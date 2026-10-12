# Contributing

Bug reports, ideas, and pull requests are welcome. For anything bigger than a small fix, open an issue first so we can agree on the approach before you write code.

## Reporting a bug

[Open an issue](https://github.com/coreyhaines31/midnightoil/issues/new/choose) and include:

- Your Midnight Oil version (menu › About Midnight Oil), macOS version, and Mac model.
- What you did, what you expected, and what happened instead.
- If the Mac slept when it shouldn't have: the output of `pmset -g assertions` during a session, and whether the lid was closed or the Mac was on battery.

Security issues are different: please report them privately, as described in [SECURITY.md](SECURITY.md).

## Setting up

Follow [Building from source](README.md#building-from-source) in the README. In short:

```sh
brew install xcodegen swiftlint
xcodegen generate
xcodebuild -project MidnightOil.xcodeproj -scheme MidnightOil CODE_SIGNING_ALLOWED=NO test
```

Session timing, trigger rules, schedules, and statistics live in `Packages/MidnightOilCore`, which has its own unit tests. If your change is about *when* a session starts or ends, it probably belongs there, with a test.

## Making a pull request

1. Fork the repository and branch from `development`, which is where work lands before a release. `main` holds what's been released.
2. Keep each pull request to one change, and each commit to one step of it.
3. Run the tests and `swiftlint --strict`. CI runs both and must pass.
4. Open the pull request against `development` and fill in the template: what it changes and how you tested it. For UI changes, include a screenshot.

Interface text follows a few conventions: write from the user's side ("Keep Awake Until", not "Set end date"), keep it short, and give new settings an ⓘ explanation in `MidnightOil/Settings/Help.swift`.

## Contributor terms

Midnight Oil is licensed under FSL-1.1-MIT, and some future features may be sold under a commercial license. To keep that possible, every contribution comes with these terms. By opening a pull request, you agree that:

1. You wrote the contribution, or otherwise have the right to submit it.
2. You grant Corey Haines a perpetual, worldwide, non-exclusive, royalty-free, irrevocable license to use, modify, and distribute your contribution, and to sublicense and relicense it under any terms, including commercial ones.
3. You keep the copyright in your contribution, and you can use it however you like.

If you can't agree to these terms, please open an issue describing the change instead.
