const fs = require('fs');
const path = require('path');

function summarizeBody(content) {
  if (!content || !content.text) return 'N/A';
  if (content.mimeType.includes('json')) {
    try {
      const parsed = JSON.parse(content.text);
      const keys = Object.keys(parsed);
      return `JSON: { ${keys.slice(0, 5).join(', ')}${keys.length > 5 ? '...' : ''} }`;
    } catch (e) {
      return 'Malformed JSON';
    }
  }
  return content.mimeType;
}

function indexHar(filePath) {
  if (!fs.existsSync(filePath)) {
    console.error(`Error: File not found at ${filePath}`);
    process.exit(1);
  }

  const har = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  const entries = har.log.entries;

  console.log(`Index of ${path.basename(filePath)} (${entries.length} requests):`);
  console.log('ID | Method | Status | Content-Type | URL | Body Summary');
  console.log('---|--------|--------|--------------|-----|--------------');

  entries.forEach((entry, index) => {
    const url = new URL(entry.request.url);
    const mimeType = entry.response.content.mimeType || 'N/A';
    
    // Noise filtering
    const isNoise = /analytics|telemetry|google-analytics|hotjar|segment|pixel|favicon|font|image|css/i.test(entry.request.url) ||
                    /image\/|font\/|text\/css/.test(mimeType);

    if (isNoise) return;

    const bodySummary = summarizeBody(entry.response.content);
    console.log(`${index} | ${entry.request.method} | ${entry.response.status} | ${mimeType} | ${url.pathname}${url.search} | ${bodySummary}`);
  });
}

const harPath = process.argv[2];
if (!harPath) {
  console.error('Usage: node index_har.cjs <path_to_har_file>');
  process.exit(1);
}

indexHar(harPath);
