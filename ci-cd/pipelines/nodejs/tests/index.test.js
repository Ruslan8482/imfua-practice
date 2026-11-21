"use strict";

const http = require("http");
const { createServer } = require("../src/index");

function request(server, options, body) {
  return new Promise((resolve, reject) => {
    const req = http.request({ port: server.address().port, ...options }, (res) => {
      let data = "";
      res.on("data", (chunk) => {
        data += chunk;
      });
      res.on("end", () => resolve({ status: res.statusCode, body: JSON.parse(data) }));
    });
    req.on("error", reject);
    if (body) {
      req.write(body);
    }
    req.end();
  });
}

describe("REST API", () => {
  let server;

  beforeAll((done) => {
    server = createServer().listen(0, done);
  });

  afterAll((done) => {
    server.close(done);
  });

  test("GET /health", async () => {
    const response = await request(server, { method: "GET", path: "/health" });
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: "ok" });
  });

  test("POST /echo", async () => {
    const response = await request(
      server,
      { method: "POST", path: "/echo", headers: { "Content-Type": "application/json" } },
      "{\"message\":\"hi\"}"
    );
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ echo: "{\"message\":\"hi\"}" });
  });

  test("unknown route", async () => {
    const response = await request(server, { method: "GET", path: "/unknown" });
    expect(response.status).toBe(404);
    expect(response.body).toEqual({ error: "not found" });
  });
});
