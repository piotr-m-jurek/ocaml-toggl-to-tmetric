open Core
open Ocaml_toggl_to_tmetric

(* ===DEBUGGING FOR COHTTP_DEBUG=true=== *)
(* let reporter ppf =
  let report src level ~over k msgf =
    let k _ =
      over ();
      k ()
    in
    let with_metadata header _tags k ppf fmt =
      Format.kfprintf
        k
        ppf
        ("%a[%a]: " ^^ fmt ^^ "\n%!")
        Logs_fmt.pp_header
        (level, header)
        Fmt.(styled `Magenta string)
        (Logs.Src.name src)
    in
    msgf @@ fun ?header ?tags fmt -> with_metadata header tags k ppf fmt
  in
  { Logs.report }
;;

let () =
  Logs.set_reporter (reporter Fmt.stderr);
  Logs.set_level ~all:true (Some Logs.Debug)
;; *)

let () =
  let task =
    let open Lwt.Syntax in
    let* toggl_projects = Toggl.fetch_projects () in
    let* toggl_entries =
      Toggl.fetch_time_entries
        { start_date = "2024-10-01T00:00:00Z"; end_date = "2024-11-01T23:59:59Z" }
    in
    let* tmetric_projects = Tmetric.fetch_projects () in
    let toggl_entries = toggl_entries |> Result.ok_or_failwith in
    let tmetric_projects = tmetric_projects |> Result.ok_or_failwith in
    let entries =
      List.filter_map toggl_entries ~f:(fun entry ->
        let toggl_project =
          List.find_exn toggl_projects ~f:(fun project ->
            Option.value_exn entry.project_id = project.id)
        in
        Toggl_tmetric.tmetric_entry_of_toggl entry toggl_project tmetric_projects)
    in
    Tmetric.post_time_entries ~entries
  in
  Lwt_main.run task
;;

