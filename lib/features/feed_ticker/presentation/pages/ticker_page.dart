import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../widgets/simple_ticker_window.dart';

/// The main page that hosts the ticker
class TickerPage extends ConsumerWidget {
  const TickerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.info('Building TickerPage');
    
    // Using SimpleTickerWindow instead of TickerWindow to avoid window_manager issues
    return const SimpleTickerWindow();
  }
}