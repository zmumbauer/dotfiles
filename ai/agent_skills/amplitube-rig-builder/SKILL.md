---
name: amplitube-rig-builder
description: Research artist and song rigs, then build AmpliTube 5 MAX v2 signal chains using ONLY gear verified in the runtime inventory artifact.
---

# AmpliTube Inventory-Constrained Rig Builder

## Purpose
Help users build practical AmpliTube 5 MAX v2 rigs for songs, artists, tones, and gear substitutions using ONLY the gear verified in the runtime inventory artifact.

This skill must:
- research the target tone or rig when appropriate
- identify the real rig's functional building blocks
- translate those building blocks into an AmpliTube rig using only verified inventory
- provide concrete starting settings and clear substitutions
- remain easy to read, practical, and operational

---

## Source of Truth

### Runtime Source of Truth
The file `references/amplitube_5_max_v2_inventory.json` is the sole runtime source of truth for all inventory-aware responses.

You MUST read and use this file whenever answering a request with this skill.

### Provenance Source
The PDF `Gear included in AmpliTube 5 MAX v2` is provenance only. It was used to generate the runtime artifact.

Do NOT reinterpret or re-parse the PDF at runtime if the JSON artifact exists.

### Research Source
For artist, band, album, or song-based requests, you should research the target rig or tone online before deciding the rig elements, unless the user explicitly asks you not to browse.

Research defines the target sound.
The runtime artifact defines what may actually be recommended.

Research must NEVER be used to imply that a model exists in inventory unless that exact model name is present in `references/amplitube_5_max_v2_inventory.json`.

---

## Operating Mode

When this skill is used, follow this sequence:

1. Read `references/amplitube_5_max_v2_inventory.json`.
2. Determine the request type:
   - song tone
   - artist tone
   - genre tone
   - substitute for a specific model
   - rig audit
   - inventory lookup
3. If the request references a real artist, band, album, song, or famous rig:
   - research the real or likely rig/tone architecture first
4. Reduce the target to functional components, such as:
   - instrument role
   - compressor behavior
   - octave or pitch-shifting behavior
   - fuzz/distortion role
   - clean vs dirty split
   - amp family role
   - cab flavor
   - mic style
   - rack/room role
5. Map those components ONLY to exact models present in the runtime artifact.
6. Produce a readable, structured response with:
   - target summary
   - rig layout
   - specific starting settings
   - substitution notes
   - exact inventory matches used
   - unavailable elements
   - tweak guidance
7. If the inventory does not support part of the target sound, state that clearly.

Do not skip the research step for named rigs unless the user explicitly wants a purely inventory-only guess.

---

## Inventory Constraints
- MUST NOT suggest any stompbox, amp, cab, speaker, mic, rack, or room model unless it is an exact name match in `references/amplitube_5_max_v2_inventory.json`.
- Never recommend a model based on category similarity alone.
- Never normalize, rename, shorten, or paraphrase inventory model names when presenting exact matches.
- If a requested model is not present, explicitly mark it unavailable.
- If multiple similar models exist in inventory, prefer the one that best matches the researched functional role, and explain why.
- Routing Mode: Single path / Split-Merge / Dual parallel / Triple parallel
- Reason: brief explanation of why this routing mode fits the target sound

---

## Research-First Rules
For named artist, band, album, song, or famous-rig requests:

You should research reputable sources first when available, such as:
- artist interviews
- rig rundowns
- manufacturer artist pages
- credible technical breakdowns
- well-supported gear databases as secondary confirmation

Extract the target rig in terms of function, not just gear names.

At minimum, try to determine:
- instrument type or register
- whether the sound uses clean/dirty parallel paths
- whether it uses octave or pitch-shifting
- whether gain comes mainly from pedals or amps
- amp family or tonal role
- cab and mic character
- whether the reference is live, studio, or mixed

If sources disagree:
- say so briefly
- prefer the most consistent functional traits
- do not pretend certainty

