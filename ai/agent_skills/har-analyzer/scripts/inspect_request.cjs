const fs = require('fs');

function inspectRequest(filePath, requestId) {
  if (!fs.existsSync(filePath)) {
    console.error(`Error: File not found at ${filePath}`);
    process.exit(1);
  }

  const har = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  const entry = har.log.entries[requestId];

  if (!entry) {
    console.error(`Error: Request ID ${requestId} not found.`);
    process.exit(1);
  }

  const result = {
    request: {
      method: entry.request.method,
      url: entry.request.url,
      headers: entry.request.headers,
      queryString: entry.request.queryString,
      postData: entry.request.postData
    },
    response: {
      status: entry.response.status,
      statusText: entry.response.statusText,
      headers: entry.response.headers,
      content: {
        mimeType: entry.response.content.mimeType,
        size: entry.response.content.size,
        text: entry.response.content.text
      }
    }
  };

  console.log(JSON.stringify(result, null, 2));
}

const harPath = process.argv[2];
const requestId = process.argv[3];

if (!harPath || requestId === undefined) {
  console.error('Usage: node inspect_request.cjs <path_to_har_file> <request_id>');
  process.exit(1);
}

inspectRequest(harPath, parseInt(requestId));
