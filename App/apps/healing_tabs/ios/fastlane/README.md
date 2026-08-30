fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios sync_signing

```sh
[bundle exec] fastlane ios sync_signing
```

Sync App Store signing (match)

### ios build

```sh
[bundle exec] fastlane ios build
```

Build prod IPA via Flutter (no upload)

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Upload prod build to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Submit prod build to App Store (manual review)

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Sync icons + build + upload TestFlight (one command)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
