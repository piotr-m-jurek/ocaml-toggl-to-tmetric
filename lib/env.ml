exception EnvVarNotFound of string

let get_env_var var_name =
  match Sys.getenv_opt var_name with
  | Some var -> var
  | None ->
    raise (EnvVarNotFound (Printf.sprintf "Environment variable '%s' not found" var_name))
;;
