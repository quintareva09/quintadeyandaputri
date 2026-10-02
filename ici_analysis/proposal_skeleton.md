# Proposal skeleton: a content and visual system for @inainvienna

> **Structure only, no finished copy.** Every recommendation names the finding that justifies it (F1–F3 = the three findings in `findings.md`; FR = its "Further results" section). Anything without data behind it is marked **[judgement call, not evidence]**. None of it is citable until the validation kappa has been run.

---

## 0. The problem, stated as system properties
- The account has **no governing content allocation** tied to the ICI dimensions. *(F1)*
- Its own content structure follows **source and language**, not perception dimensions. *(FR: clustering)*
- No content standard, brand guideline or KPI beyond engagement exists. *(user brief; nothing in the data contradicts it)*
- [Placeholder] The DCM's stated question, quoted as given: what would make Austrians interested, given an image that is high on tourism and culture and low on democracy and government. *(source: DCM statement; not a data finding)*

## 1. Purpose and audience
- 1.1 Primary audience: the Austrian public. **[judgement call, not evidence]** The scrape has no follower geography, so who the account currently reaches is unknown (`findings.md`, "What this data cannot tell us").
- 1.2 Secondary audience: Indonesian citizens in Austria and Slovenia, for service content. *(F1: D3 = 64 posts and the COVID series = 163 show that this function already exists)*
- 1.3 Objective: shift allocation toward the ICI dimensions where the image is reported to be weak (B, C). *(F2, F3 for the content side; the perception side rests on the DCM's statement, not on data here)*

## 2. Content pillars mapped to ICI dimensions
| Pillar | ICI attributes | Justified by | Target share |
|---|---|---|---|
| P-A Culture & Tourism | A1 visit, A2 culture, A3 plural & tolerant | F2: already 72% of ICI-relevant posts. FR: A3 has only 4 posts | [judgement call, not evidence] |
| P-B Economy & Business | B1 stable, B2 business, B3 products | F2: 50 posts in 5 years | [judgement call, not evidence] |
| P-C Governance & Safety | C1 safe, C2 democratic, C3 regulations | F3: 0 of 117 posts since Jan 2025 | [judgement call, not evidence] |
| Service channel (not a pillar) | D1–D5 | F1: 73% of output, much of it mandated | separated from the pillars; format to decide [judgement call, not evidence] |

- 2.1 Rule: every pillar post must pass the codebook's substance test (Rule 3: concrete information about Indonesia, not just a topic named). *(F1: most D posts have no ICI keyword in the body; method)*
- 2.2 Sub-attribute coverage targets, A3 and C2 in particular. *(FR: A3 = 4, C2 = 6; counts only)* Specific targets: [judgement call, not evidence]
- 2.3 Where pillar content comes from (original vs reposted). *(FR: 9 of 27 C posts and 15 of 50 B posts are reposts; descriptive only)* Sourcing model: [judgement call, not evidence]
- 2.4 How target shares will be set: placeholder until perception data from a non-event sample exists (§5.3). Until then they are explicitly [judgement call, not evidence].

## 3. Language policy
- 3.1 Language rule per pillar for an Austrian-facing audience. *(FR: German-only captions = 45 of 1,000 posts; the language detector is not validated)* Which languages, and in what order: [judgement call, not evidence]
- 3.2 Service-channel language: Indonesian. *(FR: consistent with the citizen audience)* [judgement call, not evidence]

## 4. Visual rules
- 4.1 **[Empty until the colour analysis runs.]** Whether a visual system exists now is **not established**: the colour strip, dispersion and palette clusters were not produced (`findings.md`). This section must not be filled before then.
- 4.2 Once it runs, pick one branch:
  - (a) If a recurrent palette cluster exists → codify it.
  - (b) If not → specify one.
  
  The palette, typography and templates themselves: [judgement call, not evidence]
- 4.3 One visual marker per pillar, so the allocation is visible on the grid. [judgement call, not evidence]

## 5. Measurement to replace "engagement and vibes"
- 5.1 **Allocation KPI (measurable now):** monthly share of posts per ICI pillar, coded with `codebook.md`. Re-run `analysis.R` on a fresh scrape. *(F1–F3; this is the instrument used here)*
- 5.2 **Coding reliability:** a quarterly hand-coded sample with Cohen's kappa reported, using `validation_kappa.R`. *(Method; every allocation figure depends on it)*
- 5.3 **Perception:** ICI items asked of a sample that is **not** recruited at Indonesian events. Report n and the method of recruitment every time. Any comparison with content is descriptive unless the design supports more. *(FR / "cannot tell us": the event sample is self-selected and favourable to A)* Sample design: [judgement call, not evidence]
- 5.4 **Reach of the intended audience:** share of followers and reach located in Austria, from Instagram Insights. *(The scrape has no audience data)*
- 5.5 **Engagement:** recorded as context, never used as the success criterion or to judge content types. *(Observational data are confounded; see "cannot tell us")*
- 5.6 **Visual consistency:** colour dispersion (ΔE) per quarter, tracked against the account's own baseline. No external benchmark exists. *(Step 7, once run)*

## 6. Cadence
- 6.1 Yearly volume has ranged from 508 to 69 posts. There is no stated cadence target. *(FR: yearly n)*
- 6.2 Posts per week, and the mix of pillar vs service posts per week: [judgement call, not evidence]. The data says nothing about the best frequency.

## 7. Governance of the system
- 7.1 The codebook becomes the planning tool: each planned post is tagged with its pillar before publication. [judgement call, not evidence]
- 7.2 Allocation review every quarter, using §5.1–5.2. [judgement call, not evidence]
- 7.3 Change log for the codebook, as in Appendix B. *(Method)*

## Open items before this skeleton becomes a proposal
- [ ] Hand-code the 30 random + 20 B/C validation posts; report kappa in `findings.md`.
- [ ] Run the colour analysis (image access needed before about 6 Oct 2026, 21:00 UTC, or re-scrape).
- [ ] Get Instagram Insights audience geography.
- [ ] Add the in-person ICI responses, labelled indicative only.
