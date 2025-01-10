open Core

let make_tmetric_project start_time end_time project (note : string) : Tmetric.time_entry =
  { start_time; end_time; project; note }
;;

let make_timeentry_project project_id description : Tmetric.timeentry_project =
  { project_id; description }
;;

(* let make_project_option: Tmetric.time = Some { *)
let tmetric_entry_of_toggl
  (entry : Toggl.time_entry)
  (toggl_project : Toggl.project)
  (tmetric_projects : Tmetric.projects)
  : Tmetric.time_entry option
  =
  let matched_project : Tmetric.timeentry_project option =
    List.find_map tmetric_projects ~f:(fun tmetric_project ->
      Fmt.pr "tmetric_name: %s toggl_name %s" tmetric_project.name toggl_project.name;
      match String.equal tmetric_project.name toggl_project.name with
      | true -> Some (make_timeentry_project tmetric_project.id tmetric_project.name)
      | false ->
        Fmt.pr "@couldn't find project in tmetric with name %s@." toggl_project.name;
        None)
  in
  let note = entry.description |> Option.value ~default:"Project work" in
  Option.map matched_project ~f:(fun project ->
    make_tmetric_project entry.start entry.stop project note)
;;
