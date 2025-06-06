import { Router } from "express";
import { LeaderboardController } from "../controllers/leaderboard-controller";

export const createLeaderboardRouter = (
  leaderboardController: LeaderboardController
): Router => {
  const router = Router();

  router.get("/:quizId", (req, res) =>
    leaderboardController.getLeaderboard(req, res)
  );
  router.post("/mock/score-update", (req, res) =>
    leaderboardController.mockScoreUpdate(req, res)
  );

  return router;
};
