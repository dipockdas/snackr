import 'dart:convert';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/app_settings_model.dart';
import 'local_database.dart';

abstract class SettingsLocalDataSource {
  Future<AppSettingsModel> getSettings();
  Future<AppSettingsModel> saveSettings(AppSettingsModel settings);
  Future<AppSettingsModel> resetToDefaults();
  Future<List<String>> getCategories();
  Future<List<String>> addCategory(String category);
  Future<List<String>> deleteCategory(String category);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final LocalDatabase database;

  SettingsLocalDataSourceImpl({required this.database});

  @override
  Future<AppSettingsModel> getSettings() async {
    final db = await database.database;
    final settingsData = await db.query('settings');
    
    if (settingsData.isEmpty) {
      // No settings found, return default settings
      final defaultSettings = const AppSettingsModel();
      await saveSettings(defaultSettings);
      return defaultSettings;
    }
    
    final settingsJson = json.decode(settingsData.first['settingsJson'] as String);
    return AppSettingsModel.fromJson(settingsJson);
  }

  @override
  Future<AppSettingsModel> saveSettings(AppSettingsModel settings) async {
    final db = await database.database;
    final settingsJson = json.encode(settings.toJson());
    
    // Check if settings already exist
    final existingSettings = await db.query('settings');
    
    if (existingSettings.isEmpty) {
      // Insert new settings
      await db.insert(
        'settings',
        {'id': 1, 'settingsJson': settingsJson},
      );
    } else {
      // Update existing settings
      await db.update(
        'settings',
        {'settingsJson': settingsJson},
        where: 'id = 1',
      );
    }
    
    return settings;
  }

  @override
  Future<AppSettingsModel> resetToDefaults() async {
    final defaultSettings = const AppSettingsModel();
    return await saveSettings(defaultSettings);
  }

  @override
  Future<List<String>> getCategories() async {
    final db = await database.database;
    final categoriesData = await db.query('categories');
    return categoriesData.map((e) => e['name'] as String).toList();
  }

  @override
  Future<List<String>> addCategory(String category) async {
    final db = await database.database;
    
    await db.insert(
      'categories',
      {'name': category},
      conflictAlgorithm: sqflite.ConflictAlgorithm.ignore,
    );
    
    return await getCategories();
  }

  @override
  Future<List<String>> deleteCategory(String category) async {
    final db = await database.database;
    
    await db.delete(
      'categories',
      where: 'name = ?',
      whereArgs: [category],
    );
    
    return await getCategories();
  }
}