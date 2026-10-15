import { serve } from "bun";
import { join } from "path";

const PORT = 4040;
const DIR = "apps/quire/build/web";

serve({
  port: PORT,
  hostname: "0.0.0.0",
  async fetch(req) {
    const url = new URL(req.url);
    let pathname = decodeURIComponent(url.pathname);
    if (pathname === "/" || pathname === "") pathname = "/index.html";

    const filePath = join(DIR, pathname);
    const file = Bun.file(filePath);

    if (await file.exists()) {
      return new Response(file, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, HEAD, OPTIONS",
          "Cache-Control": "no-cache",
        },
      });
    }

    // Fallback to index.html for Flutter Web SPA routing
    return new Response(Bun.file(join(DIR, "index.html")), {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "text/html; charset=utf-8",
      },
    });
  },
});

console.log(`[Bun Web Server] Serving ${DIR} on http://localhost:${PORT}`);
