import express from "express";
import moment from "moment";
import Client from "pg";

import error from "./error/index.js";

const app = express();
const port = process.env.PORT || 1337;

app.get("/health", (_req, res) => {
  res.json({ status: "UP" });
});

app.use((_req, _res, _next) => {
  throw new error.ErrorHandler(404, "Not Found");
});

app.use((err, _req, res, _next) => {
  error.handleError(err, res);
});

app.listen(port, () => {
  const client = new Client.Client();
  client.connect();
  client.query("SELECT 1", (err, _res) => {
    if (err) throw err;
    console.log(
      `${moment().toISOString()} [INFO] Successfully connected to database.`
    );
    console.log(`${moment().toISOString()} [INFO] Started on port ${port}`);
    client.end();
  });
});
