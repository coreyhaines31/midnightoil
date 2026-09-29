# Midnight Oil

Keep your Mac awake. An open-source, actively maintained replacement for [Amphetamine](https://apps.apple.com/us/app/amphetamine/id937984704).

> Work in progress. See the [roadmap issues](https://github.com/coreyhaines31/midnightoil/issues).

## Building from source

Requires macOS 14+, Xcode 16+, and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen swiftlint
xcodegen generate          # creates MidnightOil.xcodeproj from project.yml
open MidnightOil.xcodeproj
```

Or from the command line:

```sh
xcodebuild -project MidnightOil.xcodeproj -scheme MidnightOil test
swiftlint --strict
```

App logic lives in `Packages/MidnightOilCore` so it can be tested without launching the app.

## License

[MIT](LICENSE)
