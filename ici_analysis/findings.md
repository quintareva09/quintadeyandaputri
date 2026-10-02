# @inainvienna against the Indonesia Image Index: content allocation findings

**Status: PROVISIONAL.** All labels come from an automated, caption-only classifier. They become citable only after the hand-coded validation (`output/validation_sample.csv` → `validation_kappa.R`) has been run and Cohen's kappa reported here.

**Corpus:** 1,000 grid posts, 14 Dec 2021 – 1 Oct 2026. 992 could be classified and 8 were uncodable.

## Three findings

1. **Most of the account's output gives the ICI's three dimensions no material.** 720 of 992 posts (73%) are coded D. Under every coding setting tested the figure stays between 57% and 81%. It is 67% (557 of 829) with the 163-post COVID-19 infographic series removed. → `charts/content_share_by_ici.png`

2. **Within the content that does address the ICI, the allocation is concentrated in Culture & Tourism.** Of 272 posts, A has 195 (72%), B 50 (18%) and C 27 (10%). A is the majority under every setting (65–75%).

3. **Governance & Safety, the dimension the DCM named as the image's weak side, has had no allocation since January 2025.** It has 0 of 117 posts under the headline coding and at most 3 of 117 under any setting. → `charts/content_share_over_time.png`

**What this means for the hypothesis:** it is **partly supported and needs reframing**.
- The concentration in A within ICI-relevant content is real and robust.
- B and C are small: B has 50 posts and C 27 across five years.
- But the larger pattern is not "too much A". Nearly three quarters of the output serves none of the three dimensions.

The account has **no governing content allocation** tied to the perception dimensions. Its output is dominated by the following sub-codes, plus 398 posts the classifier could not place in any sub-code (D6, see Method):

| Sub-code | Posts |
|---|---|
| Ceremonial / greetings (D5) | 77 |
| Protocol (D1) | 75 |
| Citizen services (D3) | 64 |
| Multilateral (D4) | 55 |
| Community (D2) | 51 |

Several of these are legitimate mandates of the mission. This finding concerns how the account's output is split across these functions, not whether any one of them should be there.

## Further results (each with its limit)

- **Sub-attributes are uneven.** A divides into visit 88 / culture 103 / plural & tolerant **4**. C divides into safe 5 / democratic 6 / regulations 16. Every C cell is under 10, so these are counts only, not shares.
- **Syndication.** 109 posts (11%) are reposts from other accounts. Reposts make up 9 of 27 C posts and 15 of 50 B posts, against 37 of 720 D posts. With these n, this is descriptive only.
- **Language.** Language was detected by matching each caption against short lists of common words, a method that has not been validated. Captions are Indonesian-only in 600 posts, English 177, German 45 and mixed 120. The account has **no language policy** for an Austrian audience. Whether Austrians are in fact the audience is not in the data.
- **Change over time.** A's yearly share rose: odds ratio 1.27 per year (95% CI 1.12–1.44), n = 190. D's fell: 0.81 (0.72–0.91). These are descriptive only and confounded on two counts:
  - the COVID series sits entirely in 2021–22;
  - yearly volume varied from 508 posts (2022) to 69 (2025).

  B (n = 50) and C (n = 27) show no trend whose CI excludes 1. Yearly cells under 10 are not read as shares.
