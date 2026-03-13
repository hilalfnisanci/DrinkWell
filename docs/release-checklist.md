# DrinkWell Release Checklist

## 1) Versioning
- Set `MARKETING_VERSION` (for example `1.1.0`)
- Increment `CURRENT_PROJECT_VERSION` (build number)

## 2) Ads
- Set `GADApplicationIdentifier` in `DrinkWell/Info.plist`
- Set `GADBannerAdUnitID` in `DrinkWell/Info.plist` for release
- Verify test ad unit is used only in Debug builds

## 3) Signing
- Open Xcode target settings for app + widget extension
- Confirm `Team`, bundle IDs, and capabilities
- Ensure App Group `group.com.hilalNisanci.DrinkWell` is enabled for both targets

## 4) App Store Privacy
- Review App Store Connect `App Privacy` answers
- Ensure answers match in-app behavior and `docs/privacy.md`
- If personalized ads/tracking are enabled, configure ATT and consent flow

## 5) Validation
- Run:
  - `xcodebuild -workspace DrinkWell.xcworkspace -scheme DrinkWell -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' build`
  - `xcodebuild -workspace DrinkWell.xcworkspace -scheme DrinkWell -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' test`
- Archive:
  - `xcodebuild -workspace DrinkWell.xcworkspace -scheme DrinkWell -configuration Release -destination 'generic/platform=iOS' archive -archivePath /tmp/DrinkWell.xcarchive`

## 6) Store Metadata
- Update screenshots (iPhone + iPad)
- Update description, keywords, and support URL
- Verify privacy and terms URLs

