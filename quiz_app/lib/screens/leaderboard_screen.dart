import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/leaderboard/leaderboard_bloc.dart';
import '../widgets/back_to_home_button.dart';
import '../constants/string_constants.dart';
import '../constants/style_constants.dart';

class LeaderboardScreen extends StatefulWidget {
  final String quizId;

  const LeaderboardScreen({super.key, required this.quizId});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeaderboardBloc>().add(ConnectToLeaderboard(widget.quizId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(StringConstants.leaderboardTitle)),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state.status == LeaderboardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == LeaderboardStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? StringConstants.somethingWentWrong, style: StyleConstants.errorStyle),
                  const SizedBox(height: StyleConstants.smallSpacing),
                  const BackToHomeButton(),
                ],
              ),
            );
          }

          if (state.status == LeaderboardStatus.connected && state.leaderboard != null) {
            if (state.leaderboard!.entries.isEmpty) {
              return const Center(child: Text(StringConstants.noEntriesYet));
            }

            return ListView.builder(
              itemCount: state.leaderboard!.entries.length,
              itemBuilder: (context, index) {
                final entry = state.leaderboard!.entries[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${entry.rank}')),
                  title: Text(entry.username),
                  trailing: Text('${entry.score} ${StringConstants.points}', style: StyleConstants.pointsStyle),
                );
              },
            );
          }

          return const Center(child: Text(StringConstants.waitingForData));
        },
      ),
    );
  }
}
