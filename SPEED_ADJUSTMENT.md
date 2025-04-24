# Snackr Ticker Speed Adjustment

## Current Changes

The ticker speed has been hardcoded to be much slower (200 seconds for a complete animation cycle). This should make it easier to read and click on articles.

## How to Further Adjust the Speed

If you want to make the ticker move even slower or faster, you can modify the value directly in the code:

1. Open this file:
   ```
   lib/features/feed_ticker/presentation/widgets/ticker.dart
   ```

2. Find these lines (around line 35-37):
   ```dart
   _animationController = AnimationController(
     vsync: this,
     duration: const Duration(seconds: 200), // Much slower animation - hardcoded to 200 seconds
   );
   ```

3. Change the `200` to a different value:
   - Larger values (e.g., 300, 400) = SLOWER scrolling
   - Smaller values (e.g., 100, 50) = FASTER scrolling

4. Also update the hardcoded value in the `_updateScrollSpeed()` method (around line 107):
   ```dart
   _animationController.duration = const Duration(seconds: 200);
   ```

5. Save the file and restart the app.

## Future Improvement

For a proper solution, we should add a settings UI to control the speed. This would require:

1. Creating a settings screen with a slider for ticker speed
2. Updating the UI to allow changing settings without editing code
3. Properly saving those settings to the database

Until then, you can use the manual adjustment method above.