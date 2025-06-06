import { Request, Response } from "express";
import { LeaderboardService } from "../../../application/services/leaderboard-service";

export class LeaderboardController {
  constructor(private leaderboardService: LeaderboardService) {}

  /**
   * @swagger
   * /api/leaderboard/{quizId}:
   *   get:
   *     summary: Get leaderboard for a specific quiz
   *     tags: [Leaderboard]
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - in: path
   *         name: quizId
   *         required: true
   *         schema:
   *           type: string
   *         description: ID of the quiz
   *     responses:
   *       200:
   *         description: Leaderboard data retrieved successfully
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 quizId:
   *                   type: string
   *                   example: quiz-123
   *                 scores:
   *                   type: array
   *                   items:
   *                     type: object
   *                     properties:
   *                       userId:
   *                         type: string
   *                         example: user-123
   *                       username:
   *                         type: string
   *                         example: john_doe
   *                       score:
   *                         type: number
   *                         example: 100
   *       401:
   *         description: Unauthorized - Invalid or missing token
   *       404:
   *         description: Quiz not found
   *       500:
   *         description: Server error
   *     x-websocket:
   *       description: |
   *         This endpoint has a corresponding WebSocket connection for real-time updates.
   *         Connect to `ws://localhost:3000/leaderboard/{quizId}` to receive live updates.
   *       events:
   *         - name: leaderboard_init
   *           description: Initial leaderboard data sent upon connection
   *           schema:
   *             type: object
   *             properties:
   *               type:
   *                 type: string
   *                 enum: [leaderboard_init]
   *               data:
   *                 $ref: '#/components/schemas/Leaderboard'
   *         - name: leaderboard_update
   *           description: Real-time leaderboard updates
   *           schema:
   *             type: object
   *             properties:
   *               type:
   *                 type: string
   *                 enum: [leaderboard_update]
   *               data:
   *                 $ref: '#/components/schemas/Leaderboard'
   */
  async getLeaderboard(req: Request, res: Response) {
    try {
      const { quizId } = req.params;
      const leaderboard = await this.leaderboardService.getLeaderboard(quizId);
      res.json(leaderboard);
    } catch (error) {
      console.error("Error getting leaderboard:", error);
      res.status(500).json({ error: "Failed to get leaderboard" });
    }
  }

  /**
   * @swagger
   * /api/leaderboard/mock/score-update:
   *   post:
   *     summary: Mock endpoint to simulate score updates
   *     tags: [Leaderboard]
   *     security:
   *       - bearerAuth: []
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - quizId
   *               - userId
   *               - score
   *             properties:
   *               quizId:
   *                 type: string
   *                 description: ID of the quiz
   *                 example: quiz-123
   *               userId:
   *                 type: string
   *                 description: ID of the user
   *                 example: user-123
   *               score:
   *                 type: number
   *                 description: New score for the user
   *                 example: 100
   *     responses:
   *       200:
   *         description: Score updated successfully
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 message:
   *                   type: string
   *                   example: Score updated successfully
   *       401:
   *         description: Unauthorized - Invalid or missing token
   *       400:
   *         description: Invalid request body
   *       500:
   *         description: Server error
   *     x-websocket:
   *       description: |
   *         This endpoint triggers a WebSocket broadcast to all connected clients
   *         for the specified quiz. Clients will receive a leaderboard_update event.
   */
  async mockScoreUpdate(req: Request, res: Response) {
    try {
      const { quizId, userId, score, username } = req.body;
      await this.leaderboardService.handleSubmitScore(
        quizId,
        userId,
        username,
        score
      );
      res.json({ message: "Score updated successfully" });
    } catch (error) {
      console.error("Error updating score:", error);
      res.status(500).json({ error: "Failed to update score" });
    }
  }
}
