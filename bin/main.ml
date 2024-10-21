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
  | Ok _ -> ()
  | Error e -> Printf.printf "%s" e
;; *)

let rec get_dates () =
  print_newline ();
  Printf.printf "Start Date (format DD-MM-YYYY): ";
  let start_date = read_line () in
  Printf.printf "End Date (format DD-MM-YYYY): ";
  let end_date = read_line () in
  match Dates.parse_date start_date, Dates.parse_date end_date with
  | Ok start_date, Ok end_date -> start_date, end_date
  | Error e1, Error e2 ->
    Printf.printf "Expected format: DD-MM-YYYY. Got %s " (String.concat "," [ e1; e2 ]);
    get_dates ()
  | Ok _, Error e ->
    Printf.printf "Expected format: DD-MM-YYYY. Got %s " e;
    get_dates ()
  | Error e, Ok _ ->
    Printf.printf "Expected format: DD-MM-YYYY. Got %s " e;
    get_dates ()
;;

let () =
  let start_date, end_date = get_dates () in
  let range = Dates.get_UTC_range start_date end_date in
  Printf.printf "Start: %s, end: %s\n" range.start_date range.end_date
;;
(* let () = Lwt_main.run (Ocaml_toggl_to_tmetric.Tmetric.fetch_projects ()) *)

(*
   TODO:
   - [x] get dates from env variables
   - [ ] fetch toggl entries & projects
   - [ ] map toggl entries to tmetric (toggl projects, toggl entries)
   - [ ] filter out the project not belonging to tmetricProjects
   - [ ] push entry to tmetric(entry, tmetricToken, tmetricProjects, userId)
   - [x] fetch tmetric projects

   TODO:
   - [ ] TUI - get the default dates for input? for example for the current month, so you can click
*)
