const fs = require('fs');
const path = require('path');

const SOURCE = path.join(__dirname, 'natural-ulcer-cure-book-ad.html');
const OUT_DIR = path.join(__dirname, 'dist');
const OUT_FILE = path.join(OUT_DIR, 'natural-ulcer-cure-book-ad.html');

let SUPABASE_URL = process.env.SUPABASE_URL || '';
let SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || '';

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  const envPath = path.join(__dirname, '.env');
  if (fs.existsSync(envPath)) {
    const envContent = fs.readFileSync(envPath, 'utf8');
    for (const line of envContent.split(/\r?\n/)) {
      const match = line.match(/^([A-Z_]+)\s*=\s*(.*)$/);
      if (match) {
        const key = match[1].trim();
        let val = match[2].trim();
        if (val.startsWith('"') && val.endsWith('"')) val = val.slice(1, -1);
        if (val.startsWith("'") && val.endsWith("'")) val = val.slice(1, -1);
        if (key === 'SUPABASE_URL' && !SUPABASE_URL) SUPABASE_URL = val;
        if (key === 'SUPABASE_ANON_KEY' && !SUPABASE_ANON_KEY) SUPABASE_ANON_KEY = val;
      }
    }
  }
}

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('Error: SUPABASE_URL and SUPABASE_ANON_KEY must be set in your environment.');
  console.error('       Copy .env.example to .env and fill in your Supabase credentials.');
  console.error('       Get them from: https://app.supabase.com/ → project → Settings → API');
  process.exit(1);
}

if (SUPABASE_URL.startsWith('YOUR_') || SUPABASE_ANON_KEY.startsWith('YOUR_')) {
  console.error('Error: Credentials look like placeholders. Update your .env with real Supabase values.');
  process.exit(1);
}

let html = fs.readFileSync(SOURCE, 'utf8');

html = html.replace('YOUR_SUPABASE_PROJECT_URL', SUPABASE_URL);
html = html.replace('YOUR_SUPABASE_ANON_KEY', SUPABASE_ANON_KEY);

if (!fs.existsSync(OUT_DIR)) {
  fs.mkdirSync(OUT_DIR, { recursive: true });
}

fs.writeFileSync(OUT_FILE, html);
console.log('Build complete: dist/natural-ulcer-cure-book-ad.html');
console.log(`  Supabase URL: ${SUPABASE_URL}`);
