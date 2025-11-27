# KidLearn iOS App

A playful teaching tool for kids covering numbers, shapes, colours, animals, fruits/vegetables, and a drawing canvas. Includes a friendly "Talking Tom"-style voice using AVSpeechSynthesizer.

## Features
- Categories: Numbers, Shapes, Colours, Animals, Fruits & Vegetables, Draw
- Talking Tom voice feedback (toggle on/off)
- Drawing canvas with color palette, brush size, clear, and save to Photos
- Optimized image loading with NSCache in Animals
- Centralized theme and UI helpers

## Project Structure
- App sources: `KidLearn/`
- Assets: `KidLearn/Assets.xcassets/` and `KidLearn/Resources/`
- Tests: `KidLearnTests/`, `KidLearnUITests/`

Key files:
- `MainScreen.swift`: Category grid and navigation
- `AnimalsVC.swift`: Animals carousel (to be renamed to `AnimalsViewController.swift` in refactor)
- `DrawingViewController.swift`: Drawing feature
- `TalkingTomManager.swift`: Speech synthesis and user toggle
- `Theme.swift`, `UIHelper.swift`: Shared theme and UI utilities

## Requirements
- macOS with Xcode (latest stable)
- iOS Simulator (e.g., iPhone 14) for manual testing
- Optional: SwiftLint via Homebrew

## Setup
1. Install Xcode via the App Store or developer.apple.com.
2. Open Xcode once to finish component installation.
3. Select Xcode developer directory:
   ```zsh
   sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
   xcodebuild -version
   ```
4. If license prompt appears:
   ```zsh
   sudo xcodebuild -license accept
   ```

## Build & Run
Build from terminal:
```zsh
xcodebuild -scheme KidLearn -project KidLearn.xcodeproj -configuration Debug build
```
Run tests (if configured):
```zsh
xcodebuild test -scheme KidLearnTests -project KidLearn.xcodeproj -configuration Debug
```
Alternatively, open the project in Xcode and run the `KidLearn` scheme on an iPhone simulator.

## Asset Optimization
A script `optimize_assets.sh` (to be finalized) will compress PNG images using `sips` and optionally convert audio to m4a.
Example usage:
```zsh
./optimize_assets.sh
```
Expected outcome: reduce total asset bundle size by ~20%.

## Linting (Optional)
Install SwiftLint via Homebrew:
```zsh
brew install swiftlint
swiftlint lint
```
A `.swiftlint.yml` can be added to configure rules (line length, naming, etc.).

## Settings: Talking Tom Toggle
The speech voice can be enabled/disabled via `UserDefaults` bound to `TalkingTomEnabled`. Code honors the toggle:
```swift
TalkingTomManager.shared.isEnabled = false // disables voice
```
A simple Settings screen can be added to expose this toggle in the UI.

## Permissions
To save drawings to Photos, `Info.plist` includes:
- `NSPhotoLibraryAddUsageDescription`

## Roadmap (Refactor)
- Rename `*VC.swift` files to `*ViewController.swift` and update references
- Add Settings UI for the Talking Tom toggle
- Finalize `optimize_assets.sh` and add `.swiftlint.yml`

## Troubleshooting
- If `xcodebuild` errors: ensure Xcode is installed and selected via `xcode-select -switch`.
- If the Photos save alert doesn’t appear: check `NSPhotoLibraryAddUsageDescription` in `Info.plist`.
- If images look blurry: verify asset scales and consider adjusting placeholder rendering scale.

## License
This project is for educational purposes.