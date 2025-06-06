import { Router } from "express";
import { createLeaderboardRouter } from "./leaderboard.routes";
import { LeaderboardController } from "../controllers/leaderboard-controller";

export function createRouter(
  leaderboardService: LeaderboardController
): Router {
  const router = Router();

  // Health check route

  /**
   * @swagger
   * /health:
   *   get:
   *     summary: Health check endpoint
   *     description: Returns the health status of the service.
   *     tags: [Health]
   *     responses:
   *       200:
   *         description: Service is healthy
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 status:
   *                   type: string
   *                   example: ok
   */
  router.use("/health", (req, res) => {
    res.json({ status: "ok" });
  });

  // Mount leaderboard routes
  router.use("/leaderboard", createLeaderboardRouter(leaderboardService));

  return router;
}
