(lang dune 3.16)

(name ocaml_toggl_to_tmetric)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name ocaml_toggl_to_tmetric)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune cohttp cohttp-lwt-unix yojson ppx_deriving_yojson lwt_ssl dotenv core)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
