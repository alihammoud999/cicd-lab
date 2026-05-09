const assert = require("assert");
const request = require("supertest");
const Redis = require("ioredis");
const { createApp } = require("./server");

describe("backend API Redis integration tests", () => {
  let redis;
  let app;

  before(async () => {
    redis = new Redis({
      host: process.env.REDIS_HOST || "localhost",
      port: Number(process.env.REDIS_PORT || 6379)
    });
    app = createApp(redis);
    await redis.del("visits", "messages");
  });

  after(async () => {
    await redis.quit();
  });

  it("pings Redis through the health endpoint", async () => {
    const response = await request(app).get("/api/health").expect(200);
    assert.strictEqual(response.body.redis, "PONG");
  });

  it("persists visits and messages in Redis", async () => {
    const visits = await request(app).get("/api/visits").expect(200);
    assert.strictEqual(visits.body.visits, 1);

    await request(app).post("/api/messages").send({ text: "integration" }).expect(201);
    const messages = await request(app).get("/api/messages").expect(200);

    assert.strictEqual(messages.body.messages[0].text, "integration");
  });
});
