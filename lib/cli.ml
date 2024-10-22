open Core

let rec get_correct_date_range () =
  Out_channel.newline stdout;
  Printf.printf "Start Date (format DD-MM-YYYY): ";
  let start_date =
    Out_channel.(flush stdout);
    In_channel.(input_line_exn stdin)
  in
  Printf.printf "End Date (format DD-MM-YYYY): ";
  let end_date =
    Out_channel.(flush stdout);
    In_channel.(input_line_exn stdin)
  in
  match Dates.parse_date start_date, Dates.parse_date end_date with
  | Ok start_date, Ok end_date -> start_date, end_date
  | Error e1, Error e2 ->
    Printf.printf
      "Expected format: DD-MM-YYYY. Got %s "
      (String.concat ~sep:"," [ e1; e2 ]);
    get_correct_date_range ()
  | Ok _, Error e ->
    Printf.printf "Expected format: DD-MM-YYYY. Got %s " e;
    get_correct_date_range ()
  | Error e, Ok _ ->
    Printf.printf "Expected format: DD-MM-YYYY. Got %s " e;
    get_correct_date_range ()
;;
