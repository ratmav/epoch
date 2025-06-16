# TODO

1. project management
    - install github cli
    - need board to work with multiple repos
        - epoch
        - dotfiles
        - trap
        - ???
    - project name?
    - kanban board
    - remove TODO.md from `epoch` repo
3. new `epoch` feature TICKET: `:EpochComplete`
    - If the last interval on the current timesheet is open, close with current timestamp.
    - If the last interval on the current timesheet is closed, notify user.
    - v0.2.0
4. fix `trap` plugin
    - probably abstract floating window logic from `epoch` into it's own plugin
    - fix trap bugs
5. new epic: push/pull timesheet data from remote systems via api
    - use rust, similar to `marv`.
    - v0.3.0 (intervals api support; design to support multiple systems)
    - use configuration file to map epoch data structure to remote system data structure
    - will likely require adding new fields to epoch data structure
    - worth mocking api
