import swaggerJsdoc from "swagger-jsdoc";

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Leaderboard Service API",
      version: "1.0.0",
      description: `A real-time leaderboard service API documentation

## WebSocket Connection
The service provides real-time leaderboard updates via WebSocket. To connect:

\`\`\`javascript
const quizId = 'quiz-123';

const ws = new WebSocket(\`ws://localhost:3000/leaderboard/\${quizId}\`);

ws.onopen = () => {
  console.log('Connected to WebSocket server');
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  if (data.type === 'leaderboard_update') {
    console.log('Leaderboard updated:', data.data);
  }
};
\`\`\`

### WebSocket Message Types

1. Initial Leaderboard Data:
\`\`\`json
{
  "type": "leaderboard_init",
  "data": {
    "quizId": "quiz-123",
    "scores": [
      {
        "userId": "user-123",
        "username": "john_doe",
        "score": 100
      }
    ]
  }
}
\`\`\`

2. Leaderboard Update:
\`\`\`json
{
  "type": "leaderboard_update",
  "data": {
    "quizId": "quiz-123",
    "scores": [
      {
        "userId": "user-123",
        "username": "john_doe",
        "score": 150
      }
    ]
  }
}
\`\`\`

### WebSocket Connection Details

- **URL Format**: \`ws://localhost:3000/leaderboard/{quizId}\`
- **Path Parameters**:
  - \`quizId\` (required): The ID of the quiz to subscribe to
- **Connection Events**:
  - \`open\`: Connection established
  - \`message\`: Received leaderboard update
  - \`error\`: Connection error
  - \`close\`: Connection closed
- **Message Types**:
  - \`leaderboard_init\`: Initial leaderboard data
  - \`leaderboard_update\`: Real-time leaderboard updates`,
      contact: {
        name: "API Support",
        email: "support@example.com",
      },
    },
    servers: [
      {
        url: "http://localhost:3000",
        description: "Development server",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
    tags: [
      {
        name: "Leaderboard",
        description: "Leaderboard operations",
      },
      {
        name: "Health",
        description: "Health check operations",
      },
    ],
  },
  apis: [
    "./src/interfaces/http/controllers/*.ts ",
    "./src/interfaces/http/routes/*.ts",
  ], // Path to the API docs
};

export const swaggerSpec = swaggerJsdoc(options);
