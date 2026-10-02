# ICI Content Codebook — @inainvienna

**Version 1.0 — frozen before any post was classified.**
Any later change to these rules is recorded in the change log at the bottom as v1.1, v1.2 and so on, with the reason. Results are then reported under both the frozen version and the revised one, so nobody can say the rules were tuned to get a result.

---

## 1. Purpose

This codebook assigns each Instagram post to one of the three perception dimensions of the Indonesia Image Index (ICI), or to a residual category:

| Code | Dimension | ICI attributes (survey wording) |
|---|---|---|
| **A** | Culture & Tourism | A1 interesting to visit · A2 rich and diverse culture · A3 plural and tolerant society |
| **B** | Economy & Business | B1 economically stable · B2 prospective place to do business · B3 good product quality |
| **C** | Governance & Safety | C1 safe · C2 democratic · C3 clear and easy-to-understand regulations |
| **D** | None of the three | Internal, protocol, ceremonial, community or service content |
| **U** | Uncodable | No caption text, and no visual coding available |

What gets measured is **which perception of Indonesia a post gives material to**, not the post's quality, reach or intent.

## 2. Unit of analysis and coder input

- **Unit:** one post (one row in the scraped file). A carousel counts as one post.
- **Coder input:** the caption text (and the visual, where a human coder can see it). The automated coder sees **captions only**. That limit is reported wherever the automated labels are used.
- **Language:** captions may be in Indonesian, English or German, or a mix. The rules apply in all three, and the dictionaries in Appendix A are trilingual.
- **Hashtags and @mentions** count as caption text, but **a hashtag on its own never meets the substance test (Rule 3)**.

## 3. Core rules (apply in order)

### Rule 1 — Single primary label
Every post gets exactly **one** primary code (A, B, C, D or U). A coder may also record **one** optional secondary code (A, B or C). Only the primary code goes into the allocation statistics.

### Rule 2 — The viewer test
Ask: *"After seeing this post, what would a foreign viewer with no prior connection to Indonesia have learned or felt about Indonesia as a country?"*
- If the answer maps to one of the nine ICI attributes, code the matching dimension (A, B or C).
- If the answer is about **the mission itself** (who it met, what it attended, who it greeted), or about Indonesian **citizens** as a service audience, code **D**.

### Rule 3 — The substance test (A, B and C need substance)
To get A, B or C, the caption must contain **at least one concrete piece of information about Indonesia** that bears on the attribute: a place, practice, art form, product, figure, policy, procedure, opportunity or event content. **Naming a topic is not substance.**

| Caption | Code | Why |
|---|---|---|
| "The Ambassador received the Austrian Chamber of Commerce delegation and discussed economic cooperation." | **D** (D1) | Names the topic only, gives no information about Indonesia's economy |
| "…discussed opportunities in Indonesia's EV-battery supply chain, where nickel downstreaming has attracted €X bn in investment." | **B** (B2) | Concrete business information |
| "#WonderfulIndonesia" plus a photo of the embassy reception hall | **D** | Hashtag only (see the note in Section 2) |
| "Join us for a gamelan workshop — the Javanese bronze ensemble tradition, inscribed by UNESCO in 2021" | **A** (A2) | Concrete cultural information |

### Rule 4 — Event content beats event format
When the mission hosts, attends or opens an event, code **what the event is about**, not the fact that the mission was there.
- Ambassador opens an Indonesian food festival → **A** (A2)
- Mission hosts a trade and investment forum → **B** (B2)
- Mission joins a reception with no stated content → **D** (D1)

### Rule 5 — Tie-break when two dimensions are present
1. Code the dimension in the **first two sentences** of the caption (the lead).
2. If the lead is also tied, code the dimension with **more substantive sentences** (Rule 3) in the whole caption.
3. If that is still tied, use the order **C > B > A**. This deliberately favours the scarcer dimensions so that a tie cannot inflate the dimension the hypothesis predicts will dominate. The direction is conservative against the hypothesis.

Record the losing dimension as the secondary code.

