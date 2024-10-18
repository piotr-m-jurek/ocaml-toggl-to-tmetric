let () =
  let _ =
    match Ocaml_toggl_to_tmetric.Tmetric.fetch_profile () with
    | Ok profile ->
      Printf.printf
        "\nwe achieved profile %s\n"
        (Ocaml_toggl_to_tmetric.Tmetric.show_profile profile)
    | Error e -> Printf.eprintf "\nsomething went wrong, and that's the error %s\n" e
  in
  ()
;;

(*
   1. get dates from env variables
   2. fetch toggl entries & projects
   3. fetch tmetric projects
   4. map toggl entries to tmetric (toggl projects, toggl entries)
   5. filter out the project not belonging to tmetricProjects
   6. push entry to tmetric(entry, tmetricToken, tmetricProjects, userId)
*)
