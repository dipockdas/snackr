# Troubleshooting Guide for Snackr Flutter

## Common Issues & Solutions

### 1. Application Shows Empty Window / No Feed Items

If the application launches but you see an empty window without any feed items, try these steps:

1. **Network Permissions**
   - First, make sure the app has network permissions
   - Check if macOS is asking for permission to connect to the internet
   - The app requires `com.apple.security.network.client` entitlement to connect to RSS feeds

2. **Use the Manual Feed Button**
   - If no feeds are loaded, you'll see a "No feed items available" message with a button
   - Click "Add Feed Manually" to open the feed dialog
   - You can enter a custom feed URL or select from suggested feeds

3. **Try These Working Feeds**
   - `https://rss.nytimes.com/services/xml/rss/nyt/Technology.xml` (NY Times Technology)
   - `http://rss.cnn.com/rss/edition_technology.rss` (CNN Technology)
   - `https://feeds.bbci.co.uk/news/technology/rss.xml` (BBC Technology)
   - `https://news.google.com/rss` (Google News)

4. **Enable Verbose Logging**
   - Run the app with `flutter run -d macos --verbose` to see detailed logs
   - Look for errors related to database or network operations

### 2. Platform Message Errors

If you see errors like: `embedder.cc (2944): 'FlutterPlatformMessageCreateResponseHandle' returned 'kInvalidArguments'`, this is related to the `window_manager` package.

Solution:
- We've implemented a simplified version using `SimpleTickerWindow` instead of `TickerWindow` to avoid these issues
- This removes some window management functionality but ensures the app works

### 3. SQLite Issues

On macOS, you might encounter SQLite initialization errors:

1. **Check Database Permissions**
   - Make sure the app has permission to write to the Application Support directory
   - Run `chmod -R 755 ~/Library/Application\ Support/com.snackr.snackr-flutter/` to fix permissions

2. **Manually Initialize Database**
   - If database creation fails, you can create the database structure manually:
   ```sql
   CREATE TABLE feeds(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     url TEXT NOT NULL,
     title TEXT NOT NULL,
     description TEXT,
     imageUrl TEXT,
     lastUpdated TEXT,
     website TEXT,
     isActive INTEGER NOT NULL DEFAULT 1,
     updateFrequencyMinutes INTEGER NOT NULL DEFAULT 60,
     category TEXT
   );
   
   CREATE TABLE feed_items(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     feedId INTEGER NOT NULL,
     title TEXT NOT NULL,
     description TEXT,
     content TEXT,
     author TEXT,
     guid TEXT NOT NULL,
     link TEXT,
     publishDate TEXT NOT NULL,
     isRead INTEGER NOT NULL DEFAULT 0,
     isStarred INTEGER NOT NULL DEFAULT 0,
     categories TEXT,
     imageUrl TEXT,
     FOREIGN KEY(feedId) REFERENCES feeds(id) ON DELETE CASCADE,
     UNIQUE(feedId, guid)
   );
   
   CREATE TABLE settings(
     id INTEGER PRIMARY KEY CHECK (id = 1),
     settingsJson TEXT NOT NULL
   );
   
   CREATE TABLE categories(
     name TEXT PRIMARY KEY
   );
   
   INSERT INTO settings VALUES (1, '{"tickerWidth":800,"tickerHeight":100,"tickerPosition":1,"scrollDirection":1,"scrollSpeed":1.0,"opacity":0.8,"autoStart":true,"refreshIntervalMinutes":15,"feedCategories":[],"showImagesInTicker":true,"tickerBackgroundColor":4278190080,"textColor":4294967295}');
   ```

### 4. Application Crashes on Start

If the app crashes immediately after launch:

1. **Clear Temporary Files**
   - Delete the build directory: `flutter clean`
   - Delete the `.dart_tool` directory
   - Run `flutter pub get` to reinstall dependencies

2. **Check Flutter Version**
   - Make sure you have a compatible Flutter version: `flutter --version`
   - This app was built with Flutter 3.7+ and may not work with older versions

## Debugging Tips

1. **Enable Debug Logging**
   - The application uses a built-in logging system
   - All logs are printed to the console
   - Look for entries with `[ERROR]` to identify issues

2. **Run in Debug Mode**
   - Use `flutter run -d macos` instead of running the built app
   - This will show more detailed error information

3. **Check Database Contents**
   - Use a SQLite browser like DB Browser for SQLite to inspect the database
   - Verify that tables are created and data is being stored correctly

## Reporting Issues

If you continue to experience problems:

1. Check the terminal/console output for error messages
2. Gather the logs from the application
3. Create an issue with detailed reproduction steps and logs