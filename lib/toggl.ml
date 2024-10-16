let toggl_time_entries_endpoint = "https://api.track.toggl.com/api/v9/me/time_entries"
let toggl_project_ids_endpoint = "https://api.track.toggl.com/api/v9/workspaces"

let get_project_by_workspace_id id =
  "https://api.track.toggl.com/api/v9/workspaces/" ^ id ^ "/projects"
;;

let get_auth_header ~token =
  let token = Base64.encode_string token in
  Cohttp.Header.of_list
    [ "Content-Type", "application/json"
    ; "Authorization", "Basic " ^ token ^ ":api_token"
    ]
;;
