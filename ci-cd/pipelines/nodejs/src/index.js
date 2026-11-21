"use strict";

const http = require("http");

function sendJson(res, status, payload) {
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(JSON.stringify(payload));
}

function createServer() {
  return http.createServer((req, res) => {
    if (req.method === "GET" && req.url === "/health") {
      sendJson(res, 200, { status: "ok" });
      return;
    }

    if (req.method === "POST" && req.url === "/echo") {
      let body = "";
      req.on("data", (chunk) => {
        body += chunk;
      });
      req.on("end", () => sendJson(res, 200, { echo: body }));
      return;
    }

    sendJson(res, 404, { error: "not found" });
  });
}

function start(port = 3000) {
  return createServer().listen(port);
}

if (require.main === module) {
  const port = Number(process.env.PORT || 3000);
  start(port);
  console.log(`Server listening on ${port}`);
}

module.exports = { createServer, start };
