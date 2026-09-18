const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;

// Inject a localStorage-backed window.storage mock so the admin dashboard
// records and reads WhatsApp click data during local development.
// On production (or in Claude's environment) this is skipped — the built-in
// Supabase / window.storage integration takes over.
const STORAGE_INJECTION = `
<script>
if (typeof window.storage === 'undefined') {
  window.storage = {
    async get(key) {
      const val = localStorage.getItem(key);
      return { value: val !== null ? val : undefined };
    },
    async set(key, value) {
      localStorage.setItem(key, value);
      return true;
    }
  };
}
</script>
`;

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js':  'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json':'application/json; charset=utf-8',
  '.ico': 'image/x-icon',
  '.jpg': 'image/jpeg',
  '.jpeg':'image/jpeg',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.woff':'font/woff',
  '.woff2':'font/woff2',
};

const server = http.createServer((req, res) => {
  const urlPath = new URL(req.url, 'http://localhost').pathname;
  const filePath = urlPath === '/'
    ? path.join(__dirname, 'natural-ulcer-cure-book-ad.html')
    : path.join(__dirname, urlPath);

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('Not Found');
      return;
    }
    const ext = path.extname(filePath);
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    let body = data;
    if (ext === '.html') {
      body = data.toString().replace('</body>', STORAGE_INJECTION + '</body>');
    }
    res.writeHead(200, { 'Content-Type': contentType });
    res.end(body);
  });
});

server.listen(PORT, () => {
  console.log(`✓ Local dev server running:  http://localhost:${PORT}`);
  console.log(`✓ Main site:                    http://localhost:${PORT}`);
  console.log(`✓ Admin dashboard:            http://localhost:${PORT}/#admin`);
  console.log(`  (passcode: gemsofinsight2026)`);
});
