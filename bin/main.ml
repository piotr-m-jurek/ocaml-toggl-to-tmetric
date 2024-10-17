let () =
  let profile = Ocaml_toggl_to_tmetric.Tmetric.Tmetric.fetch_profile () in
  Printf.printf "we achieved profile %s" profile.name;
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