### Rule 6 — Audience rule for citizen-facing content
Content addressed to **Indonesian citizens as service users** is **D3**, even when its subject touches governance. Examples: passport services, overseas voting logistics for Indonesian voters in Austria, consular hours, reporting obligations.
Content that **explains** an Indonesian governance process **to a foreign audience** is **C**. Examples: how Indonesia's elections work, a new visa regime for Austrian visitors, investment rules.
> Test: *Who is the "you" of the post — an Indonesian passport holder or a foreigner?*

### Rule 7 — Multilateral content (PTRI Wina)
The mission also represents Indonesia at the Vienna-based UN and international bodies (e.g. IAEA, UNODC, UNIDO, CTBTO, OSCE). A post on Indonesia's position in a multilateral body is **D4**, **unless** it gives concrete information about a domestic ICI attribute, such as:
- Indonesia's national nuclear-safety regulator and regime → **C** (C1 or C3)
- domestic drug-law enforcement outcomes → **C** (C1)
- an Indonesian industrial-development programme presented with figures → **B** (B1 or B2)

D4 is kept as a separate sub-code so that multilateral content can be reported on its own. It would be wrong to count it as "absent".

## 4. Inclusion and exclusion rules by code

### A — Culture & Tourism
**Include**
- **A1 Visit:** named destinations, landscapes, travel information, tourism promotion, travel fairs, "visit Indonesia" calls, direct-flight or travel-route news.
- **A2 Culture:** arts (batik, gamelan, wayang, dance, film, music, literature), cuisine, language (BIPA classes), heritage sites, crafts **presented as culture**, cultural festivals, cultural diplomacy performances, Indonesian artists performing in Austria.
- **A3 Plural & tolerant:** religious or ethnic diversity **as the explicit subject**, interfaith dialogue, Bhinneka Tunggal Ika framing, coexistence stories.

**Exclude**
- Crafts or food presented as **export products or trade-fair goods** → **B3**.
- Religious-holiday greetings (Idulfitri, Christmas, Nyepi, Waisak) **with no pluralism framing** → **D5**. A greeting becomes **A3** only if it explicitly presents the diversity of Indonesia's observances as a feature of the country.
- Diaspora social gatherings with no cultural content shown or described → **D2**.

### B — Economy & Business
**Include**
- **B1 Stable:** growth, inflation, macro indicators, ratings, fiscal and monetary stability, economic resilience.
- **B2 Business:** investment opportunities, trade figures, business forums, B2B matchmaking, trade or investment agreements (e.g. IEU-CEPA), sector opportunities (nickel/EV, energy transition, digital, infrastructure, IKN), company partnerships, Austria–Indonesia trade.
- **B3 Products:** Indonesian products and brands **as goods** (coffee, spices, furniture, textiles, cocoa, palm-based products), export promotion, trade-fair booths, UMKM/SME showcases, product-quality claims or certifications.

**Exclude**
- A meeting with an economic actor that only names the topic (Rule 3) → **D1**.
- Food or coffee presented as heritage or experience → **A2**. Decide by framing: *what is being promoted — the tradition or the product?*

### C — Governance & Safety
**Include**
- **C1 Safe:** public safety, travel safety, security cooperation **with information about Indonesia**, disaster preparedness or response capacity, health-system safety.
- **C2 Democratic:** elections **explained to foreigners**, rule of law, institutions, human rights, press freedom, civil society, decentralisation, anti-corruption, parliament.
- **C3 Clear regulations:** visa policy (e-VoA, golden visa, visa exemptions) for foreign readers, investment or business licensing (OSS, Omnibus/Job Creation rules), customs or import rules, step-by-step procedures for foreigners.

**Exclude**
- Consular or administrative notices for Indonesian citizens → **D3** (Rule 6).
- Overseas-voting logistics for Indonesian voters → **D3** (Rule 6).
- Multilateral statements without domestic content → **D4** (Rule 7).
- Condolence messages after disasters → **D5**, unless the caption gives information about the response capacity (→ C1).

