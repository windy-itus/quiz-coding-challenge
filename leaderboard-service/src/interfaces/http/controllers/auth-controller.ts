import { Request, Response } from "express";
import { JwtService } from "../../../infrastructure/auth/jwt-service";

export class AuthController {
  constructor(private jwtService: JwtService) {}

  /**
   * @swagger
   * /api/auth/token:
   *   post:
   *     summary: Generate JWT token for authentication
   *     tags: [Mock Authentication]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             type: object
   *             required:
   *               - userId
   *               - username
   *             properties:
   *               userId:
   *                 type: string
   *                 description: User's unique identifier
   *                 example: user-123
   *               username:
   *                 type: string
   *                 description: User's display name
   *                 example: john_doe
   *     responses:
   *       200:
   *         description: JWT token generated successfully
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 token:
   *                   type: string
   *                   description: JWT token
   *                   example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   *       400:
   *         description: Invalid request body
   *       500:
   *         description: Server error
   */
  async generateToken(req: Request, res: Response) {
    try {
      const { userId, username } = req.body;
      const token = this.jwtService.generateToken({ userId, username });
      res.json({ token });
    } catch (error) {
      console.error("Error generating token:", error);
      res.status(500).json({ error: "Failed to generate token" });
    }
  }
}
