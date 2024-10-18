let user_profile_endpoint = "https://app.tmetric.com/api/v3/user" |> Uri.of_string

let post_entry_endpoint ~active_account_id =
  "https://app.tmetric.com/api/v3/accounts/" ^ active_account_id ^ "/timeentries"
  |> Uri.of_string
;;

let get_headers ~token =
  Cohttp.Header.of_list
    [ "Authorization", "Bearer " ^ token; "Accept", "application/json" ]
;;

let get_post_headers ~token =
  get_headers ~token
  |> fun headers -> Cohttp.Header.add headers "Content-Type" "application/json"
;;

type env_variables =
  { account_id : string
  ; account_token : string
  }

let get_env_variables =
  let _ = Dotenv.export () in
  let account_id = Env.get_env_var "TMETRIC_ACCOUNT_ID" in
  let account_token = Env.get_env_var "TMETRIC_API_TOKEN" in
  { account_id; account_token }
;;

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
    let { account_token; account_id = _ } = get_env_variables in
    let* resp, body =
      Client.get user_profile_endpoint ~headers:(get_headers ~token:account_token)
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

type project =
  { id : int
  ; description : string
  }
[@@deriving yojson { strict = false }, show]

type time_entry =
  { start_time : string [@key "startTime"]
  ; end_time : string [@key "endTime"]
  ; project : project
  ; note : string
  }
[@@deriving yojson { strict = false }, show]

let post_entry (entry : time_entry) =
  let open Lwt.Syntax in
  let open Cohttp_lwt_unix in
  let { account_token; account_id } = get_env_variables in
  Printf.printf "\n\nAccount id: %s\n\n" account_id;
  let* resp, body =
    Client.post
      (post_entry_endpoint ~active_account_id:account_id)
      ~headers:(get_post_headers ~token:account_token)
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
  | 200 -> Lwt.return_ok "post_entry successfull"
  | _ ->
    entry
    |> show_time_entry
    |> Printf.sprintf "\nsomething went wrong with posting entry: %s\n"
    |> Lwt.return_error
;;

let post_entries ~(entries : time_entry list) =
  let results = Lwt_list.map_p post_entry entries |> Lwt_main.run in
  results
  |> List.iter (fun result ->
    match result with
    | Ok _ -> ()
    | Error e -> Printf.printf "%s" e)
;;
