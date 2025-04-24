# Multi-Window System in Snackr Flutter

This document describes the multi-window system implemented in Snackr Flutter to solve the dialog constraint issues.

## Overview

The multi-window system uses a custom `FloatingWindowRoute` implementation that creates "floating windows" that break out of the parent ticker window's constraints. This approach overcomes the limitation where Flutter dialogs are constrained by the size of their parent window.

## Key Components

### FloatingWindowRoute

The `FloatingWindowRoute` class (in `lib/core/utils/floating_window_route.dart`) extends Flutter's `PopupRoute` to create a window that:

- Breaks out of parent widget constraints
- Positions itself centered on the screen regardless of parent window size
- Adapts its size based on screen dimensions to ensure content visibility
- Provides a title bar with close functionality
- Uses material design for elevation and shadow effects

### DialogWindowManager

The `DialogWindowManager` class (in `lib/features/feed_ticker/presentation/widgets/dialogs/dialog_window_manager.dart`) is responsible for creating, tracking, and managing floating windows. It provides methods to:

- Show dialogs using the `FloatingWindowRoute`
- Track open dialogs by ID
- Close dialogs individually or all at once
- Prevent duplicate dialogs from opening

### Implementation in Various Dialogs

The dialog implementation has been updated across the app:
- Settings dialog
- Add feed dialog
- Article detail dialog
- Starred items dialog
- Manual feed dialog

All dialogs now:
- Use `SingleChildScrollView` to handle any overflow
- Have improved styling with proper padding and typography
- Use a consistent design language across the app
- Adapt their content to be readable at various sizes

## Usage

To open a new dialog window:

```dart
// Open settings dialog
await ref.read(showSettingsDialogProvider)(context);

// Open add feed dialog
await ref.read(dialogWindowManagerProvider).showDialogWindow(
  dialogId: 'add_feed_dialog',
  title: 'Add Feed',
  width: 600,
  height: 500,
  builder: (context) => const AddFeedDialog(),
);

// Open article detail
await ref.read(dialogWindowManagerProvider).showDialogWindow(
  dialogId: 'article_detail_${DateTime.now().millisecondsSinceEpoch}',
  title: articleTitle,
  width: 800, 
  height: 800,
  builder: (context) => ArticleDetailView(article: articleData),
);
```

## Benefits

1. **Proper Window Sizing**: Each dialog can have its own dimensions independent of the ticker window
2. **No Overflow Errors**: Eliminates RenderFlex overflow errors that occurred with constrained dialogs
3. **Better User Experience**: Dialogs appear properly sized and positioned
4. **Improved Content Visibility**: Content is always visible with adaptive sizing and scrolling
5. **Consistent UI**: All dialogs follow the same design patterns

## Technical Notes

- Uses Flutter's animation and positioning system for smooth transitions
- Window IDs are tracked to prevent duplicate dialogs
- Windows automatically adapt to screen size for better visibility
- Each dialog includes SingleChildScrollView to handle any remaining overflow
- Typography and spacing have been enhanced for better readability
- The implementation is lighter weight than using multiple OS windows
- Dark theme styling is consistent across all dialogs