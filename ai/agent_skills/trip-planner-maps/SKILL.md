---
name: trip-planner-maps
description: Turn travel workbooks or destination notes into an editable routed itinerary using the Google Maps MCP and web search. Use when a user has a spreadsheet, workbook, or city wish list and wants a day-by-day trip plan with grouping logic, travel-time-aware ordering, and explicit follow-up questions for missing logistics.
---

# Trip Planner With Maps

Use this skill when the user wants a practical itinerary from a workbook, spreadsheet, or rough destination list.

This skill is for planning, not just summarizing. You should:
- extract the workbook structure first
- identify what is fixed versus flexible
- use the Google Maps MCP for place lookup, geography, and travel times
- use web search for hours, closures, reservations, and official details when useful
- produce an editable Markdown itinerary with explicit reasoning

## Required Workflow

1. Parse the workbook with:

```bash
python3 scripts/extract_trip_workbook.py "/absolute/path/to/workbook.xlsx"
```

2. Read the extracted JSON before planning.
   - Use the `overview` section for dates, city order, and travel days.
   - Use `city_sheets` for candidate stops, notes, and duplicated city tabs.
   - Use `planning_signals.missing_inputs` to detect gaps that may require follow-up.

3. Determine whether you are blocked.
   - Ask the user only for information that materially changes routing.
   - Good reasons to ask:
     - lodging or hotel address for a city when first/last-mile travel matters
     - missing trip dates
     - missing arrival or departure times on intercity travel days
     - fixed bookings or must-do priorities not present in the workbook
   - Ask concise plain-text questions and keep the batch short.
   - If not blocked, proceed with explicit assumptions instead of stalling.

4. Use the Google Maps MCP.
   - Discover and use the available Google Maps MCP tools for:
     - place search
     - geocoding
     - directions or travel times
     - route sanity checks
   - Use the MCP to group stops into walkable or transit-friendly clusters.
   - Prefer minimizing backtracking over squeezing in every candidate stop.

5. Use web search when Maps data is not enough.
   - Search for:
     - official opening hours
     - reservation requirements
     - timed-entry rules
     - seasonal closures
     - restaurant or venue constraints
   - Prefer official or clearly reputable sources.
   - Distinguish verified facts from inference.

6. Build the itinerary.
   - Respect dates from the workbook and always present exact dates.
   - Treat intercity travel days as constrained days.
   - Group nearby stops together.
   - Put high-friction items earlier:
     - timed entry
     - popular museums
     - reservations
     - attractions with narrow hours
   - Put flexible items later:
     - scenic walks
     - neighborhoods
     - parks
     - optional overflow stops
   - Avoid unrealistic same-day zig-zagging across a city.
   - If a city tab has too many candidates, keep the strongest route and move the rest to alternates.

## Planning Rules

- Treat the workbook as the source of user intent, not the source of geographic truth.
- If multiple sheets refer to the same city, merge them into one candidate pool and note the merge.
- Preserve user priorities even when they are geographically inefficient, but say so clearly.
- If hotel data is missing, route days from a neutral city-center assumption and label that assumption.
- If dates are missing, stop and ask.
- If travel mode is unclear within a city, default to walking plus transit unless the workbook implies otherwise.
- If a same-day arrival is late or uncertain, keep the first day light.
- Do not invent opening hours, booking rules, or travel times.

## Output Contract

Unless the user explicitly asks for inline-only output, write an editable Markdown file next to the workbook:

- default output path: `<workbook dir>/<workbook stem>-trip-plan.md`

The itinerary must contain these sections:

1. `Trip Snapshot`
   - trip dates
   - city sequence
   - major travel days
   - planning assumptions

2. `Missing Inputs`
   - only include if something important is unknown
   - state whether you asked the user or proceeded with an assumption

3. `Day-by-Day Itinerary`
   - one subsection per date
   - use a Markdown table with these columns when possible:
     - Time Block
     - Stop / Area
     - Why This Fits Here
     - Transit From Previous Stop
     - Hours / Booking Notes
     - Notes

4. `Alternates and Overflow`
   - stops that did not fit cleanly
   - rainy-day swaps
   - lower-priority options

5. `Decision Log`
   - short bullets explaining route choices
   - explain grouping logic, not chain-of-thought
   - examples:
     - grouped Museum Island sites on the same day to avoid repeat transit across central Berlin
     - scheduled the castle first because of timed-entry risk and long uphill walk

6. `Open Questions`
   - only unresolved items that would improve the plan materially

7. `Sources`
   - short list of searched sources or note that routing relied primarily on Google Maps MCP plus workbook data

## Response Style

- Prefer compact, editable Markdown over prose-heavy travel writing.
- Be concrete.
- If you infer something, label it as an assumption.
- If you are missing a critical datum, say exactly why it matters.
- Include reasoning at the itinerary level and the day level, but do not expose hidden chain-of-thought.

## Example Invocation

- "Use this skill on `~/Downloads/europe 2026 to do.xlsx` and create a routed itinerary."
- "Use `$trip-planner-maps` to turn my workbook into an editable Markdown trip plan."

