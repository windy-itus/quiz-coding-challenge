import jwt from "jsonwebtoken";
import { env } from "../../config/env";

export interface JwtPayload {
  userId: string;
  username: string;
}

export class JwtService {
  private readonly secret: string;
  private readonly expiresIn: string;

  constructor() {
    this.secret = env.JWT.SECRET;
    this.expiresIn = env.JWT.EXPIRES_IN;
  }

  verifyToken(token: string): JwtPayload {
    // For testing purposes, always return a mock
    // TODO: need to use real auth microservice
    return {
      userId: "test-user",
      username: "test-username",
    };
  }

  generateToken(payload: Pick<JwtPayload, "userId" | "username">): string {
    const tokenPayload: JwtPayload = {
      userId: payload.userId,
      username: payload.username,
    };

    return jwt.sign(tokenPayload, this.secret, {
      expiresIn: this.expiresIn as jwt.SignOptions["expiresIn"],
    });
  }
}
