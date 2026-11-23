import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Track B: initialise Supabase here (before runApp) when it's connected.
  runApp(const ProviderScope(child: SnapSplitApp()));
}
