const pptxgen = require("pptxgenjs");
const { applyTheme } = require("/root/.claude/skills/synced/bde37891-3bef-4da4-b9bb-1bb9b29898f9_33615194-bc2a-4010-a576-7951822dbf9a/pptx/scripts/apply_theme.js");

const IMG = process.env.DECK_IMG || `${__dirname}/deck_images`;
const OUT = process.env.DECK_OUT || `${__dirname}/KBRI_Wina_Penataan_Konten_Instagram.pptx`;

const THEME = {
  name: "KBRI Wina Briefing",
  headFontFace: "Arial",
  bodyFontFace: "Arial",
  colors: {
    dk1: "1A1A1A", lt1: "FFFFFF", dk2: "1F3864", lt2: "F2F2F2",
    accent1: "1F3864", accent2: "6F8FBF", accent3: "C00000", accent4: "D9D9D9",
    accent5: "595959", accent6: "BFBFBF", hlink: "1F3864", folHlink: "595959",
  },
};
// Hex copies for options that only accept hex
const NAVY = "1F3864", MID = "6F8FBF", RED = "C00000", LIGHT = "D9D9D9", GREY = "595959", TINT = "F2F2F2";

const pres = new pptxgen();
pres.layout = "LAYOUT_WIDE"; // 13.33 x 7.5 in
pres.theme = { headFontFace: THEME.headFontFace, bodyFontFace: THEME.bodyFontFace };
pres.title = "Penataan Konten Instagram KBRI Wina";
pres.author = "Quinta Deyandaputri, Fungsi Pensosbud, KBRI/PTRI Wina";
const C = pres.SchemeColor;

pres.defineSlideMaster({
  title: "COVER",
  background: { color: "FFFFFF" },
  objects: [
    { placeholder: { options: { name: "title", type: "title", x: 0.9, y: 2.1, w: 11.5, h: 1.6,
        fontSize: 40, bold: true, color: C.text2, valign: "bottom", align: "left", margin: 0 }, text: "" } },
    { placeholder: { options: { name: "body", type: "body", x: 0.9, y: 3.85, w: 11.5, h: 0.8,
        fontSize: 24, color: C.text1, valign: "top", align: "left", margin: 0 }, text: "" } },
    { placeholder: { options: { name: "meta", type: "body", x: 0.9, y: 5.4, w: 11.5, h: 1.3,
        fontSize: 16, color: C.accent5, valign: "top", align: "left", margin: 0 }, text: "" } },
  ],
});
pres.defineSlideMaster({
  title: "CONTENT",
  background: { color: "FFFFFF" },
  objects: [
    { placeholder: { options: { name: "title", type: "title", x: 0.6, y: 0.35, w: 12.1, h: 1.0,
        fontSize: 28, bold: true, color: C.text2, valign: "middle", align: "left", margin: 0 }, text: "" } },
    { line: { x: 0.6, y: 6.9, w: 12.1, h: 0, line: { color: LIGHT, width: 0.75 } } },
    { text: { text: "KBRI/PTRI Wina  ·  Fungsi Pensosbud  ·  Bahan diskusi",
        options: { x: 0.6, y: 6.95, w: 9, h: 0.3, fontSize: 11, color: C.accent5, margin: 0 } } },
  ],
  slideNumber: { x: 12.1, y: 6.95, w: 0.6, h: 0.3, fontSize: 11, color: GREY, align: "right", margin: 0 },
});

const T = (o) => ({ margin: 0, isTextBox: true, color: C.text1, valign: "top", ...o });
const NOTE = (o) => T({ fontSize: 13, color: C.accent5, ...o });
const img = (s, id, x, y, size, alt) => s.addImage({ path: `${IMG}/${id}.jpg`, x, y, w: size, h: size, altText: alt });
const box = (s, x, y, w, h, fill = TINT) => s.addShape(pres.shapes.RECTANGLE, { x, y, w, h, fill: { color: fill }, line: { color: fill, width: 0 } });

const POST = {
  jatiluwih: "3366970197514874148", bipa: "3722323211842320460", iebf: "3202613031442937564",
  coffee: "3917855808738391129", voa: "3139557286447458314", golden: "3275759198489651045",
  paspor: "2976629670594870657",
};