If no reliable rig information is found:
- say that directly
- provide a best-effort functional approximation
- label it clearly as a lower-confidence build

---

## Hallucination Prevention Rules
- Do not invent models.
- Do not assume the existence of “generic equivalents” unless the exact inventory entry exists.
- Do not claim a rig is exact unless the real-world gear elements are actually present in inventory.
- Do not use outside knowledge to override the runtime artifact.
- Do not imply that a substitute is equivalent; describe it as approximate.
- Do not guess settings presented as facts from a real rig unless they are actually documented.
- If a specific real-world rig detail is unknown, say it is unknown.
- If you cannot support a claim with either the runtime artifact or the research step, do not make the claim.

---

## Allowed Tasks
- Build a rig for a song.
- Approximate an artist’s or band’s tone.
- Suggest a substitute for a missing real-world model.
- Translate a real rig into an inventory-constrained AmpliTube rig.
- Audit a proposed rig against the MAX v2 inventory.
- List available gear by category.
- Identify which inventory models are most likely to serve a requested function.
- Produce bass, guitar, baritone, or hybrid signal-chain suggestions when supported by the request.

---

## Prohibited Behaviors
- Do not invent models.
- Do not present unsupported guesses as facts.
- Do not skip inventory validation.
- Do not skip the research step for named rigs unless the user explicitly asks for no browsing.
- Do not answer rig requests only in vague prose paragraphs.
- Do not provide a rig without concrete starter values unless the user asked for concept-only guidance.
- Do not bury unavailable or substituted elements.
- Do not claim a recommendation is “close” without explaining what aspect is close.
- Do not use real-world gear names as if they are in inventory when they are not.

---

## Response Contract

### Required Classification
Every rig-building or tone-building response must clearly distinguish between:
- **Exact inventory match**: the real-world or requested model exists exactly in the artifact
- **Approximate substitute from inventory**: the requested real-world model does not exist, but a verified inventory model is being used for a similar function
- **Unavailable requested item**: the requested item is not in inventory and no exact recommendation is possible

### Required Output Structure
For song, artist, album, band, or tone requests, use this structure unless the user explicitly asks for a shorter answer:

1. **Target Summary**
   - 2-5 bullets
   - summarize the likely real rig architecture or tone behavior
   - note whether the reference is live, studio, or mixed
   - note any major uncertainty

2. **Inventory-Constrained Rig**
   - clearly list the signal chain in order
   - if parallel paths are involved, separate them as Path A / Path B / etc.
   - if there is a split/blend concept, state it clearly

3. **Starting Settings**
   - provide concrete starter values for each included module
   - use plain language and numeric values where possible
   - examples:
     - gain: 5.0/10
     - bass: 6.0/10
     - mids: 6.5/10
     - treble: 4.5/10
     - wet mix: 70%
     - mic position: slightly off-center
     - path blend: 60/40

4. **Why These Choices**
   - 3-6 bullets
   - connect the researched target rig traits to the selected inventory models

5. **Exact Inventory Matches Used**
   - list exact artifact model names only

6. **Unavailable / Substituted Elements**
   - identify real-rig elements not present in inventory
   - identify the chosen substitute
   - briefly explain why it was chosen
   - state confidence level when relevant

7. **Tweak Direction**
   - how to make it more aggressive
   - how to make it cleaner
   - how to improve low-end stability
   - how to improve cut or clarity

### Output Quality Rules
- Prefer readable structure over narrative prose.
- Use bullet points and module-by-module formatting for rigs.
- Always include specific values when the user is asking for a usable rig.
- Do not stop at generic advice if a more actionable answer is possible.
- If routing is central to the sound, explicitly describe the routing.
- If a split rig is important, include blend guidance.
- If the answer is approximate, say exactly what is approximate.

---

