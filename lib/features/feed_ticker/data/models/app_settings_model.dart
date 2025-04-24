import 'dart:convert';

import 'package:flutter/material.dart';

import '../../domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    super.tickerWidth,
    super.tickerHeight,
    super.tickerPosition,
    super.scrollDirection,
    super.scrollSpeed,
    super.opacity,
    super.autoStart,
    super.refreshIntervalMinutes,
    super.feedCategories,
    super.showImagesInTicker,
    super.tickerBackgroundColor,
    super.textColor,
    super.infoReaderServiceUrl,
    super.infoReaderUsername,
    super.soundEnabled,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      tickerWidth: json['tickerWidth']?.toDouble() ?? 800,
      tickerHeight: json['tickerHeight']?.toDouble() ?? 100,
      tickerPosition: _parseTickerPosition(json['tickerPosition']),
      scrollDirection: _parseScrollDirection(json['scrollDirection']),
      scrollSpeed: json['scrollSpeed']?.toDouble() ?? 1.0,
      opacity: json['opacity']?.toDouble() ?? 0.8,
      autoStart: json['autoStart'] ?? true,
      refreshIntervalMinutes: json['refreshIntervalMinutes'] ?? 15,
      feedCategories: json['feedCategories'] != null
          ? List<String>.from(json['feedCategories'])
          : const [],
      showImagesInTicker: json['showImagesInTicker'] ?? true,
      tickerBackgroundColor: _parseColor(json['tickerBackgroundColor']) ?? Colors.black,
      textColor: _parseColor(json['textColor']) ?? Colors.white,
      infoReaderServiceUrl: json['infoReaderServiceUrl'],
      infoReaderUsername: json['infoReaderUsername'],
      soundEnabled: json['soundEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tickerWidth': tickerWidth,
      'tickerHeight': tickerHeight,
      'tickerPosition': tickerPosition.index,
      'scrollDirection': scrollDirection.index,
      'scrollSpeed': scrollSpeed,
      'opacity': opacity,
      'autoStart': autoStart,
      'refreshIntervalMinutes': refreshIntervalMinutes,
      'feedCategories': feedCategories,
      'showImagesInTicker': showImagesInTicker,
      'tickerBackgroundColor': tickerBackgroundColor.value,
      'textColor': textColor.value,
      'infoReaderServiceUrl': infoReaderServiceUrl,
      'infoReaderUsername': infoReaderUsername,
      'soundEnabled': soundEnabled,
    };
  }

  // Create an AppSettingsModel from a domain AppSettings entity
  factory AppSettingsModel.fromAppSettings(AppSettings settings) {
    return AppSettingsModel(
      tickerWidth: settings.tickerWidth,
      tickerHeight: settings.tickerHeight,
      tickerPosition: settings.tickerPosition,
      scrollDirection: settings.scrollDirection,
      scrollSpeed: settings.scrollSpeed,
      opacity: settings.opacity,
      autoStart: settings.autoStart,
      refreshIntervalMinutes: settings.refreshIntervalMinutes,
      feedCategories: settings.feedCategories,
      showImagesInTicker: settings.showImagesInTicker,
      tickerBackgroundColor: settings.tickerBackgroundColor,
      textColor: settings.textColor,
      infoReaderServiceUrl: settings.infoReaderServiceUrl,
      infoReaderUsername: settings.infoReaderUsername,
      soundEnabled: settings.soundEnabled,
    );
  }

  static TickerPosition _parseTickerPosition(dynamic value) {
    if (value is int && value >= 0 && value < TickerPosition.values.length) {
      return TickerPosition.values[value];
    }
    return TickerPosition.bottom;
  }

  static ScrollDirection _parseScrollDirection(dynamic value) {
    if (value is int && value >= 0 && value < ScrollDirection.values.length) {
      return ScrollDirection.values[value];
    }
    return ScrollDirection.rightToLeft;
  }

  static Color? _parseColor(dynamic value) {
    if (value is int) {
      return Color(value);
    }
    return null;
  }
}