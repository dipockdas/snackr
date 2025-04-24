import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// The position where the ticker will be docked
enum TickerPosition {
  top,
  bottom,
  left,
  right,
}

/// Direction of ticker scrolling
enum ScrollDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

/// Represents the application settings
class AppSettings extends Equatable {
  final double tickerWidth;
  final double tickerHeight;
  final TickerPosition tickerPosition;
  final ScrollDirection scrollDirection;
  final double scrollSpeed;
  final double opacity;
  final bool autoStart;
  final int refreshIntervalMinutes;
  final List<String> feedCategories;
  final bool showImagesInTicker;
  final Color tickerBackgroundColor;
  final Color textColor;
  final String? infoReaderServiceUrl;
  final String? infoReaderUsername;
  final bool soundEnabled;
  
  const AppSettings({
    this.tickerWidth = 800,
    this.tickerHeight = 100,
    this.tickerPosition = TickerPosition.bottom,
    this.scrollDirection = ScrollDirection.rightToLeft,
    this.scrollSpeed = 0.2, // Changed default from 1.0 to 0.2 to slow down the ticker
    this.opacity = 0.8,
    this.autoStart = true,
    this.refreshIntervalMinutes = 15,
    this.feedCategories = const [],
    this.showImagesInTicker = true,
    this.tickerBackgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.infoReaderServiceUrl,
    this.infoReaderUsername,
    this.soundEnabled = false,
  });

  AppSettings copyWith({
    double? tickerWidth,
    double? tickerHeight,
    TickerPosition? tickerPosition,
    ScrollDirection? scrollDirection,
    double? scrollSpeed,
    double? opacity,
    bool? autoStart,
    int? refreshIntervalMinutes,
    List<String>? feedCategories,
    bool? showImagesInTicker,
    Color? tickerBackgroundColor,
    Color? textColor,
    String? infoReaderServiceUrl,
    String? infoReaderUsername,
    bool? soundEnabled,
  }) {
    return AppSettings(
      tickerWidth: tickerWidth ?? this.tickerWidth,
      tickerHeight: tickerHeight ?? this.tickerHeight,
      tickerPosition: tickerPosition ?? this.tickerPosition,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      opacity: opacity ?? this.opacity,
      autoStart: autoStart ?? this.autoStart,
      refreshIntervalMinutes: refreshIntervalMinutes ?? this.refreshIntervalMinutes,
      feedCategories: feedCategories ?? this.feedCategories,
      showImagesInTicker: showImagesInTicker ?? this.showImagesInTicker,
      tickerBackgroundColor: tickerBackgroundColor ?? this.tickerBackgroundColor,
      textColor: textColor ?? this.textColor,
      infoReaderServiceUrl: infoReaderServiceUrl ?? this.infoReaderServiceUrl,
      infoReaderUsername: infoReaderUsername ?? this.infoReaderUsername,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  List<Object?> get props => [
        tickerWidth,
        tickerHeight,
        tickerPosition,
        scrollDirection,
        scrollSpeed,
        opacity,
        autoStart,
        refreshIntervalMinutes,
        feedCategories,
        showImagesInTicker,
        tickerBackgroundColor,
        textColor,
        infoReaderServiceUrl,
        infoReaderUsername,
        soundEnabled,
      ];
}