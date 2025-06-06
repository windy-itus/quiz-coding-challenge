# Leaderboard Service

A real-time leaderboard service built with Express.js, following Clean Code Architecture principles. The service handles leaderboard logic, subscribes to a Kafka topic, reads from Redis, and provides updates via WebSocket.

## Features

- Real-time leaderboard updates via WebSocket
- Redis caching for leaderboard data
- Kafka integration for score updates
- RESTful API endpoints
- Clean Code Architecture implementation

## Prerequisites

- Node.js (v14 or higher)
- Redis
- Kafka (not yet)
- npm or yarn

## Installation

1. Clone the repository:

```bash
git clone <repository-url>
cd leaderboard-service
```

2. Install dependencies:

```bash
npm install
```

3. Set up environment variables:

```bash
# Copy the example environment file
cp .env.example .env

# Edit the .env file with your configuration
```

## API Endpoints

### Leaderboard

#### Get Leaderboard

```http
GET /api/leaderboard/:quizId
```

Response:

```json
{
  "quizId": "quiz-123",
  "scores": [
    {
      "userId": "user-123",
      "username": "john_doe",
      "score": 100
    }
  ]
}
```

#### Mock Score Update (for testing)

```http
POST /api/leaderboard/mock/score-update
Content-Type: application/json

{
  "quizId": "quiz-123",
  "userId": "user-123",
  "username": "john_doe",
  "score": 100
}
```

## WebSocket Connection

The service provides real-time leaderboard updates via WebSocket. Here's how to connect and handle updates:

### Basic Connection

```javascript
const quizId = "quiz-123";

const ws = new WebSocket(`ws://localhost:3000/leaderboard/${quizId}`);

// Handle WebSocket events
ws.onopen = () => {
  console.log("Connected to WebSocket server");
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  if (data.type === "leaderboard_update") {
    console.log("Leaderboard updated:", data.data);
  }
};

ws.onerror = (error) => {
  console.error("WebSocket error:", error);
};

ws.onclose = () => {
  console.log("Disconnected from WebSocket server");
};
```

### Connection Details

- **URL Format**: `ws://localhost:3000/leaderboard/{quizId}`
- **Path Parameters**:
  - `quizId` (required): The ID of the quiz to subscribe to
- **Connection Events**:
  - `open`: Connection established
  - `message`: Received leaderboard update
  - `error`: Connection error
  - `close`: Connection closed

### Message Types

1. Initial Leaderboard Data:

```json
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
```

2. Leaderboard Update:

```json
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
```

### Complete Example with Error Handling

```javascript
class LeaderboardClient {
  constructor(quizId) {
    this.quizId = quizId;
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.reconnectDelay = 1000; // 1 second
  }

  connect() {
    this.ws = new WebSocket(`ws://localhost:3000/leaderboard/${this.quizId}`);

    this.ws.onopen = () => {
      console.log("Connected to WebSocket server");
      this.reconnectAttempts = 0;
    };

    this.ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        switch (data.type) {
          case "leaderboard_init":
            console.log("Initial leaderboard:", data.data);
            break;
          case "leaderboard_update":
            console.log("Leaderboard updated:", data.data);
            break;
          default:
            console.warn("Unknown message type:", data.type);
        }
      } catch (error) {
        console.error("Error parsing message:", error);
      }
    };

    this.ws.onerror = (error) => {
      console.error("WebSocket error:", error);
    };

    this.ws.onclose = () => {
      console.log("Disconnected from WebSocket server");
      this.attemptReconnect();
    };
  }

  attemptReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      console.log(
        `Attempting to reconnect (${this.reconnectAttempts}/${this.maxReconnectAttempts})...`
      );
      setTimeout(
        () => this.connect(),
        this.reconnectDelay * this.reconnectAttempts
      );
    } else {
      console.error("Max reconnection attempts reached");
    }
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
    }
  }
}

// Usage
const client = new LeaderboardClient("quiz-123");
client.connect();

// To disconnect
// client.disconnect();
```

## Project Structure

```
src/
├── application/           # Application layer
│   └── services/         # Business logic services
│       └── LeaderboardService.ts
│
├── config/               # Configuration
│   └── env.ts           # Environment variables
│
├── domain/              # Domain layer
│   └── entities/        # Domain entities
│       └── Leaderboard.ts
│
├── infrastructure/      # Infrastructure layer
│   ├── auth/           # Authentication
│   │   └── jwt-service.ts
│   ├── redis/          # Redis implementation
│   │   └── redis-leaderboard-repository.ts
│   ├── swagger/        # API documentation
│   │   └── swagger.ts
│   └── websocket/      # WebSocket server
│       └── websocket-server.ts
│
├── interfaces/          # Interface layer
│   ├── http/           # HTTP interfaces
│   │   ├── controllers/    # API controllers
│   │   │   ├── LeaderboardController.ts
│   │   │   └── AuthController.ts
│   │   ├── routes/         # API routes
│   │   │   ├── index.ts
│   │   │   └── leaderboard.routes.ts
│   │   └── middleware/     # HTTP middleware
│   └── middleware/     # Application middleware
│
└── index.ts            # Application entry point
```

The project follows Clean Architecture principles with the following layers:

1. **Domain Layer** (`src/domain/`)

   - Contains business entities and interfaces
   - Defines core business rules
   - Independent of other layers

2. **Application Layer** (`src/application/`)

   - Implements use cases
   - Orchestrates domain entities
   - Contains business logic services

3. **Infrastructure Layer** (`src/infrastructure/`)

   - Implements external services
   - Redis for caching
   - WebSocket for real-time updates
   - Authentication services
   - API documentation

4. **Interface Layer** (`src/interfaces/`)

   - HTTP controllers and routes
   - WebSocket handlers
   - Middleware components
   - API documentation setup

5. **Configuration** (`src/config/`)
   - Environment variables
   - Application configuration

## Running the Service

1. Start Redis and Kafka
2. Run the service:

```bash
npm start
```

## Development

```bash
# Run tests
npm test

# Run linter
npm run lint

# Run in development mode
npm run dev
```

## Error Handling

The service uses a centralized error handling system. All errors are properly formatted and include:

- HTTP status code
- Error message
- Error code (for client-side handling)
- Timestamp

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License.
