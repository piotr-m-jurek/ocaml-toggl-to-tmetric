open Core

module Uris = struct
  let get_toggl_time_entries = "https://api.track.toggl.com/api/v9/me/time_entries"
  let get_toggl_projects = "https://api.track.toggl.com/api/v9/workspaces"

  let make_get_project_by_workspace_id id =
    "https://api.track.toggl.com/api/v9/workspaces/" ^ id ^ "/projects"
  ;;

  let make_get_header ~token =
    let token = token ^ ":api_token" |> Base64.encode_string in
    Cohttp.Header.of_list
      [ "Content-Type", "application/json"; "Authorization", "Basic " ^ token ]
  ;;
end

module Toggl_env = struct
  Env.parse ()

  let get_token = Env.get_env_var "TOGGL_API_TOKEN"
end

type time_entry =
  { project_id : int option
  ; start : string
  ; stop : string
  ; description : string option
  }
[@@deriving yojson { strict = false }, show]

type time_entries = time_entry list [@@deriving yojson { strict = false }, show]

let fetch_time_entries ({ start_date; end_date } : Dates.date_range) =
  let open Lwt.Syntax in
  let token = Toggl_env.get_token in
  let uri =
    Uris.get_toggl_time_entries
    |> Uri.of_string
    |> fun uri ->
    Uri.add_query_params uri [ "start_date", [ start_date ]; "end_date", [ end_date ] ]
  in
  let* resp, body =
    Cohttp_lwt_unix.Client.get uri ~headers:(Uris.make_get_header ~token)
  in
  let* body = body |> Cohttp_lwt.Body.to_string in
  let code = resp |> Cohttp_lwt_unix.Response.status |> Cohttp.Code.code_of_status in
  Fmt.pr "@\n\n code: %d, @.body: %s" code body;
  match code with
  | 200 ->
    Lwt.return_ok
      (body |> Yojson.Safe.from_string |> time_entries_of_yojson |> Result.ok_or_failwith)
  | _ ->
    Fmt.pr "@ code: %d, @.body: %s" code body;
    Lwt.return_error "failed to fetch"
;;

type workspace =
  { name : string
  ; id : int
  }
[@@deriving yojson { strict = false }, show]

type workspaces = workspace list [@@deriving yojson, show]

let fetch_workspaces =
  let open Lwt.Syntax in
  let token = Toggl_env.get_token in
  let uri = Uris.get_toggl_projects |> Uri.of_string in
  let* resp, workspaces =
    Cohttp_lwt_unix.Client.get uri ~headers:(Uris.make_get_header ~token)
  in
  let* body_string = workspaces |> Cohttp_lwt.Body.to_string in
  let code = resp |> Cohttp_lwt_unix.Response.status |> Cohttp.Code.code_of_status in
  Fmt.pr "@ Code: %d, @.Body: %s" code body_string;
  match code with
  | 200 ->
    Lwt.return_ok
      (body_string
       |> Yojson.Safe.from_string
       |> workspaces_of_yojson
       |> Result.ok_or_failwith)
  | _ -> Lwt.return_error "failed to fetch projects"
;;