### D — None of the three (residual, sub-coded)
| Sub-code | Covers |
|---|---|
| **D1 Protocol** | Credentials, courtesy calls, bilateral meetings, receptions, visits by officials, MoU signings described only as an event |
| **D2 Community** | Diaspora gatherings, students' associations, sports days, community religious events, Dharma Wanita |
| **D3 Service** | Consular notices, citizen services, overseas-voting logistics, office closures, job vacancies |
| **D4 Multilateral** | Indonesia's positions or activities at Vienna-based international organisations without domestic ICI content |
| **D5 Ceremonial / greeting** | National-day ceremonies (17 Agustus flag ceremony), religious and national holiday greetings, commemorations, condolences, anniversaries |
| **D6 Other** | Anything not covered above, such as reposts with no caption content about Indonesia or giveaways with no subject |

### U — Uncodable
Use U only when the caption is empty, or has nothing but emoji, mentions or hashtags, **and** no visual coding is available. U posts are counted and reported but excluded from the share denominators. Their number is always stated.

## 5. Recording format

| Field | Values |
|---|---|
| `ici_primary` | A / B / C / D / U |
| `ici_sub` | A1–A3, B1–B3, C1–C3, D1–D6, U |
| `ici_secondary` | A / B / C / blank |
| `rule_applied` | the rule number that decided a non-obvious case (e.g. `R3`, `R5.1`, `R6`) |
| `coder` | `auto_v1.0` or the human coder's initials |

## 6. How the automated coder implements this codebook

The automated coder is a **transparent dictionary classifier**, not a model. A reader can trace every label back to the matched terms, which are stored in the output.

1. **U check:** after removing hashtags, mentions, URLs and emoji, fewer than 3 word tokens → U.
2. **Scoring:** count term matches per dimension (A, B, C) and per D sub-code, using the trilingual dictionaries in Appendix A. Matching is case-insensitive and on word stems.
3. **Substance proxy (Rule 3):** a dimension counts only if it has **≥ 2 matches** in the caption body, with hashtags excluded. One match is treated as a topic mention.
4. **Audience proxy (Rule 6):** if any D3 citizen-service term matches (e.g. *WNI*, *paspor*, *lapor diri*, *pemilu luar negeri*, *PPLN*), C matches are cancelled and the post goes to D3 — unless it also contains foreign-audience C3 terms such as *visa on arrival* or *e-visa*.
5. **Decision:** the dimension with the most qualifying matches wins. Ties are broken by the dimension matched first in the lead (the first 2 sentences), then by C > B > A (Rule 5). The runner-up, if it qualified, becomes the secondary code.
6. **Residual:** if no dimension qualifies → D. The D sub-code is the one with the most matches, and D6 is used if nothing matches.
7. **Audit trail:** every output row keeps `hits_A`, `hits_B`, `hits_C`, the matched terms and the rule that decided it.

**Known limits of the automated coder.** These are the reasons it has to be validated against a human coder (see `validation_sample.csv`):
- It cannot see images.
- It cannot fully apply the framing distinctions (A2 vs B3, greeting vs A3).
- The ≥ 2-match threshold is only a rough stand-in for Rule 3.

## Appendix A — Dictionaries v1.0 (stems; ID / EN / DE)

**A1 Visit:** wisata, pariwisata, destinasi, pantai, pulau, gunung, danau, liburan, wonderful indonesia, bali, lombok, labuan bajo, raja ampat, borobudur, toba, komodo, tourism, travel, destination, visit, island, beach, holiday, reise, urlaub, insel, strand, tourismus, reiseziel, ITB Berlin, ferien messe

**A2 Culture:** budaya, kebudayaan, seni, batik, gamelan, wayang, tari, tarian, angklung, kuliner, masakan, rendang, sate, tempe, kain, tenun, keris, pencak silat, BIPA, bahasa indonesia, musik, film, festival, pameran seni, warisan, UNESCO, culture, cultural, art, dance, music, cuisine, heritage, performance, workshop, kultur, kunst, tanz, musik, küche, kulturerbe, aufführung

