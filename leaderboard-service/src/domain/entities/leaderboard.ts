export interface LeaderboardEntry {
  userId: string;
  username: string;
  score: number;
  rank: number;
}

export interface Leaderboard {
  quizId: string;
  scores: Array<{
    userId: string;
    username: string;
    score: number;
  }>;
  entries: LeaderboardEntry[];
  lastUpdated: Date;
}

export interface LeaderboardRepository {
  getLeaderboard(quizId: string): Promise<Leaderboard | null>;
  updateLeaderboard(quizId: string, entry: LeaderboardEntry): Promise<void>;
}
