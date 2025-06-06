import { createClient } from "redis";
import {
  Leaderboard,
  LeaderboardEntry,
  LeaderboardRepository,
} from "../../domain/entities/leaderboard";
import { env } from "../../config/env";

export class RedisLeaderboardRepository implements LeaderboardRepository {
  private client;

  constructor() {
    this.client = createClient({
      url: `redis://${env.REDIS.HOST}:${env.REDIS.PORT}`,
      password: env.REDIS.PASSWORD || undefined,
    });

    this.client.connect().catch(console.error);
  }

  async getLeaderboard(quizId: string): Promise<Leaderboard | null> {
    try {
      const key = `leaderboard:${quizId}`;
      const data = await this.client.get(key);

      if (!data) {
        return {
          quizId,
          scores: [],
          entries: [],
          lastUpdated: new Date(),
        };
      }

      return JSON.parse(data) as Leaderboard;
    } catch (error) {
      console.error("Error getting leaderboard:", error);
      return null;
    }
  }

  async updateLeaderboard(
    quizId: string,
    entry: LeaderboardEntry
  ): Promise<void> {
    try {
      const key = `leaderboard:${quizId}`;

      // Start a transaction
      const multi = this.client.multi();

      // Watch the key for changes
      await this.client.watch(key);

      // Get current leaderboard
      const data = await this.client.get(key);
      const leaderboard = data
        ? (JSON.parse(data) as Leaderboard)
        : {
            quizId,
            entries: [],
            lastUpdated: new Date(),
          };

      // Update or add entry
      const existingIndex = leaderboard.entries.findIndex(
        (e) => e.userId === entry.userId
      );
      if (existingIndex >= 0) {
        // Add the new score to the existing score
        leaderboard.entries[existingIndex].score += entry.score;
      } else {
        leaderboard.entries = [...leaderboard.entries, entry];
      }

      // Sort by score and update ranks
      leaderboard.entries.sort((a, b) => b.score - a.score);
      leaderboard.entries.forEach((entry, index) => {
        entry.rank = index + 1;
      });

      leaderboard.lastUpdated = new Date();

      // Set the updated leaderboard
      multi.set(key, JSON.stringify(leaderboard));

      // Execute the transaction
      const results = await multi.exec();

      // If results is null, it means the watched key was modified by another client
      if (results === null) {
        // Retry the operation
        return this.updateLeaderboard(quizId, entry);
      }
    } catch (error) {
      console.error("Error updating leaderboard:", error);
      throw error;
    }
  }
}
