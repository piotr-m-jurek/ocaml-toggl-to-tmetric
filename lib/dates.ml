open Core

type date =
  { year : string
  ; month : string
  ; day : string
  }

type date_range =
  { start_date : string
  ; end_date : string
  }

let parse_date input_string =
  match input_string |> String.split_on_chars ~on:[ '-' ] with
  | [ year; month; day ] -> Ok { year; month; day }
  | _ -> Error ("Wrong format, expected YYYY-MM-DD, got: " ^ input_string)
;;

let get_UTC_range (start_date : date) (end_date : date) =
  let start_date =
    Printf.sprintf "%s-%s-%sT:00:00:00Z" start_date.year start_date.month start_date.day
  in
  let end_date =
    Printf.sprintf "%s-%s-%sT:23:59:99Z" end_date.year end_date.month end_date.day
  in
  { start_date; end_date }
;;

let get_current_year () =
  let time_now = Core_unix.time () in
  let local_time = Core_unix.localtime time_now in
  local_time.Core_unix.tm_year + 1900
;;

let get_week_day () =
  let open Core_unix in
  let week_day (tm : tm) = tm.tm_wday in
  time () |> localtime |> week_day
;;
