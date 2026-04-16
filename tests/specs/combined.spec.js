const { test, expect } = require("@playwright/test");
const fs = require("fs");
const path = require("path");

const NODE_API_URL = process.env.NODE_API_URL || "http://127.0.0.1:3000/api";
const PYTHON_API_URL = process.env.PYTHON_API_URL || "http://127.0.0.1:5000/api";
const NOVNC_URL = process.env.NOVNC_URL || "http://127.0.0.1:6080/vnc.html";
const PLAYWRIGHT_SHOT_DIR = path.resolve(__dirname, "../../test");

function ensureScreenshotDir() {
  fs.mkdirSync(PLAYWRIGHT_SHOT_DIR, { recursive: true });
}

async function saveShot(page, fileName) {
  ensureScreenshotDir();
  await page.screenshot({
    path: path.join(PLAYWRIGHT_SHOT_DIR, fileName),
    fullPage: true,
  });
}

test("noVNC page is reachable", async ({ page }) => {
  await page.goto(NOVNC_URL, { waitUntil: "domcontentloaded" });

  await expect(page).toHaveTitle(/noVNC/i);
  await expect(page.getByRole("button", { name: /connect/i })).toBeVisible();
  await saveShot(page, "playwright-novnc.png");
});

test("Node API is reachable", async ({ request, page }) => {
  const response = await request.get(NODE_API_URL);
  expect(response.ok()).toBeTruthy();

  const body = await response.json();
  expect(body).toMatchObject({
    status: "ok",
    service: "node",
  });

  await page.setContent(
    `<html><body><h1>Node API Test</h1><pre>${JSON.stringify(body, null, 2)}</pre></body></html>`,
    { waitUntil: "domcontentloaded" }
  );
  await saveShot(page, "playwright-node-api.png");
});

test("Python API is reachable", async ({ request, page }) => {
  const response = await request.get(PYTHON_API_URL);
  expect(response.ok()).toBeTruthy();

  const body = await response.json();
  expect(body).toMatchObject({
    status: "ok",
    service: "python",
  });

  await page.setContent(
    `<html><body><h1>Python API Test</h1><pre>${JSON.stringify(body, null, 2)}</pre></body></html>`,
    { waitUntil: "domcontentloaded" }
  );
  await saveShot(page, "playwright-python-api.png");
});
