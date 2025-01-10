# ocaml-toggl-to-tmetric

a handy tool for transferring tracked time from *Toggl* to *Tmetric*.

===

## TODO:

- [ ] Import Tmetric projects in universal format
- [ ] Import Toggl projects in universal format
- [x] map toggl entries to tmetric (toggl projects, toggl entries)
- [x] filter out the project not belonging to tmetricProjects
- [x] fetch projects in workspaces
- [x] push entry to tmetric(entry, tmetricToken, tmetricProjects, userId)
- [x] fetch tmetric projects
- [x] get dates from env variables
- [x] fetch toggl entries
- [x] fetch workspaces
- [x] prompt for dates

## TODO : V2
- [ ] TUI - get the default dates for input? for example for the current month, so you can click
- [ ] Offhub integration


## API DOCS
- [Tmetric](https://app.tmetric.com/api-docs/#/)
- [Toggl](https://engineering.toggl.com/docs/api/projects)
