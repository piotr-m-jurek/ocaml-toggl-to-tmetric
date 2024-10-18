exception EnvVarNotFound of string

let get_env_var var_name =
  match Sys.getenv_opt var_name with
  | Some var -> var
  | None ->
    let msg = Printf.sprintf "Environment variable '%s' not found" var_name in
    raise (EnvVarNotFound msg)
;;
