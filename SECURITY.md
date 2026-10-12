# Security policy

Midnight Oil includes a privileged helper that runs as root to support closed-lid mode, so security reports matter to us.

## Reporting a vulnerability

Please don't open a public issue. Report it privately through GitHub instead: on the repository's **Security** tab, choose **Report a vulnerability**, or go straight to [the private report form](https://github.com/coreyhaines31/midnightoil/security/advisories/new).

Include what you found, how to reproduce it, and which version you tested. You'll get a reply within a few days, and credit in the release notes once a fix ships, if you'd like it.

## Supported versions

Fixes go into the latest release. The app updates itself, so please check you're on the [current version](https://github.com/coreyhaines31/midnightoil/releases/latest) before reporting.

## What the helper can do

The helper accepts connections only from the Midnight Oil app signed by its developer team, and it does one thing: turn system sleep off or back on with `pmset disablesleep`. It restores sleep when the app disconnects for any reason, and on its own launch. The code is in [`MidnightOilHelper/`](MidnightOilHelper) and [`Shared/`](Shared).
