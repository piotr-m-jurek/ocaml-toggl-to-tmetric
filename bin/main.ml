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

let () = Lwt_main.run (Ocaml_toggl_to_tmetric.Tmetric.fetch_projects ())

(*
   TODO:
   1. get dates from env variables
   2. fetch toggl entries & projects
   3. fetch tmetric projects
   4. map toggl entries to tmetric (toggl projects, toggl entries)
   5. filter out the project not belonging to tmetricProjects
   6. push entry to tmetric(entry, tmetricToken, tmetricProjects, userId)
*)