**A3 Plural & tolerant:** keberagaman, kebhinekaan, bhinneka tunggal ika, toleransi, moderasi beragama, antarumat, lintas agama, interfaith, diversity, tolerance, pluralism, harmony, coexistence, vielfalt, toleranz, interreligiös, religiöse vielfalt

**B1 Stable:** pertumbuhan ekonomi, inflasi, PDB, stabilitas ekonomi, ekonomi indonesia, GDP, economic growth, inflation, economic stability, resilience, rating, wirtschaftswachstum, inflation, wirtschaftliche stabilität

**B2 Business:** investasi, investor, perdagangan, ekspor, impor, bisnis, peluang bisnis, forum bisnis, kerja sama ekonomi, CEPA, IEU-CEPA, hilirisasi, nikel, kendaraan listrik, IKN, BKPM, investment, trade, business, export, business forum, opportunity, market, supply chain, partnership, investition, handel, wirtschaft, geschäft, unternehmen, markt, wirtschaftskammer, WKO, ADA

**B3 Products:** produk, produk indonesia, UMKM, kopi, rempah, kakao, furnitur, mebel, tekstil, trade expo, pameran dagang, kualitas, product, products, coffee, spices, SME, brand, quality, made in indonesia, produkt, kaffee, gewürze, messe, qualität

**C1 Safe:** keamanan, aman, keselamatan, penanggulangan bencana, kontra terorisme, safety, safe, security, disaster response, preparedness, sicherheit, sicher, katastrophenschutz

**C2 Democratic:** demokrasi, pemilu, pemilihan umum, hak asasi manusia, HAM, supremasi hukum, kebebasan pers, masyarakat sipil, DPR, MK, antikorupsi, KPK, democracy, democratic, election, human rights, rule of law, press freedom, civil society, parliament, demokratie, wahl, menschenrechte, rechtsstaat, pressefreiheit, zivilgesellschaft

**C3 Clear regulations:** regulasi, peraturan, kebijakan visa, visa on arrival, e-VoA, e-visa, golden visa, bebas visa, perizinan, OSS, omnibus, cipta kerja, prosedur, persyaratan, regulation, policy, visa, licensing, procedure, requirements, how to apply, verordnung, visum, einreise, genehmigung, voraussetzungen, antrag

**D1 Protocol:** kunjungan kehormatan, courtesy call, credentials, surat kepercayaan, bertemu, pertemuan, menerima kunjungan, resepsi, jamuan, penandatanganan, received, met with, meeting, reception, visit of, delegation, besuch, empfang, treffen

**D2 Community:** diaspora, masyarakat indonesia, PPI, pelajar, mahasiswa, komunitas, warga, dharma wanita, DWP, pengajian, arisan, olahraga, lomba, community, students, gathering, gemeinschaft, studierende

**D3 Service:** WNI, paspor, SPLP, lapor diri, layanan konsuler, konsuler, PPLN, pemilu luar negeri, DPT, pemilih, jam pelayanan, libur kantor, lowongan, rekrutmen, passport, consular, citizens, office closed, vacancy, reisepass, konsularisch

**D4 Multilateral:** IAEA, UNODC, UNIDO, CTBTO, CTBTO PrepCom, OSCE, OPEC, UNOOSA, CND, CCPCJ, Board of Governors, General Conference, PTRI, permanent mission, statement, multilateral, United Nations, PBB, sidang, delegasi RI

**D5 Ceremonial / greeting:** HUT RI, upacara, bendera, proklamasi, kemerdekaan, selamat hari raya, idulfitri, idul adha, natal, nyepi, waisak, imlek, tahun baru, selamat, ucapan, duka cita, belasungkawa, peringatan, hari pahlawan, hari kartini, independence day, flag ceremony, greetings, condolences, commemoration, frohe, feiertag, beileid

*Note: on its own, "Festival" in A2 also catches non-cultural festivals. The ≥ 2-match threshold (Section 6, step 3) is what keeps such single matches from deciding a label.*

---

## Change log
| Version | Date | Change | Reason |
|---|---|---|---|
| 1.0 | 2026-10-02 | Initial frozen version, written before any data was seen | — |
