let user_profile_endpoint = "https://app.tmetric.com/api/v3/user" |> Uri.of_string

let post_entry_endpoint ~active_account_id =
  "https://app.tmetric.com/api/accounts/" ^ active_account_id ^ "/timeentries"
  |> Uri.of_string
;;

let get_headers ~token =
  Cohttp.Header.of_list
    [ "Authorization", "Bearer " ^ token; "Accept", "application/json" ]
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

(* === PROFILE === *)

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

(*
   type project = { project_id : int [@key "projectId"] } [@@deriving yojson]
type time_entry =
  { start_time : string [@key "startTime"]
  ; end_time : string [@key "endTime"]
  ; note : string
  ; project : project
  }
[@@deriving yojson]
*)

(*
   {
  "id": 210658,
  "name": "Piotr Małecki-Jurek",
  "activeAccountId": 14279,
  "dateFormat": "DD/MM/YYYY",
  "timeFormat": "H:mm",

  "email": "piotr.m.jurek@tooploox.com",

  "iconUrl": "https://lh3.googleusercontent.com/a/ACg8ocJ2rfF1YCRSiKXw5zE4p7RRDwQGxXxW7GFGf0b_IXkVp2t2YgBH=s96-c",

  "cultureInfo": {
    "id": "en",
    "nativeName": "English"
  },

  "timeZone": {
    "id": "Europe/Prague",
    "displayName": "(UTC+01:00) Prague",
    "winterOffset": 1.0,
    "summerOffset": 2.0,
    "currentOffset": 2.0
  },
  "accounts": [
    {
      "id": 14279,
      "name": "Tooploox",
      "firstWeekDay": 1,

      "timeTracking": { "allowManualEditing": true, "allowNewTags": false, "allowNewTask": true, "allowNewProject": true, "allowNewClient": false, "requireDescription": false, "requireProject": false, "requireTags": false, "requireTask": false, "allowTeamView": false },

      "activity": { "inactivityStopMinutes": 0, "captureActivityLine": true, "captureActivityLevels": false, "captureAppsAndSites": false, "captureDetails": false, "captureScreenshots": false, "blurScreenshots": false },

      "role": "member"
    }
  ]
}
*)