// 1. Cover -----------------------------------------------------------------
let s = pres.addSlide({ masterName: "COVER" });
s.addText("Penataan Konten Instagram KBRI Wina", { placeholder: "title" });
s.addText("Usulan berdasarkan Indonesia Image Index (ICI)", { placeholder: "body" });
s.addText([
  { text: "Bahan diskusi  ·  Fungsi Pensosbud, KBRI/PTRI Wina", options: { breakLine: true } },
  { text: "Disusun oleh: Quinta Deyandaputri, Magang Fungsi Pensosbud", options: { breakLine: true } },
  { text: "Oktober 2026" },
], { placeholder: "meta" });

// 2. Background ------------------------------------------------------------
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Latar belakang", { placeholder: "title" });
box(s, 0.6, 1.6, 5.7, 4.0, NAVY);
s.addText("Pertanyaan pimpinan", T({ x: 0.95, y: 1.9, w: 5.0, h: 0.4, fontSize: 16, bold: true, color: "FFFFFF" }));
s.addText("“Bagaimana agar publik Austria melihat Indonesia lebih dari sekadar budaya dan pariwisata?”",
  T({ x: 0.95, y: 2.45, w: 5.0, h: 2.9, fontSize: 28, bold: true, color: "FFFFFF" }));
const ctx = [
  ["Unggahan makin terbatas", "Jumlah unggahan kini lebih sedikit dibanding tahun-tahun sebelumnya. Setiap unggahan makin bernilai."],
  ["Belum ada pedoman", "Pembagian unggahan belum diatur menurut gambaran Indonesia yang ingin dibangun."],
];
ctx.forEach(([h, d], i) => {
  const y = 1.6 + i * 2.05;
  s.addText(h, T({ x: 6.8, y, w: 5.9, h: 0.5, fontSize: 22, bold: true, color: C.text2 }));
  s.addText(d, T({ x: 6.8, y: y + 0.55, w: 5.9, h: 1.2, fontSize: 18 }));
});
s.addText([
  { text: "Pertanyaan kajian:  ", options: { bold: true } },
  { text: "dengan unggahan yang terbatas, gambaran Indonesia seperti apa yang ingin kita sampaikan kepada publik Austria?" },
], T({ x: 0.6, y: 5.85, w: 12.1, h: 0.8, fontSize: 18, valign: "middle" }));

// 3. Framework with an example post per category ---------------------------
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Acuan: tiga dimensi Indonesia Image Index (ICI) Kemlu", { placeholder: "title" });
const FR = [
  ["A. Budaya & Pariwisata", "Menarik dikunjungi · budaya kaya dan beragam · masyarakat majemuk dan toleran", POST.jatiluwih, false],
  ["B. Ekonomi & Bisnis", "Ekonomi stabil · prospektif untuk berbisnis · kualitas produk baik", POST.iebf, false],
  ["C. Tata Kelola & Keamanan", "Aman · demokratis · regulasi jelas dan mudah dipahami", POST.voa, false],
  ["D. Layanan & Protokol", "Di luar ICI: konsuler, protokol, peringatan hari besar, kegiatan masyarakat", POST.paspor, true],
];
FR.forEach(([name, desc, id, isD], i) => {
  const y = 1.5 + i * 1.2;
  if (i > 0) s.addShape(pres.shapes.LINE, { x: 0.6, y: y - 0.12, w: 12.1, h: 0, line: { color: LIGHT, width: 0.75 } });
  img(s, id, 0.6, y, 1.05, name);
  s.addText(name, T({ x: 1.95, y: y + 0.05, w: 4.2, h: 0.95, fontSize: 22, bold: true, color: isD ? C.accent5 : C.text2, valign: "middle" }));
  s.addText(desc, T({ x: 6.2, y: y + 0.05, w: 6.5, h: 0.95, fontSize: 18, color: isD ? C.accent5 : C.text1, valign: "middle" }));
});
s.addText("Kategori D tetap tugas resmi Perwakilan; dipisahkan agar pembagian konten terlihat.", NOTE({ x: 0.6, y: 6.45, w: 12.1, h: 0.35 }));

