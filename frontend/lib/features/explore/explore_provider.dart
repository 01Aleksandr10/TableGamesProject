import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';

class ExploreState {
  final List<dynamic> meetups;
  final bool isLoading;
  final String? error;

  const ExploreState({
    this.meetups = const [],
    this.isLoading = false,
    this.error,
  });

  ExploreState copyWith({
    List<dynamic>? meetups,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ExploreState(
      meetups: meetups ?? this.meetups,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ExploreNotifier extends StateNotifier<ExploreState> {
  ExploreNotifier() : super(const ExploreState());

  Future<void> loadMeetups() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await ApiClient.dio.get('/meetups');
      state = ExploreState(meetups: List<dynamic>.from(res.data as List));
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['detail']?.toString() ?? 'Не удалось загрузить встречи',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось загрузить встречи',
      );
    }
  }
}