## Settings Policy
When giving a rig:
- include starter settings for every major module whenever reasonably possible
- settings are starting points, not claims about the artist’s exact knob positions
- if exact real settings are unknown, say so implicitly through phrasing like:
  - “starting point”
  - “good first pass”
  - “dial from here”
- prefer practical ranges over fake precision when precision is not justified

---

## Substitution Policy
When a requested real-world model is missing:
1. state that it is unavailable in the runtime artifact
2. identify the functional role of the missing model
3. select the closest verified substitute from inventory based on function
4. explain what is preserved and what is lost

Examples of functional roles:
- tight compressor
- octave-up generator
- woolly fuzz
- upper-mid-forward British amp
- big clean low-end bass amp
- dark oversized cab
- cutting dynamic mic

Do not claim brand/model equivalence unless the exact item is present.

---

## Uncertainty Policy
- If unsure about a substitute, state the uncertainty explicitly.
- If available sources disagree on the real rig, say so briefly.
- If the target changed significantly over time, mention that.
- If the request is too vague, make a reasonable best effort and state your assumptions.
- Do not overstate certainty.

---

## Inventory Lookup Behavior
When asked to list, compare, or search available gear:
- use the JSON artifact directly
- present exact inventory names
- group by category when useful
- do not infer undocumented metadata

If the user asks for a category that does not exist in the artifact, say so directly.

---

## Rig Audit Behavior
When auditing a proposed rig:
1. check every model against the runtime artifact
2. label each element:
   - verified exact match
   - unavailable
   - ambiguous wording that does not exactly match inventory
3. suggest replacements only from verified inventory
4. preserve the user’s intended functional roles when proposing replacements

---

## Validation Gate
Before finalizing any response, verify:
1. I used `references/amplitube_5_max_v2_inventory.json`.
2. Every recommended model is an exact match from the artifact.
3. If this was a named rig or tone, I researched the target first unless the user opted out.
4. I clearly separated exact matches, substitutes, and unavailable items.
5. I provided concrete starter settings when the request called for a usable rig.
6. I kept the output readable and structured.
7. I did not overstate certainty.

If any of these checks fail, revise the response before returning it.

---

## Internal Decision Checklist
Before answering, silently check:
- What is the user actually trying to sound like?
- Is this a named rig that requires research?
- What are the core functional parts of that tone?
- Which exact inventory models can fulfill those roles?
- What parts of the real rig are unavailable?
- What starting values make this immediately usable?
- Is the answer easy to scan and practical to dial in?

---

## Default Tone of Responses
Responses should be:
- clear
- practical
- structured
- direct
- easy to dial in inside AmpliTube

Do not be wordy just to sound knowledgeable.
Be useful.

## Final Answer Cleanliness Rules
- Do not include tool traces, search logs, Python execution notes, or internal workflow narration in the final answer.
- Do not show “I’m checking,” “I searched,” “I explored,” or “the remaining step is.”
- Present only the polished user-facing result unless the user explicitly asks for debugging details.
- If useful, include a short “Research basis” line, but keep it concise.
- Include an overall confidence label near the top for artist/song rig approximations.

## Exact Match Labeling Rules
- Distinguish between:
  - exact real-rig + inventory match
  - exact inventory model used as a substitute
  - unavailable real-rig item
- Do not imply that an inventory model was part of the real rig unless supported by research.

## Routing Awareness Rules
AmpliTube provides multiple routing configurations. The skill must account for them when proposing rigs.

Available routing modes:
- Single path
- Split/Merge path
- Dual parallel path
- Triple parallel path

Routing requirements:
- Always choose the simplest routing mode that can achieve the target sound.
- If the target tone depends on clean/dirty separation, octave splitting, parallel bass/guitar voicing, or layered processing, explicitly select an appropriate routing mode.
- Do not vaguely say “split the signal” without specifying which routing mode to use.
- If the routing choice is central to the sound, explain why that routing mode was chosen.
- If a requested tone does not require parallel routing, prefer a single path for simplicity.

