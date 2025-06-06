import express from "express";
import cors from "cors";
import helmet from "helmet";
import { rateLimiter } from "./rateLimiter";

export const setupMiddleware = (app: express.Application) => {
  // Security middleware
  app.use(cors());
  app.use(helmet());

  // Body parsing middleware
  app.use(express.json());

  // Rate limiting middleware
  app.use(rateLimiter);
};
