module Uris = struct
  let get_toggl_time_entries = "https://api.track.toggl.com/api/v9/me/time_entries"
  let get_toggl_project_ids = "https://api.track.toggl.com/api/v9/workspaces"

  let make_get_project_by_workspace_id id =
    "https://api.track.toggl.com/api/v9/workspaces/" ^ id ^ "/projects"
  ;;

  let make_get_header ~token =
    let token = Base64.encode_string token in
    Cohttp.Header.of_list
      [ "Content-Type", "application/json"
      ; "Authorization", "Basic " ^ token ^ ":api_token"
      ]
  ;;
end
