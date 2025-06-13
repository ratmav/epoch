# TODO

1. new `epoch` feature: `:EpochEdit <date/>`
    - Add support for :EpochEdit <date/> to open the timesheet for a specific date
    - No date opens today's timesheet by default
2. github action
    - run these `make` targets as their own jobs in a single pipeline, they should all pass, and we want this to run on any pr to `main` branch
        - `coverage`
        - `laconic`
        - `lint`
3. tag as v0.1.0
4. project management
    - need board to work with multiple repos
        - epoch
        - dotfiles
        - trap
        - ???
    - project name?
    - kanban board
5. new `epoch` feature TICKET: `:EpochComplete`
    - If the last interval on the current timesheet is open, close with current timestamp.
    - If the last interval on the current timesheet is closed, notify user.
    - v0.2.0
6. fix `trap` plugin
    - probably abstract floating window logic from `epoch` into it's own plugin
    - fix trap bugs
7. new epic: push/pull timesheet data from remote systems via api
    - use rust, similar to `marv`.
    - v0.3.0 (intervals api support; design to support multiple systems)
    - use configuration file to map epoch data structure to remote system data structure
    - will likely require adding new fields to epoch data structure
    - worth mocking api
