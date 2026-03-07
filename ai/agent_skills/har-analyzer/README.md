# HAR Analyzer Skill

This skill allows Gemini CLI to efficiently analyze large HAR (HTTP Archive) files by using a two-tiered retrieval system. It helps developers reverse-engineer web application data flows to understand how primary data is retrieved from backend services.

## Features

- **Tier 1 (Indexing)**: Scans the HAR file and provides a compact summary of relevant requests, filtering out noise like images, CSS, and analytics.
- **Tier 2 (Inspection)**: Enables targeted retrieval of full request/response details (headers, payloads, bodies) for specific requests.
- **Structured Analysis**: Follows a senior reverse-engineering workflow to map out authentication, session dependencies, and minimal reproduction steps.

## Directory Structure

```
har-analyzer/
├── SKILL.md             # Core instructions for Gemini CLI
├── scripts/
│   ├── index_har.cjs    # Tier 1: Indexes and triages the HAR file
│   └── inspect_request.cjs # Tier 2: Deep-dives into a specific request
└── assets/              # (Empty)
└── references/          # (Empty)
```

## How to Use

1.  **Install the Skill**:
    ```bash
    gemini skills install ./har-analyzer --scope workspace
    ```
2.  **Reload Skills**:
    In your interactive session, run:
    ```bash
    /skills reload
    ```
3.  **Trigger Analysis**:
    Ask Gemini to analyze a HAR file:
    > "Analyze the traffic in `./network_capture.har` and find out which API provides the user dashboard data."

## Security & Ethics

This tool is designed for **legitimate developer analysis** of traffic already captured. It should not be used to:
- Bypass authentication or anti-bot protections.
- Break encryption or exploit vulnerabilities.
- Access data without authorization.

Always use placeholders for sensitive credentials in generated code examples.
