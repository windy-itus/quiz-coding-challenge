import express from "express";
import { createServer } from "http";
import { config } from "dotenv";
import { RedisLeaderboardRepository } from "./infrastructure/redis/redis-leaderboard-repository";
import { WebSocketServer } from "./infrastructure/websocket/websocket-server";
import { LeaderboardController } from "./interfaces/http/controllers/leaderboard-controller";
import { createRouter } from "./interfaces/http/routes";
import swaggerUi from "swagger-ui-express";
import { swaggerSpec } from "./infrastructure/swagger/swagger";
import { LeaderboardService } from "./application/services/leaderboard-service";

// Load environment variables
config();

const app = express();
const httpServer = createServer(app);

// Middleware
app.use(express.json());

// Initialize dependencies
// TODO: Consider using DI container
const redisLeaderboardRepository = new RedisLeaderboardRepository();
const wsServer = new WebSocketServer(httpServer, redisLeaderboardRepository);
const leaderboardService = new LeaderboardService(
  redisLeaderboardRepository,
  wsServer
);
const leaderboardController = new LeaderboardController(leaderboardService);

// Swagger documentation
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Routes
app.use("/api", createRouter(leaderboardController));

// Start server
const PORT = process.env.PORT || 3000;
httpServer.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(
    `Swagger documentation available at http://localhost:${PORT}/api-docs`
  );
});