// 4. Current allocation ----------------------------------------------------
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Sebagian besar unggahan adalah konten layanan dan protokol", { placeholder: "title" });
s.addText("73%", T({ x: 0.6, y: 1.55, w: 4.6, h: 1.5, fontSize: 96, bold: true, color: C.text2, valign: "middle" }));
s.addText("unggahan termasuk kategori D: layanan dan protokol (720 dari 992)", T({ x: 0.6, y: 3.1, w: 4.4, h: 1.0, fontSize: 18 }));
s.addShape(pres.shapes.LINE, { x: 0.6, y: 4.3, w: 4.2, h: 0, line: { color: LIGHT, width: 0.75 } });
s.addText([
  { text: "Dari 272 unggahan yang membentuk citra, ", options: {} },
  { text: "72% tentang budaya dan pariwisata.", options: { bold: true } },
], T({ x: 0.6, y: 4.5, w: 4.4, h: 1.2, fontSize: 18 }));
s.addChart(pres.charts.BAR, [{
  name: "Persentase unggahan",
  labels: ["A. Budaya & Pariwisata", "B. Ekonomi & Bisnis", "C. Tata Kelola & Keamanan", "D. Layanan & Protokol"],
  values: [20, 5, 3, 73],
}], {
  x: 5.4, y: 1.5, w: 7.3, h: 4.6, barDir: "bar", catAxisOrientation: "maxMin",
  chartColors: [NAVY], barGapWidthPct: 45,
  showValue: true, dataLabelPosition: "outEnd", dataLabelFormatCode: '0"%"', dataLabelFontSize: 18, dataLabelColor: "1A1A1A",
  dataLabelFontFace: "+mn-lt", dataLabelFontBold: true,
  catAxisLabelFontSize: 16, catAxisLabelColor: "1A1A1A", catAxisLabelFontFace: "+mn-lt",
  catAxisLineShow: false, valAxisHidden: true, valAxisMaxVal: 90, valAxisMinVal: 0,
  valGridLine: { style: "none" }, catGridLine: { style: "none" }, showLegend: false,
});
s.addText("Sumber: 1.000 unggahan @inainvienna, Des 2021 – Okt 2026. Angka sementara sampai pemeriksaan manual selesai.",
  NOTE({ x: 0.6, y: 6.45, w: 12.1, h: 0.35 }));

// 5. Since Jan 2025: one square per post -----------------------------------
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Sejak Januari 2025, tidak ada unggahan tentang tata kelola dan keamanan", { placeholder: "title" });
const W5 = [["A", 35, NAVY], ["B", 10, MID], ["C", 0, RED], ["D", 72, LIGHT]];
const cells = W5.flatMap(([k, n, col]) => Array(n).fill(col));
const COLS = 13, SQ = 0.3, GAP = 0.07, X0 = 0.6, Y0 = 1.75;
cells.forEach((col, i) => {
  const r = Math.floor(i / COLS), c = i % COLS;
  s.addShape(pres.shapes.RECTANGLE, { x: X0 + c * (SQ + GAP), y: Y0 + r * (SQ + GAP), w: SQ, h: SQ,
    fill: { color: col }, line: { color: col, width: 0 } });
});
s.addText("1 kotak = 1 unggahan  ·  117 unggahan, Jan 2025 – Okt 2026", NOTE({ x: 0.6, y: 5.2, w: 4.8, h: 0.35 }));
const LEG = [
  ["A. Budaya & Pariwisata", "35", NAVY, C.text1],
  ["B. Ekonomi & Bisnis", "10", MID, C.text1],
  ["C. Tata Kelola & Keamanan", "0", RED, C.accent3],
  ["D. Layanan & Protokol", "72", LIGHT, C.text1],
];
LEG.forEach(([name, n, col, tc], i) => {
  const y = 1.75 + i * 0.85;
  s.addShape(pres.shapes.RECTANGLE, { x: 6.0, y: y + 0.12, w: 0.35, h: 0.35, fill: { color: col }, line: { color: col, width: 0 } });
  s.addText(n, T({ x: 6.55, y, w: 1.0, h: 0.6, fontSize: 30, bold: true, color: tc, valign: "middle" }));
  s.addText(name, T({ x: 7.6, y, w: 5.1, h: 0.6, fontSize: 20, color: tc, valign: "middle", bold: i === 2 }));
});
s.addText("Padahal dimensi inilah yang dinilai masih lemah dalam citra Indonesia. KBRI pernah membuat konten jenis ini, misalnya penjelasan Visa on Arrival (2023) dan Golden Visa (2024).",
  T({ x: 6.0, y: 5.25, w: 6.7, h: 1.1, fontSize: 16, color: C.accent5 }));

