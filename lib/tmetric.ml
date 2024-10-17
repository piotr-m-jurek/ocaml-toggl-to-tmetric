module Tmetric = struct
  type env_variables =
    { account_id : string
    ; account_token : string
    }

  let get_env_variables () =
    let account_id = Env.get_env_var "TMETRIC_ACCOUNT_ID" in
    let account_token = Env.get_env_var "TMETRIC_API_TOKEN" in
    { account_id; account_token }
  ;;

  let user_profile_endpoint = Uri.of_string "https://app.tmetric.com/api/v3/user"

  let get_post_entry ~account_id ~user_id =
    "https://app.tmetric.com/api/accounts/" ^ account_id ^ "/timeentries/" ^ user_id
    |> Uri.of_string
  ;;

  let get_auth_headers ~token =
    Cohttp.Header.of_list
      [ "Authorization", "Bearer " ^ token; "Accept", "application/json" ]
  ;;

  type time_zone = { current_offset : float option }

  let time_zone_of_yojson json =
    let open Yojson.Basic.Util in
    { current_offset = json |> member "currentOffset" |> to_float_option }
  ;;

  type account =
    { id : int
    ; name : string
    ; first_week_day : int
    }

  let account_of_yojson json =
    let open Yojson.Basic.Util in
    { id = json |> member "id" |> to_int
    ; name = json |> member "name" |> to_string
    ; first_week_day = json |> member "firstWeekDay" |> to_int
    }
  ;;

  type profile =
    { active_account_id : int
    ; name : string
    ; email : string
    ; time_zone : time_zone
    ; accounts : account list
    }

  let profile_of_yojson json =
    let open Yojson.Basic.Util in
    { active_account_id = json |> member "activeAccountId" |> to_int
    ; name = json |> member "name" |> to_string
    ; email = json |> member "email" |> to_string
    ; time_zone = json |> member "timeZone" |> time_zone_of_yojson
    ; accounts = json |> member "accounts" |> to_list |> List.map account_of_yojson
    }
  ;;

  let fetch_profile () =
    let open Lwt.Syntax in
    let open Cohttp_lwt_unix in
    let _ = Dotenv.export () in
    let process =
      let { account_token; account_id = _ } = get_env_variables () in
      let* resp, body =
        Client.get user_profile_endpoint ~headers:(get_auth_headers ~token:account_token)
      in
      let* body_string = Cohttp_lwt.Body.to_string body in
      let code = resp |> Cohttp_lwt_unix.Response.status |> Cohttp.Code.code_of_status in
      Printf.printf "Response code %d" code;
      let basic_json = Yojson.Basic.from_string body_string in
      Lwt.return (body_string |> Yojson.Basic.from_string |> profile_of_yojson)
    in
    Lwt_main.run process
  ;;
end
