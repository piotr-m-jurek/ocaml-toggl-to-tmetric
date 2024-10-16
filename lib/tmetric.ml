type env_variables =
  { account_id : string
  ; account_token : string
  }

let get_env_variables () =
  let account_id = Env.get_env_var "TMETRIC_ACCOUNT_ID" in
  let account_token = Env.get_env_var "TMETRIC_API_TOKEN" in
  { account_id; account_token }
;;

let user_profile_endpoint = Uri.of_string "https://app.tmetric.com/api/userprofile"

let get_post_entry ~account_id ~user_id =
  "https://app.tmetric.com/api/accounts/" ^ account_id ^ "/timeentries/" ^ user_id
  |> Uri.of_string
;;

let get_auth_headers ~token =
  Cohttp.Header.of_list
    [ "Authorization", "Bearer " ^ token
    ; "Content-Type", "application/json"
    ; "Accept-Encoding", "gzip, defalte, br"
    ; "Accept", "*/*"
    ]
;;

(*
   {
  "id": 123,
  "name": "John Doe",
  "activeAccountId": 456,
  "dateFormat": "MM/DD/YYYY",
  "timeFormat": "H:mm",
  "email": "john.doe@example.com",
  "timeZone": {
    "currentOffset": -4
  },
  "accounts": [
    {
      "id": 456,
      "name": "My Company",
      "firstWeekDay": 1,
    }
  ]
}
*)
type profile = { active_account_id : string }

let fetch_profile ~token =
  let open Lwt.Syntax in
  let open Cohttp_lwt_unix in
  let* resp, body = Client.get user_profile_endpoint ~headers:(get_auth_headers ~token) in
  let* body_string = Cohttp_lwt.Body.to_string body in
  let code = resp |> Cohttp_lwt_unix.Response.status |> Cohttp.Code.code_of_status in
  Printf.printf "Response code %d, body %s" code body_string;
  failwith "TODO"
;;
