# Snackr Ticker Speed Control

The default ticker speed has been adjusted to be slower and more readable.

## How to Apply the New Speed Settings

1. Open Terminal
2. Navigate to the snackr_flutter directory
3. Run the reset script:

```bash
./reset_speed.sh
```

This script will:
- Reset the app settings to use the new default speed (0.2 instead of 1.0)
- Start the Snackr app with the new settings

## Manual Speed Adjustment

If you want to adjust the speed further:

1. Edit the file: `lib/features/feed_ticker/domain/entities/app_settings.dart`
2. Find the line with `this.scrollSpeed = 0.2`
3. Change 0.2 to a different value:
   - Lower values (e.g., 0.1) = slower scrolling
   - Higher values (e.g., 0.5) = faster scrolling
4. Run the reset script again to apply the changes

## Menu Icon Issues

You mentioned that menu icons aren't working. We'll need to investigate this further, which may require looking at the event handlers and UI components related to the menu system.