- **The account's own latent structure (question 4).** TF-IDF on 996 captions, with k-means and Ward clustering, finds **no substantial structure**. The best mean silhouette is 0.13 (below 0.25 = none), and it rises slowly to the edge of the tested range (k = 2–15, so k = 15 was chosen by the stated max-silhouette rule). The WSS elbow is at k = 7, and k-means and Ward agree only moderately (ARI 0.42).

  Such structure as exists follows **repost status (Cramér's V 0.68), language (0.62) and format (0.44) more than ICI dimension (0.35)**. The ordering holds at k = 7, where language comes first and ICI last. The recognisable clusters are recurring series: COVID infographics, consular service, holiday greetings, immigration circulars, ASEAN/G20 reposts.

  In short, the account's content is organised around **source and language, not around perception dimensions**. V values across variables with different numbers of categories are only roughly comparable, and part of the language separation is built into bag-of-words methods. → `charts/k_selection.png`

- **Visual system (step 7).** Each post's dominant colour was measured from its cover image (n = 999; 1 image could not be downloaded). The dominant colours show **no recurring accent colour**:
  - Near-white, grey and near-black clusters cover 71% of posts.
  - Of 7 palette clusters (chosen by silhouette, 0.62), no coloured cluster covers more than 9%. The red cluster (#CA2D27) covers 3%.
  - Dispersion (mean ΔE from the account centroid) is 38.4 overall and 33.7–41.6 in every year. No year shows a tighter period that would suggest a specification was in force.

  In system terms, the grid shows **no governing colour specification**. Limits:
  - Dominant colour in photographs reflects the scene photographed, not a design decision.
  - Only the cover image of a carousel or video is measured.
  - There is no comparator account or brand norm, so ΔE values are a baseline for repeat measurement, not "high" or "low".

  → `charts/colour_strip.png`

## Method in brief

**Codebook.** `codebook.md` v1.0 was committed (328485a) before any data was seen. v1.1 fixes only mechanical word collisions in the keyword lists and adds an omitted rule (Rule 7, which sends multilateral posts to D4). Both are logged in Appendix B. v1.0 and v1.1 agree on 969 of 1,000 labels.

**Classifier.** A transparent keyword-dictionary classifier in Indonesian, English and German. A dimension needs at least 2 substantive keyword matches in the caption body (hashtags excluded). The per-post matched terms are kept in `output/labelled_posts.csv`.

**Sensitivity.** Results are re-run under each of these settings (`output/allocation_by_setting.csv`):

| Setting | What it changes |
|---|---|
| Threshold 1 | Lenient substance test (1 keyword match is enough) |
| Threshold 3 | Strict substance test (3 matches needed) |
| v1.0 | The frozen original rules |
| Own posts only | Removes 45 collaboration posts owned by other accounts |
| Without reposts | Removes 109 reposts from other accounts |
| Without COVID series | Removes the 163-post COVID infographic series |

**Intervals.** Wilson 95% intervals cover sampling only, not classification error.

**Validation.** The sample is 30 random posts, blind to the automated label, with an optional oversample of 20 auto-coded B/C posts. A random 30 is expected to contain only about 3 B or C posts, so it cannot check the scarce labels on its own.

## What this data cannot tell us

- **Whether the content changes anyone's perception.** There is no perception data linked to exposure. Content share and ICI scores, once supplied, sit side by side and are never correlated: three dimensions are three data points.
- **The perception side.** No survey responses have been supplied, so the slot in `charts/content_vs_perception.png` is empty.
  - When they arrive, 10–20 responses support **no inference**.
  - The sample is **self-selected at an Indonesian cultural event**, the audience most favourably disposed to dimension A. Every mean, and A's most of all, will be biased upward. The results are **indicative only**.
  - No ICI benchmark or national average was supplied, and none is used.
- **What drives engagement.** Likes and comments were not used. In observational data, engagement differences between content types are confounded with date, format, reposting, language and follower growth.
- **Who sees the account.** The scrape has no reach, impressions, saves or follower geography, so whether Austrians are reached at all is unknown. Instagram Insights from the account itself would be needed.
- **History before Dec 2021.** The scrape stopped at exactly 1,000 rows, which matches a scraper limit. Stories, deleted posts and highlights are not included.
- **Visual content beyond colour.** Classification reads captions only, so a post whose message is carried by the image is coded from its caption. The colour analysis measures dominant colour only: it cannot detect typography, templates, logo use or photo style, which a visual specification would also govern.
- **Why the allocation looks like this.** The data records what was published, not the instructions, resources or approvals behind it.
