import {
  Leaderboard,
  LeaderboardEntry,
  LeaderboardRepository,
} from "../../domain/entities/leaderboard";
import { WebSocketServer } from "../../infrastructure/websocket/websocket-server";

export class LeaderboardService {
  private broadcastTimeouts: Map<string, NodeJS.Timeout> = new Map();
  private readonly BROADCAST_TIMEOUT_MS = 200;

  constructor(
    private leaderboardRepository: LeaderboardRepository,
    private wsServer: WebSocketServer
  ) {}

  async getLeaderboard(quizId: string): Promise<Leaderboard | null> {
    return this.leaderboardRepository.getLeaderboard(quizId);
  }

  async updateLeaderboard(
    quizId: string,
    entry: LeaderboardEntry
  ): Promise<void> {
    await this.leaderboardRepository.updateLeaderboard(quizId, entry);
    await this.broadcastLeaderboardUpdate(quizId);
  }

  async broadcastLeaderboardUpdate(quizId: string) {
    // Consider using a queue to broadcast the updates to avoid websocket overloading
    const existingTimeout = this.broadcastTimeouts.get(quizId);
    if (existingTimeout) {
      return; // Skip broadcast if not enough time has passed
    }

    // Set a new timeout to broadcast the update
    const timeout = setTimeout(async () => {
      const updatedLeaderboard =
        await this.leaderboardRepository.getLeaderboard(quizId);

      if (updatedLeaderboard) {
        this.wsServer.broadcastLeaderboardUpdate(quizId, updatedLeaderboard);
      }
      this.broadcastTimeouts.delete(quizId);
    }, this.BROADCAST_TIMEOUT_MS);

    this.broadcastTimeouts.set(quizId, timeout);

    // const updatedLeaderboard = await this.leaderboardRepository.getLeaderboard(
    //   quizId
    // );
    // if (updatedLeaderboard) {
    //   this.wsServer.broadcastLeaderboardUpdate(quizId, updatedLeaderboard);
    // }
  }

  // Mock method to simulate receiving updates from Kafka
  async handleSubmitScore(
    quizId: string,
    userId: string,
    username: string,
    score: number
  ): Promise<void> {
    const entry: LeaderboardEntry = {
      userId,
      username,
      score, // This score will be added to the existing score
      rank: 0, // Will be calculated in the repository
    };

    await this.updateLeaderboard(quizId, entry);
  }
}
