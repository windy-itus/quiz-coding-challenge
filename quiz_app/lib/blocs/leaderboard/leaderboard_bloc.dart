import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:quiz_app/mappers/leaderboard_mapper.dart';
import 'package:quiz_app/socket/leaderboard_web_socket_client.dart';
import 'package:quiz_app/socket/web_socket_event.dart';
import '../../models/leaderboard.dart';
import '../../repositories/leaderboard/leaderboard_repository.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

// BLoC
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository _repository = GetIt.instance<LeaderboardRepository>();
  final LeaderboardWebSocketClient _wsClient = GetIt.instance<LeaderboardWebSocketClient>();
  late StreamSubscription<WebSocketEvent> _socketSubscription;

  LeaderboardBloc() : super(const LeaderboardState(status: LeaderboardStatus.initial)) {
    on<ConnectToLeaderboard>(_onConnectToLeaderboard);
    on<DisconnectFromLeaderboard>(_onDisconnectFromLeaderboard);

    _socketSubscription = _wsClient.broadcastMessageStream.listen((event) {
      add(LeaderboardSocketEventReceived(event));
    });
    on<LeaderboardSocketEventReceived>(_onLeaderboardSocketEventReceived);
  }

  void _onLeaderboardSocketEventReceived(LeaderboardSocketEventReceived event, Emitter<LeaderboardState> emit) {
    switch (event.event.type) {
      case WebSocketEventType.leaderboardUpdate:
        _onLeaderboardUpdated(event.event, emit);
        break;
      case WebSocketEventType.leaderboardInit:
        _onLeaderboardInitialized(event.event, emit);
        break;
    }
  }

  void _onLeaderboardUpdated(WebSocketEvent event, Emitter<LeaderboardState> emit) {
    final leaderboardUpdate = LeaderboardMapper.fromJsonUpdate(event.payload);
    if (leaderboardUpdate == null) {
      return;
    }

    final currentLeaderboard = state.leaderboard;
    if (currentLeaderboard == null) {
      return;
    }

    // Create a new list of entries
    final updatedEntries = List<LeaderboardEntry>.from(currentLeaderboard.entries);

    // Update existing entries and add new ones
    for (final entry in leaderboardUpdate.updated!) {
      final existingIndex = updatedEntries.indexWhere((e) => e.userId == entry.userId);
      if (existingIndex != -1) {
        updatedEntries[existingIndex] = entry;
      } else {
        updatedEntries.add(entry);
      }
    }

    // Remove entries that are no longer in the leaderboard
    if (leaderboardUpdate.removed != null && leaderboardUpdate.removed!.isNotEmpty) {
      updatedEntries.removeWhere((entry) => leaderboardUpdate.removed!.contains(entry.userId));
    }

    // Sort entries by score in descending order
    updatedEntries.sort((a, b) => b.score.compareTo(a.score));

    // Create new leaderboard instance
    final updatedLeaderboard = Leaderboard(
      quizId: currentLeaderboard.quizId,
      entries: updatedEntries,
      lastUpdated: leaderboardUpdate.timestamp,
    );

    emit(state.copyWith(status: LeaderboardStatus.connected, leaderboard: updatedLeaderboard));
  }

  void _onLeaderboardInitialized(WebSocketEvent event, Emitter<LeaderboardState> emit) {
    emit(state.copyWith(status: LeaderboardStatus.connected, leaderboard: LeaderboardMapper.fromJson(event.payload)));
  }

  void _onConnectToLeaderboard(ConnectToLeaderboard event, Emitter<LeaderboardState> emit) async {
    emit(state.copyWith(status: LeaderboardStatus.loading));
    try {
      await emit.forEach<Leaderboard>(
        _repository.connectToLeaderboard(event.quizId),
        onData: (leaderboard) => state.copyWith(
          status: LeaderboardStatus.connected,
          leaderboard: leaderboard,
        ),
        onError: (error, stackTrace) => state.copyWith(
          status: LeaderboardStatus.error,
          errorMessage: error.toString().contains('Failed to parse')
              ? 'Cannot retrieve leaderboard data. Please try again later.'
              : 'An error occurred. Please try again.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        status: LeaderboardStatus.error,
        errorMessage: 'Cannot retrieve leaderboard data. Please try again later.',
      ));
    }
  }

  void _onDisconnectFromLeaderboard(DisconnectFromLeaderboard event, Emitter<LeaderboardState> emit) {
    _repository.disconnect();
    emit(const LeaderboardState(status: LeaderboardStatus.initial));
  }

  @override
  Future<void> close() {
    _repository.disconnect();
    _socketSubscription.cancel();
    return super.close();
  }
}
