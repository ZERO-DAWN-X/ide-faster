# Image Assets Folder

## How to Add Your Image

1. **Place your image file here** in this `assets/images/` folder
2. **Supported formats**: PNG, JPG, JPEG, GIF, WebP
3. **Recommended name**: `ide_image.png` (or update the filename in `home_screen.dart`)

## Current Image Reference

The image is referenced in `lib/screens/home_screen.dart` as:
```dart
Image.asset('assets/images/ide_image.png')
```

If you use a different filename, update the path in `home_screen.dart`.

## After Adding Image

1. Make sure `pubspec.yaml` has the assets section (already configured)
2. Run `flutter pub get` to refresh assets
3. Restart the app to see your image

