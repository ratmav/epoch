# TODO

1. manual testing
    - complete remaining tests defined in `MANUAL_TEST_2025-06-10.md`
2. create new make target for manual test report generation
    - `make test TYPE=manual`?
        - `TYPE` defaults to `automated`; `make test` runs automated tests
        - `make test TYPE=manual` creates a new test plan
            1. remove tests/MANUAL_TEST.md
            2. copy MANUAL_TEST_2025-06-10.md to tests/templates/MANUAL_TEST.template
            3. uncheck checkboxes, use template strings, etc. to turn tests/templates/MANUAL_TEST.template into an actual template
            4. tests/templates/MANUAL_TEST.template uses our scripts/templates tooling to create a MANUAL_TEST_<YYYY-MM-DD/>.md file at repo root
                - example: `MANUAL_TEST_2025-06-10.md`
            5. MANUAL_TEST_<YYYY-MM-DD/>.md files are gitignored
2. Change 'NVIM_INSTALL_MODE' to 'NVIM_HEADLESS_MODE' in dotfiles for better semantics
    - different repo, needs pr in dotfiles, then can clean up here.
3. github action
    - run these `make` targets as their own jobs in a single pipeline, they should all pass, and we want this to run on any pr to `main` branch
        - `test`
        - `coverage`
        - `laconic`
        - `lint`
4. tag as v0.1.0
5. new feature: `:EpochEdit <date/>`
    - Add support for :EpochEdit <date/> to open the timesheet for a specific date
        - No date opens today's timesheet by default
    - v0.2.0
