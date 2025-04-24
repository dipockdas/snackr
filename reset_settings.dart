import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

// Run this script to reset the app settings to use the new default scroll speed
void main() async {
  print('Locating Snackr database...');
  
  // Find the documents directory
  final documentsPath = Platform.isWindows 
      ? Directory.current.path
      : '${Platform.environment['HOME']}/Library/Containers/com.snackr.snackrFlutter/Data/Documents';
  
  print('Documents directory: $documentsPath');
  
  // Open the database
  final dbPath = path.join(documentsPath, 'snackr.db');
  
  if (!File(dbPath).existsSync()) {
    print('Database not found at $dbPath');
    return;
  }
  
  print('Database found at $dbPath');
  
  final db = await openDatabase(dbPath);
  
  // Delete the settings
  print('Clearing settings table...');
  await db.delete('settings');
  
  print('Settings reset. Next time you start the app, it will use the new default scroll speed (0.2).');
  
  // Close the database
  await db.close();
  
  print('Done!');
}