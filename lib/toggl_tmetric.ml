let tmetric_entry_of_toggl (entry : Toggl.time_entry) : Tmetric.time_entry =
  let project : Tmetric.timeentry_project = { id = 0; description = "" } in
  let note = entry.description |> Option.value ~default:"Project work" in
  { start_time = entry.start; end_time = entry.stop; project; note }
;;
