import { Server as SocketIOServer, Socket } from "socket.io";
import { Server } from "http";
import {
  Leaderboard,
  LeaderboardEntry,
  LeaderboardRepository,
} from "../../domain/entities/leaderboard";
import { JwtService } from "../auth/jwt-service";

interface LeaderboardDelta {
  added: Array<{
    rank: number;
    userId: string;
    score: number;
    username: string;
  }>;
  updated: Array<{
    rank: number;
    userId: string;
    score: number;
    username: string;
  }>;
  removed: string[]; // userIds
  timestamp: number;
}

export class WebSocketServer {
  private io: SocketIOServer;
  private clients: Map<string, Set<string>> = new Map();
  private lastLeaderboardState: Map<
    string,
    Map<string, { rank: number; score: number }>
  > = new Map();
  private jwtService: JwtService;

  constructor(
    server: Server,
    private leaderboardRepository: LeaderboardRepository
  ) {
    this.jwtService = new JwtService();
    this.io = new SocketIOServer(server, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"],
      },
      transports: ["websocket", "polling"],
      path: "/socket.io/",
      allowEIO3: true,
    });

    // Create a namespace for leaderboard
    const leaderboardNamespace = this.io.of(/^\/leaderboard\/.+$/);

    leaderboardNamespace.on("connection", async (socket: Socket) => {
      try {
        // Verify JWT token
        const authHeader =
          socket.handshake.auth.token || socket.handshake.headers.authorization;
        if (!authHeader) {
          socket.emit("error", { status: 401, message: "No token provided" });
          socket.disconnect();
          return;
        }

        const token = authHeader.startsWith("Bearer ")
          ? authHeader.substring(7)
          : authHeader;

        try {
          const payload = this.jwtService.verifyToken(token);
          // Store user info in socket for later use
          socket.data.user = payload;
        } catch (error) {
          socket.emit("error", { status: 401, message: "Invalid token" });
          socket.disconnect();
          return;
        }

        const quizId = this.extractQuizId(socket.nsp.name);

        if (!quizId) {
          socket.emit("error", { status: 400, message: "Invalid quiz ID" });
          socket.disconnect();
          return;
        }

        this.subscribeToQuiz(socket.id, quizId);

        // Send initial leaderboard data
        try {
          const leaderboard = await this.leaderboardRepository.getLeaderboard(
            quizId
          );
          if (leaderboard) {
            // Store initial state
            this.updateLeaderboardState(quizId, leaderboard);
            socket.emit("leaderboard_init", leaderboard);
          }
        } catch (error) {
          console.error("Error sending initial leaderboard:", error);
        }

        socket.on("disconnect", () => {
          this.removeClient(socket.id);
        });
      } catch (error) {
        console.error("Error in connection handler:", error);
        socket.emit("error", { status: 500, message: "Internal server error" });
        socket.disconnect();
      }
    });
  }

  private updateLeaderboardState(quizId: string, leaderboard: Leaderboard) {
    const currentState = new Map<string, { rank: number; score: number }>();

    leaderboard.entries.forEach((entry: LeaderboardEntry) => {
      currentState.set(entry.userId, {
        rank: entry.rank,
        score: entry.score,
      });
    });

    this.lastLeaderboardState.set(quizId, currentState);
  }

  private calculateDelta(
    quizId: string,
    newLeaderboard: Leaderboard
  ): LeaderboardDelta {
    const lastState = this.lastLeaderboardState.get(quizId) || new Map();
    const currentState = new Map<string, { rank: number; score: number }>();
    const delta: LeaderboardDelta = {
      added: [],
      updated: [],
      removed: [],
      timestamp: Date.now(),
    };

    // Process new leaderboard
    newLeaderboard.entries.forEach((entry: LeaderboardEntry) => {
      currentState.set(entry.userId, { rank: entry.rank, score: entry.score });

      const lastEntry = lastState.get(entry.userId);
      if (!lastEntry) {
        // New entry
        delta.added.push({
          rank: entry.rank,
          userId: entry.userId,
          score: entry.score,
          username: entry.username,
        });
      } else if (
        lastEntry.rank !== entry.rank ||
        lastEntry.score !== entry.score
      ) {
        // Updated entry
        delta.updated.push({
          rank: entry.rank,
          userId: entry.userId,
          score: entry.score,
          username: entry.username,
        });
      }
    });

    // Find removed entries
    lastState.forEach((_, userId) => {
      if (!currentState.has(userId)) {
        delta.removed.push(userId);
      }
    });

    // Update the last state
    this.lastLeaderboardState.set(quizId, currentState);

    return delta;
  }

  private extractQuizId(namespace: string): string | null {
    const match = namespace.match(/^\/leaderboard\/(.+)$/);
    return match ? match[1] : null;
  }

  private subscribeToQuiz(socketId: string, quizId: string) {
    if (!this.clients.has(quizId)) {
      this.clients.set(quizId, new Set());
    }
    this.clients.get(quizId)?.add(socketId);
  }

  private removeClient(socketId: string) {
    this.clients.forEach((clients, quizId) => {
      if (clients.has(socketId)) {
        clients.delete(socketId);
        if (clients.size === 0) {
          this.clients.delete(quizId);
          this.lastLeaderboardState.delete(quizId);
        }
      }
    });
  }

  public broadcastLeaderboardUpdate(quizId: string, leaderboard: Leaderboard) {
    const clients = this.clients.get(quizId);
    if (clients) {
      const delta = this.calculateDelta(quizId, leaderboard);

      // Only broadcast if there are actual changes
      if (
        delta.added.length > 0 ||
        delta.updated.length > 0 ||
        delta.removed.length > 0
      ) {
        this.io.of(`/leaderboard/${quizId}`).emit("leaderboard_update", delta);
      }
    }
  }
}
