import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/utils/logger.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;

  factory LocalDatabase() => _instance;

  LocalDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      AppLogger.info('Database initialized successfully');
      return _database!;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize database', e, stackTrace);
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      AppLogger.info('Initializing database...');
      final documentsDirectory = await getApplicationDocumentsDirectory();
      AppLogger.debug('Documents directory: ${documentsDirectory.path}');
      
      // Ensure directory exists
      final dbDirectory = Directory(documentsDirectory.path);
      if (!await dbDirectory.exists()) {
        await dbDirectory.create(recursive: true);
      }
      
      final path = join(documentsDirectory.path, 'snackr.db');
      AppLogger.debug('Database path: $path');
      
      // Use macOS native SQLite by setting options
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          AppLogger.info('Creating new database at version $version');
          await _createDb(db, version);
        },
        onOpen: (db) {
          AppLogger.info('Database opened successfully');
        },
        onConfigure: (db) async {
          AppLogger.debug('Configuring database...');
          // Enable foreign keys
          await db.execute('PRAGMA foreign_keys = ON');
        },
      );
      
      return db;
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _createDb(Database db, int version) async {
    try {
      AppLogger.info('Creating database tables');
      
      // Feeds table
      AppLogger.debug('Creating feeds table');
      await db.execute('''
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
        )
      ''');

      // Feed items table
      AppLogger.debug('Creating feed_items table');
      await db.execute('''
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
        )
      ''');

      // Settings table
      AppLogger.debug('Creating settings table');
      await db.execute('''
        CREATE TABLE settings(
          id INTEGER PRIMARY KEY CHECK (id = 1),
          settingsJson TEXT NOT NULL
        )
      ''');

      // Categories table
      AppLogger.debug('Creating categories table');
      await db.execute('''
        CREATE TABLE categories(
          name TEXT PRIMARY KEY
        )
      ''');
      
      // Insert default settings
      AppLogger.debug('Inserting default settings');
      await db.insert('settings', {
        'id': 1,
        'settingsJson': '{"tickerWidth":800,"tickerHeight":100,"tickerPosition":1,"scrollDirection":1,"scrollSpeed":1.0,"opacity":0.8,"autoStart":true,"refreshIntervalMinutes":15,"feedCategories":[],"showImagesInTicker":true,"tickerBackgroundColor":4278190080,"textColor":4294967295}'
      });
      
      AppLogger.info('Database creation successful');
    } catch (e, stackTrace) {
      AppLogger.error('Error creating database tables', e, stackTrace);
      rethrow;
    }
  }

  // Helper method to close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}