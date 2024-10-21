open Core

module Uris = struct
  let base_url = "https://app.tmetric.com/api/v3"
  let make_user_profile () = base_url ^ "/user" |> Uri.of_string

  let make_get_projects ~account_id =
    base_url ^ "/accounts/" ^ account_id ^ "/timeentries/projects" |> Uri.of_string
  ;;

  let make_post_entry ~account_id =
    base_url ^ "/accounts/" ^ account_id ^ "/timeentries" |> Uri.of_string
  ;;

  let make_get_headers ~token =
    Cohttp.Header.of_list
      [ "Authorization", "Bearer " ^ token; "Accept", "application/json" ]
  ;;

  let make_post_headers ~token =
    make_get_headers ~token
    |> fun headers -> Cohttp.Header.add headers "Content-Type" "application/json"
  ;;
end

module Tmetric_env = struct
  type env_variables =
    { account_id : string
    ; account_token : string
    }

  let get_account_id = Env.get_env_var "TMETRIC_ACCOUNT_ID"
  let get_account_token = Env.get_env_var "TMETRIC_API_TOKEN"
end

(* === PROFILE === *)
type time_zone =
  { id : string
  ; current_offset : float [@key "currentOffset"]
  }
[@@deriving yojson { strict = false }, show]

type account =
  { id : int
  ; name : string
  ; first_week_day : int [@key "firstWeekDay"]
  }
[@@deriving yojson { strict = false }, show]

type profile =
  { active_account_id : int [@key "activeAccountId"]
  ; name : string
  ; email : string
  ; time_zone : time_zone [@key "timeZone"]
  ; accounts : account list
  }
[@@deriving yojson { strict = false }, show]

let fetch_profile () =
  let open Lwt.Syntax in
  let open Cohttp_lwt_unix in
  let process =
    let account_token = Tmetric_env.get_account_token in
    let* resp, body =
      Client.get
        (Uris.make_user_profile ())
        ~headers:(Uris.make_get_headers ~token:account_token)
    in
    let* body_string = Cohttp_lwt.Body.to_string body in
    let code = resp |> Cohttp_lwt_unix.Response.status |> Cohttp.Code.code_of_status in
    Printf.printf "\nResponse code: %d\n" code;
    let safe_string = body_string |> Yojson.Safe.from_string in
    let ret_val = safe_string |> profile_of_yojson in
    Lwt.return ret_val
  in
  Lwt_main.run process
;;

type project_client =
  { name : string
  ; id : int
  }
[@@deriving yojson { strict = false }, show]

type project =
  { id : int
  ; name : string
  ; is_billable : bool [@key "isBillable"]
  ; client : project_client
  }
[@@deriving yojson { strict = false }, show]

let fetch_projects () =
  let open Lwt.Syntax in
  let open Cohttp_lwt_unix in
  let account_id = Tmetric_env.get_account_id in
  let account_token = Tmetric_env.get_account_token in
  let* resp, body =
    Client.get
      (Uris.make_get_projects ~account_id)
      ~headers:(Uris.make_get_headers ~token:account_token)
  in
  let code = resp |> Cohttp_lwt_unix.Response.status |> Cohttp.Code.code_of_status in
  let* body = body |> Cohttp_lwt.Body.to_string in
  Printf.printf "\nResponse code: %d\n" code;
  (* Printf.printf "\nResponse body: %s\n" body; *)
  let parsed_body = body |> Yojson.Safe.from_string |> project_of_yojson in
  match code with
  | 200 -> Lwt.return_ok (parsed_body |> Result.ok_or_failwith)
  | _ -> body |> Printf.sprintf "couldn't fetch projects %s" |> Lwt.return_error
;;

type timeentry_project =
  { id : int
  ; description : string
  }
[@@deriving yojson { strict = false }, show]

type time_entry =
  { start_time : string [@key "startTime"]
  ; end_time : string [@key "endTime"]
  ; project : timeentry_project
  ; note : string
  }
[@@deriving yojson { strict = false }, show]

let post_time_entry (entry : time_entry) =
  let open Lwt.Syntax in
  let open Cohttp_lwt_unix in
  let account_id = Tmetric_env.get_account_id in
  let account_token = Tmetric_env.get_account_token in
  let* resp, body =
    Client.post
      (Uris.make_post_entry ~account_id)
      ~headers:(Uris.make_post_headers ~token:account_token)
      ~body:
        (entry
         |> time_entry_to_yojson
         |> Yojson.Safe.to_string
         |> Cohttp_lwt.Body.of_string)
  in
  let code = resp |> Cohttp_lwt_unix.Response.status |> Cohttp.Code.code_of_status in
  let* body = body |> Cohttp_lwt.Body.to_string in
  Printf.printf "\nResponse code: %d\n" code;
  Printf.printf "\n Response body: %s\n" body;
  match code with
  | 200 -> Lwt.return_ok "\npost_timeentry successfull\n"
  | _ ->
    entry
    |> show_time_entry
    |> Printf.sprintf "\nsomething went wrong with posting entry: %s\n"
    |> Lwt.return_error
;;

let post_time_entries ~(entries : time_entry list) =
  let results = Lwt_list.map_p post_time_entry entries |> Lwt_main.run in
  results
  |> List.iter ~f:(fun result ->
    match result with
    | Ok _ -> ()
    | Error e -> Printf.printf "%s" e)
;;