// 6. Proposal: two streams ---------------------------------------------------
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Usulan: memisahkan konten citra dan konten layanan", { placeholder: "title" });
const ST = [
  ["Konten citra", POST.jatiluwih, [["Tujuan", "Membentuk gambaran publik Austria tentang Indonesia"], ["Isi", "Kategori A, B, dan C"], ["Bahasa", "Jerman dan/atau Inggris (usulan)"], ["Pengaturan", "Proporsi A, B, C ditetapkan pimpinan"]]],
  ["Konten layanan", POST.paspor, [["Tujuan", "Memberi informasi dan melayani WNI serta mitra"], ["Isi", "Konsuler, protokol, peringatan, kegiatan masyarakat"], ["Bahasa", "Bahasa Indonesia"], ["Pengaturan", "Sesuai kebutuhan"]]],
];
ST.forEach(([head, id, rows], i) => {
  const x = 0.6 + i * 6.2;
  box(s, x, 1.5, 5.9, 4.85);
  img(s, id, x + 0.3, 1.8, 1.5, head);
  s.addText(head, T({ x: x + 2.05, y: 1.8, w: 3.6, h: 1.5, fontSize: 28, bold: true, color: C.text2, valign: "middle" }));
  rows.forEach(([k, v], j) => {
    const y = 3.6 + j * 0.65;
    s.addText(k, T({ x: x + 0.3, y, w: 1.5, h: 0.6, fontSize: 16, bold: true, color: C.accent5 }));
    s.addText(v, T({ x: x + 1.85, y, w: 3.85, h: 0.6, fontSize: 16 }));
  });
});
s.addText("Konten layanan tetap tugas resmi Perwakilan. Bentuk penyajiannya (misalnya melalui Stories) dibahas bersama pengelola akun.",
  NOTE({ x: 0.6, y: 6.45, w: 12.1, h: 0.35 }));

// 7. Examples from the account ---------------------------------------------
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("KBRI sudah pernah membuat konten untuk ketiga dimensi", { placeholder: "title" });
const EX = [
  { cat: "A. Budaya & Pariwisata", dev: "Kisah keberagaman dan toleransi (baru 4 unggahan)", items: [
    [POST.jatiluwih, "Jatiluwih, Bali (2024)"], [POST.bipa, "Kelas Bahasa Indonesia, berbahasa Jerman (2025)"] ] },
  { cat: "B. Ekonomi & Bisnis", dev: "Data singkat ekonomi Indonesia secara berkala", items: [
    [POST.iebf, "Indonesia–Europe Business Forum (2023)"], [POST.coffee, "Indonesia Coffee & Culture (2026)"] ] },
  { cat: "C. Tata Kelola & Keamanan", dev: "Penjelasan pemilu dan sistem pemerintahan untuk publik asing", items: [
    [POST.voa, "Visa on Arrival (2023)"], [POST.golden, "Golden Visa, izin tinggal 10 tahun (2024)"] ] },
];
EX.forEach((g, ci) => {
  const x = 0.6 + ci * 4.15;
  s.addText(g.cat, T({ x, y: 1.4, w: 3.9, h: 0.4, fontSize: 18, bold: true, color: C.text2 }));
  g.items.forEach(([id, cap], ri) => {
    const xi = x + ri * 1.95;
    img(s, id, xi, 1.9, 1.85, cap);
    s.addText(cap, T({ x: xi, y: 3.85, w: 1.85, h: 0.9, fontSize: 13 }));
  });
  box(s, x, 4.85, 3.85, 1.45);
  s.addText([
    { text: "Dapat dikembangkan:", options: { bold: true, breakLine: true } },
    { text: g.dev },
  ], T({ x: x + 0.15, y: 4.95, w: 3.55, h: 1.3, fontSize: 15 }));
});
s.addText("Sumber gambar: akun Instagram @inainvienna. Usulan pengembangan untuk didiskusikan, bukan hasil kajian.",
  NOTE({ x: 0.6, y: 6.45, w: 12.1, h: 0.35 }));

// 8. Indicators ------------------------------------------------------------
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Ukuran keberhasilan: bukan hanya jumlah suka", { placeholder: "title" });
const IND = [
  ["Proporsi konten", "Persentase unggahan per kategori dibanding target", "Bulanan", NAVY],
  ["Jangkauan", "Persentase pengikut dan jangkauan dari Austria (Instagram Insights)", "Bulanan", NAVY],
  ["Persepsi", "Pertanyaan ICI kepada responden Austria di luar acara KBRI", "Tahunan", NAVY],
  ["Respons", "Suka, komentar, simpan: pelengkap, bukan ukuran utama", "Bulanan", GREY],
];
IND.forEach(([h, d, f, col], i) => {
  const x = 0.6 + i * 3.08;
  box(s, x, 1.55, 2.9, 4.1);
  s.addShape(pres.shapes.RECTANGLE, { x, y: 1.55, w: 2.9, h: 0.9, fill: { color: col }, line: { color: col, width: 0 } });
  s.addText(h, T({ x: x + 0.2, y: 1.55, w: 2.5, h: 0.9, fontSize: 22, bold: true, color: "FFFFFF", valign: "middle" }));
  s.addText(d, T({ x: x + 0.2, y: 2.7, w: 2.5, h: 2.2, fontSize: 17 }));
  s.addText(f, T({ x: x + 0.2, y: 5.05, w: 2.5, h: 0.4, fontSize: 15, bold: true, color: C.accent5 }));
});
s.addText("Indikator ini menunjukkan apakah rencana berjalan dan apakah publik Austria terjangkau. Indikator ini tidak dapat membuktikan bahwa Instagram mengubah persepsi.",
  NOTE({ x: 0.6, y: 5.9, w: 12.1, h: 0.7, fontSize: 15 }));

