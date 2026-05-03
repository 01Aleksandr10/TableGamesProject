import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_provider.dart';
import '../features/explore/explore_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

final exploreProvider = StateNotifierProvider<ExploreNotifier, ExploreState>(
  (ref) => ExploreNotifier(),
);
