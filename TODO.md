# TODO

1. documentation
    - developer documentation (`Makfile`, etc.) in `README.md`
    - user doucmentation `*.txt` files
2. github action
    - run these `make` targets as their own jobs in a single pipeline, they should all pass, and we want this to run on any pr to `main` branch
        - `test`
        - `coverage`
        - `laconic`
        - `lint`
2. manual(?) tests
    - see `tests/MANUAL_TEST_PLAN.md`
    - Execute all test groups and document results
    - Verify clean toggle behavior and user experience
    - can this actually be automated, similar to playwright for js web apps?
- GitHub action to lint, check formatting, and test new pull requests
3. new feature: `:EpochEdit <date/>`
    - Add support for :EpochEdit <date/> to open the timesheet for a specific date
        - No date opens today's timesheet by default
4. Change 'NVIM_INSTALL_MODE' to 'NVIM_HEADLESS_MODE' in dotfiles for better semantics
    - different repo, needs pr in dotfiles, then can clean up here.