// 9. Timeline --------------------------------------------------------------
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Langkah tiga bulan pertama", { placeholder: "title" });
const TL = [
  ["Bulan 1", "Persiapan", [["Pemeriksaan manual 50 unggahan", "Pengelola akun, dibantu magang"], ["Data asal pengikut (Instagram Insights)", "Pengelola akun"], ["Penetapan proporsi awal A, B, C", "Pimpinan"]]],
  ["Bulan 2–3", "Uji coba", [["Setiap unggahan diberi kategori sebelum terbit", "Pengelola akun"], ["Laporan bulanan pembagian konten", "Pengelola akun, dibantu magang"]]],
  ["Akhir bulan 3", "Evaluasi", [["Tinjauan hasil uji coba", "Pimpinan dan Fungsi Pensosbud"], ["Penyesuaian target dan pedoman", "Pimpinan"]]],
];
TL.forEach(([when, what, acts], i) => {
  const x = 0.6 + i * 4.1;
  s.addShape(pres.shapes.CHEVRON, { x, y: 1.55, w: 4.0, h: 0.95, fill: { color: i === 1 ? NAVY : MID }, line: { color: "FFFFFF", width: 0 } });
  s.addText([{ text: when, options: { bold: true, breakLine: true } }, { text: what }],
    T({ x: x + 0.55, y: 1.55, w: 3.0, h: 0.95, fontSize: 17, color: "FFFFFF", valign: "middle" }));
  acts.forEach(([a, who], j) => {
    const y = 2.85 + j * 1.15;
    s.addText(a, T({ x: x + 0.1, y, w: 3.75, h: 0.6, fontSize: 17, bold: true }));
    s.addText(who, T({ x: x + 0.1, y: y + 0.55, w: 3.75, h: 0.4, fontSize: 14, color: C.accent5 }));
  });
});

// 10. Decisions ------------------------------------------------------------
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Hal yang dimohonkan arahan pimpinan", { placeholder: "title" });
const DQ = [
  "Dimensi citra mana yang ingin diperkuat di Austria, dan berapa proporsi awalnya?",
  "Apakah konten layanan dipisahkan dari konten citra?",
  "Apakah uji coba tiga bulan dapat dimulai?",
];
DQ.forEach((q, i) => {
  const y = 1.65 + i * 1.5;
  s.addText(String(i + 1), T({ x: 0.6, y, w: 1.0, h: 1.1, fontSize: 60, bold: true, color: C.text2, valign: "middle" }));
  s.addText(q, T({ x: 1.7, y, w: 11.0, h: 1.1, fontSize: 26, valign: "middle" }));
});

// 11. Annex ----------------------------------------------------------------
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Lampiran: catatan dan keterbatasan kajian", { placeholder: "title" });
s.addText([
  "Klasifikasi dilakukan otomatis berdasarkan teks keterangan unggahan dan belum diperiksa manual; angka dapat berubah.",
  "Data mencakup 1.000 unggahan terakhir (Desember 2021 – Oktober 2026); Stories tidak termasuk.",
  "Belum ada data asal pengikut, sehingga belum diketahui seberapa jauh akun menjangkau publik Austria.",
  "Kajian ini tidak dapat membuktikan bahwa perubahan konten akan mengubah persepsi publik.",
  "Tampilan visual: dari 999 gambar, tidak ditemukan warna khas yang digunakan secara konsisten.",
  "Rincian metode dan data tersedia dalam dokumen terpisah.",
].map((t, i, a) => ({ text: t, options: { bullet: { indent: 22 }, breakLine: i < a.length - 1 } })),
  T({ x: 0.6, y: 1.55, w: 12.1, h: 5.0, fontSize: 18, paraSpaceAfter: 12 }));

(async () => {
  await pres.writeFile({ fileName: OUT });
  await applyTheme(OUT, THEME);
  console.log("done");
})();
