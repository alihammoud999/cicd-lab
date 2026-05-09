const assert = require("assert");
const request = require("supertest");
const { createApp } = require("./server");

function fakeRedis() {
  const messages = [];
  let visits = 0;

  return {
    async ping() {
      return "PONG";
    },
    async incr(key) {
      assert.strictEqual(key, "visits");
      visits += 1;
      return visits;
    },
    async lrange(key) {
      assert.strictEqual(key, "messages");
      return messages;
    },
    async lpush(key, value) {
      assert.strictEqual(key, "messages");
      messages.unshift(value);
      return messages.length;
    },
    async ltrim() {
      return "OK";
    }
  };
}

describe("backend API unit tests", () => {
  it("returns health with pod name and Redis status", async () => {
    const response = await request(createApp(fakeRedis())).get("/api/health").expect(200);

    assert.strictEqual(response.body.status, "ok");
    assert.strictEqual(response.body.redis, "PONG");
    assert.ok(response.body.pod);
  });

  it("increments visits", async () => {
    const app = createApp(fakeRedis());

    const first = await request(app).get("/api/visits").expect(200);
    const second = await request(app).get("/api/visits").expect(200);

    assert.strictEqual(first.body.visits, 1);
    assert.strictEqual(second.body.visits, 2);
  });

  it("stores and returns messages", async () => {
    const app = createApp(fakeRedis());

    await request(app).post("/api/messages").send({ text: "hello" }).expect(201);
    const response = await request(app).get("/api/messages").expect(200);

    assert.strictEqual(response.body.messages.length, 1);
    assert.strictEqual(response.body.messages[0].text, "hello");
  });
});
