export const env = {
  // Server
  PORT: process.env.PORT || 3000,
  NODE_ENV: process.env.NODE_ENV || "development",

  // Redis
  REDIS: {
    HOST: process.env.REDIS_HOST || "localhost",
    PORT: parseInt(process.env.REDIS_PORT || "6379", 10),
    PASSWORD: process.env.REDIS_PASSWORD || "",
  },

  // JWT
  JWT: {
    SECRET: process.env.JWT_SECRET || "your-secret-key",
    EXPIRES_IN: process.env.JWT_EXPIRES_IN || "24h",
  },

  // Rate Limiting
  RATE_LIMIT: {
    WINDOW_MS: parseInt(process.env.RATE_LIMIT_WINDOW_MS || "900000", 10), // 15 minutes
    MAX_REQUESTS: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || "100", 10),
  },
} as const;
