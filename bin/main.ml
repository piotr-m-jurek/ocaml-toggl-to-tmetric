open Core
open Ocaml_toggl_to_tmetric

(* ===DEBUGGING FOR COHTTP_DEBUG=true=== *)
let reporter ppf =
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
;;

(* ===TESTING POSTING ENTRY=== *)
(* let () =
  let entry : Ocaml_toggl_to_tmetric.Tmetric.time_entry =
    { start_time = "2024-10-18T08:00:00"
    ; end_time = "2024-10-18T16:00:00"
    ; note = "FE tasks"
    ; project = { id = 831916; description = "FE" }
    }
  in
  let result = entry |> Ocaml_toggl_to_tmetric.Tmetric.post_entry |> Lwt_main.run in
  match result with
  | Ok _ -> 
  | Error e -> Printf.printf "%s" e
;; *)

(* let () =
   let start_date, end_date = Cli.get_correct_date_range () in
   let range = Dates.get_UTC_range start_date end_date in
   Printf.printf "Start: %s, end: %s\n" range.start_date range.end_date
   ;; *)

(* let () =
  let entries = Lwt_main.run Toggl.get_projects |> Result.ok_or_failwith in
  Fmt.pr "%s" @@ Toggl.show_projects entries
;; *)

let () =
  let entries =
    Lwt_main.run
      (Toggl.fetch_time_entries
         { start_date = "2024-10-28T00:00:00Z"; end_date = "2024-11-01T23:59:59Z" })
    |> Result.ok_or_failwith
  in
  List.iter entries ~f:(fun e -> Fmt.pr "@ Time entry %s @." @@ Toggl.show_time_entry e)
;;
(*
   TODO:
   - [ ] fetch projects in workspaces
   - [ ] map toggl entries to tmetric (toggl projects, toggl entries)
   - [ ] filter out the project not belonging to tmetricProjects
   - [x] push entry to tmetric(entry, tmetricToken, tmetricProjects, userId)
   - [x] fetch tmetric projects
   - [x] get dates from env variables
   - [x] fetch toggl entries
   - [x] fetch workspaces
   - [x] prompt for dates

   TODO:
   - [ ] TUI - get the default dates for input? for example for the current month, so you can click
*)
