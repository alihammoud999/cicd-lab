const express = require("express");
const Redis = require("ioredis");

function now() {
  return new Date().toISOString();
}

function createRedisClient() {
  return new Redis({
    host: process.env.REDIS_HOST || "localhost",
    port: Number(process.env.REDIS_PORT || 6379),
    retryStrategy(times) {
      return Math.min(times * 100, 2000);
    }
  });
}

function createApp(redis = createRedisClient()) {
  const app = express();
  const podName = process.env.HOSTNAME || "local";

  app.use(express.json());

  function jsonError(res, error, status = 500) {
    res.status(status).json({
      status: "error",
      message: error.message,
      pod: podName,
      timestamp: now()
    });
  }

  app.get("/api/health", async (req, res) => {
    try {
      const pong = await redis.ping();
      res.json({
        status: "ok",
        redis: pong,
        pod: podName,
        timestamp: now()
      });
    } catch (error) {
      jsonError(res, error, 503);
    }
  });

  app.get("/api/visits", async (req, res) => {
    try {
      const visits = await redis.incr("visits");
      res.json({
        visits,
        pod: podName,
        timestamp: now()
      });
    } catch (error) {
      jsonError(res, error, 503);
    }
  });

  app.get("/api/messages", async (req, res) => {
    try {
      const rawMessages = await redis.lrange("messages", 0, 19);
      res.json({
        messages: rawMessages.map((message) => JSON.parse(message)),
        pod: podName,
        timestamp: now()
      });
    } catch (error) {
      jsonError(res, error, 503);
    }
  });

  app.post("/api/messages", async (req, res) => {
    const text = typeof req.body.text === "string" ? req.body.text.trim() : "";

    if (!text) {
      return res.status(400).json({
        status: "error",
        message: "Message text is required.",
        pod: podName,
        timestamp: now()
      });
    }

    try {
      const message = {
        text,
        pod: podName,
        timestamp: now()
      };

      await redis.lpush("messages", JSON.stringify(message));
      await redis.ltrim("messages", 0, 19);
      return res.status(201).json(message);
    } catch (error) {
      return jsonError(res, error, 503);
    }
  });

  return app;
}

if (require.main === module) {
  const port = process.env.PORT || 3000;
  createApp().listen(port, "0.0.0.0", () => {
    console.log(`Backend listening on 0.0.0.0:${port}`);
    console.log(`Redis host: ${process.env.REDIS_HOST || "localhost"}`);
  });
}

module.exports = {
  createApp
};
