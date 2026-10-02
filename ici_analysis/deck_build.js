const pptxgen = require("pptxgenjs");
const { applyTheme } = require("/root/.claude/skills/synced/bde37891-3bef-4da4-b9bb-1bb9b29898f9_33615194-bc2a-4010-a576-7951822dbf9a/pptx/scripts/apply_theme.js");

const THEME = {
  name: "KBRI Wina Briefing",
  headFontFace: "Arial",
  bodyFontFace: "Arial",
  colors: {
    dk1: "1A1A1A", lt1: "FFFFFF", dk2: "1F3864", lt2: "EDEDED",
    accent1: "1F3864", accent2: "A6A6A6", accent3: "C00000", accent4: "D9D9D9",
    accent5: "595959", accent6: "7F7F7F", hlink: "1F3864", folHlink: "595959",
  },
};

const pres = new pptxgen();
pres.layout = "LAYOUT_WIDE"; // 13.33 x 7.5 in
pres.theme = { headFontFace: THEME.headFontFace, bodyFontFace: THEME.bodyFontFace };
pres.title = "Penataan Konten Instagram KBRI Wina";
pres.author = "Fungsi Pensosbud, KBRI/PTRI Wina";
const C = pres.SchemeColor;

const FOOT = "KBRI/PTRI Wina  ·  Fungsi Pensosbud  ·  Bahan diskusi";

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
  margin: [0.5, 0.6, 0.8, 0.6],
  objects: [
    { placeholder: { options: { name: "title", type: "title", x: 0.6, y: 0.35, w: 12.1, h: 1.1,
        fontSize: 28, bold: true, color: C.text2, valign: "middle", align: "left", margin: 0 }, text: "" } },
    { line: { x: 0.6, y: 6.85, w: 12.1, h: 0, line: { color: "D9D9D9", width: 0.75 } } },
    { text: { text: FOOT, options: { x: 0.6, y: 6.9, w: 9, h: 0.35, fontSize: 11, color: C.accent5, margin: 0 } } },
  ],
  slideNumber: { x: 12.1, y: 6.9, w: 0.6, h: 0.35, fontSize: 11, color: "595959", align: "right", margin: 0 },
});

const BODY = { fontSize: 20, color: C.text1, paraSpaceAfter: 14, valign: "top", margin: 0, isTextBox: true };
const NOTE = { fontSize: 12, color: C.accent5, margin: 0, isTextBox: true };
const bullets = (items) => items.map((t, i) => ({ text: t, options: { bullet: { indent: 22 }, breakLine: i < items.length - 1 } }));
const HEAD = { bold: true, fill: { color: "D9D9D9" }, color: C.text1 };
const cell = (t, o = {}) => ({ text: t, options: o });
const TBL = { fontSize: 16, color: C.text1, border: { type: "solid", pt: 0.75, color: "A6A6A6" }, valign: "middle", margin: [5, 8, 5, 8] };

// 1. Cover
let s = pres.addSlide({ masterName: "COVER" });
s.addText("Penataan Konten Instagram KBRI Wina", { placeholder: "title" });
s.addText("Usulan berdasarkan Indonesia Image Index (ICI)", { placeholder: "body" });
s.addText([
  { text: "Bahan diskusi  ·  Fungsi Pensosbud, KBRI/PTRI Wina", options: { breakLine: true } },
  { text: "Disusun oleh: [Nama], Magang Fungsi Pensosbud", options: { breakLine: true } },
  { text: "Oktober 2026" },
], { placeholder: "meta" });

// 2. Background
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Latar belakang", { placeholder: "title" });
s.addText(bullets([
  "Pimpinan menanyakan: bagaimana agar publik Austria melihat Indonesia lebih dari sekadar budaya dan pariwisata?",
  "Jumlah unggahan Instagram KBRI kini lebih terbatas dibanding tahun-tahun sebelumnya, sehingga setiap unggahan semakin bernilai.",
  "Belum ada pedoman yang menentukan pembagian unggahan menurut gambaran Indonesia yang ingin dibangun.",
]), { ...BODY, x: 0.6, y: 1.7, w: 12.1, h: 3.2 });
s.addText([
  { text: "Pertanyaan kajian", options: { bold: true, breakLine: true } },
  { text: "Dengan jumlah unggahan yang terbatas, gambaran Indonesia seperti apa yang ingin kita sampaikan kepada publik Austria dari waktu ke waktu?" },
], { x: 0.6, y: 5.0, w: 12.1, h: 1.4, fontSize: 20, color: C.text1, fill: { color: "EDEDED" }, margin: [10, 16, 10, 16], valign: "middle", isTextBox: true });

// 3. Framework
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Kerangka: tiga dimensi Indonesia Image Index (ICI) Kemlu", { placeholder: "title" });
s.addTable([
  [cell("Kategori", HEAD), cell("Unsur yang diukur", HEAD)],
  [cell("A. Budaya & Pariwisata", { bold: true }), cell("Menarik dikunjungi; budaya kaya dan beragam; masyarakat majemuk dan toleran")],
  [cell("B. Ekonomi & Bisnis", { bold: true }), cell("Ekonomi stabil; prospektif untuk berbisnis; kualitas produk baik")],
  [cell("C. Tata Kelola & Keamanan", { bold: true }), cell("Aman; demokratis; regulasi jelas dan mudah dipahami")],
  [cell("D. Layanan & Protokol", { bold: true, color: C.accent5 }), cell("Di luar ICI: layanan konsuler, kegiatan protokoler, peringatan hari besar, kegiatan masyarakat", { color: C.accent5 })],
], { ...TBL, x: 0.6, y: 1.7, w: 12.1, colW: [3.6, 8.5], rowH: 0.75 });
s.addText("Kategori D tetap merupakan tugas resmi Perwakilan. Kategori ini dipisahkan agar pembagian konten dapat terlihat.",
  { ...NOTE, fontSize: 16, x: 0.6, y: 5.85, w: 12.1, h: 0.6 });

// 4. Current allocation (all posts)
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Sebagian besar unggahan adalah konten layanan dan protokol", { placeholder: "title" });
s.addChart(pres.charts.BAR, [{
  name: "Persentase unggahan",
  labels: ["A. Budaya & Pariwisata", "B. Ekonomi & Bisnis", "C. Tata Kelola & Keamanan", "D. Layanan & Protokol"],
  values: [20, 5, 3, 73],
}], {
  x: 0.6, y: 1.6, w: 6.6, h: 4.6, barDir: "bar", catAxisOrientation: "maxMin",
  chartColors: ["1F3864"], barGapWidthPct: 60,
  showValue: true, dataLabelPosition: "outEnd", dataLabelFormatCode: '0"%"', dataLabelFontSize: 16, dataLabelColor: "1A1A1A",
  dataLabelFontFace: "+mn-lt",
  catAxisLabelFontSize: 15, catAxisLabelColor: "1A1A1A", catAxisLabelFontFace: "+mn-lt",
  valAxisHidden: true, valAxisMaxVal: 90, valAxisMinVal: 0,
  valGridLine: { style: "none" }, catGridLine: { style: "none" }, showLegend: false,
  showTitle: true, title: "Persentase unggahan menurut kategori (n = 992)", titleFontSize: 15, titleColor: "1A1A1A", titleFontFace: "+mn-lt",
});
s.addText(bullets([
  "720 dari 992 unggahan (73%) termasuk kategori D.",
  "Dari 272 unggahan yang membentuk citra, 195 (72%) tentang budaya dan pariwisata.",
  "Ekonomi & bisnis: 50 unggahan. Tata kelola & keamanan: 27 unggahan, dalam hampir lima tahun.",
]), { ...BODY, x: 7.6, y: 1.8, w: 5.1, h: 4.2 });
s.addText("Sumber: 1.000 unggahan @inainvienna, Des 2021 – Okt 2026 (8 unggahan tanpa teks tidak dihitung). Angka bersifat sementara sampai pemeriksaan manual selesai.",
  { ...NOTE, x: 0.6, y: 6.3, w: 12.1, h: 0.45 });

// 5. Recent period
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Sejak Januari 2025, tidak ada unggahan tentang tata kelola dan keamanan", { placeholder: "title" });
const R = { align: "right" };
s.addTable([
  [cell("Kategori", HEAD), cell("Jumlah unggahan", { ...HEAD, align: "right" }), cell("Persentase", { ...HEAD, align: "right" })],
  [cell("A. Budaya & Pariwisata"), cell("35", R), cell("30%", R)],
  [cell("B. Ekonomi & Bisnis"), cell("10", R), cell("9%", R)],
  [cell("C. Tata Kelola & Keamanan", { bold: true, color: C.accent3 }), cell("0", { ...R, bold: true, color: C.accent3 }), cell("0%", { ...R, bold: true, color: C.accent3 })],
  [cell("D. Layanan & Protokol"), cell("72", R), cell("62%", R)],
  [cell("Jumlah", { bold: true }), cell("117", { ...R, bold: true }), cell("100%", { ...R, bold: true })],
], { ...TBL, fontSize: 18, x: 0.6, y: 1.7, w: 7.6, colW: [3.8, 2.0, 1.8], rowH: 0.62 });
s.addText(bullets([
  "Dimensi tata kelola dan keamanan adalah dimensi yang dinilai masih lemah dalam citra Indonesia.",
  "KBRI pernah membuat konten jenis ini, misalnya penjelasan Visa on Arrival (2022–2023) dan izin tinggal 10 tahun (2024).",
]), { ...BODY, fontSize: 18, x: 8.7, y: 1.8, w: 4.0, h: 4.3 });
s.addText("Periode 1 Januari 2025 – 1 Oktober 2026. Angka bersifat sementara sampai pemeriksaan manual selesai.",
  { ...NOTE, x: 0.6, y: 6.3, w: 12.1, h: 0.45 });

// 6. Proposal: two streams
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Usulan: memisahkan konten citra dan konten layanan", { placeholder: "title" });
s.addTable([
  [cell("", HEAD), cell("Konten citra", HEAD), cell("Konten layanan", HEAD)],
  [cell("Tujuan", { bold: true }), cell("Membentuk gambaran publik Austria tentang Indonesia"), cell("Memberi informasi dan melayani WNI serta mitra")],
  [cell("Isi", { bold: true }), cell("Kategori A, B, dan C"), cell("Konsuler, protokol, peringatan hari besar, kegiatan masyarakat")],
  [cell("Sasaran", { bold: true }), cell("Publik Austria"), cell("WNI dan mitra")],
  [cell("Bahasa", { bold: true }), cell("Jerman dan/atau Inggris (usulan)"), cell("Bahasa Indonesia")],
  [cell("Pengaturan", { bold: true }), cell("Proporsi A, B, C ditetapkan pimpinan"), cell("Sesuai kebutuhan")],
], { ...TBL, x: 0.6, y: 1.7, w: 12.1, colW: [2.3, 4.9, 4.9], rowH: 0.7 });
s.addText("Konten layanan tetap merupakan tugas resmi Perwakilan. Bentuk penyajiannya (misalnya melalui Stories) dibahas bersama pengelola akun.",
  { ...NOTE, fontSize: 16, x: 0.6, y: 6.05, w: 12.1, h: 0.6 });

// 7. Examples from the account itself
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Contoh konten citra yang sudah pernah dibuat KBRI", { placeholder: "title" });
s.addTable([
  [cell("Kategori", HEAD), cell("Contoh yang sudah ada", HEAD), cell("Kemungkinan pengembangan", HEAD)],
  [cell("A. Budaya & Pariwisata", { bold: true }), cell("Liputan acara budaya di Austria; kelas BIPA; destinasi wisata"), cell("Kisah keberagaman dan toleransi (baru 4 unggahan)")],
  [cell("B. Ekonomi & Bisnis", { bold: true }), cell("Informasi bagi pelaku usaha Austria (2023); kunjungan Dubes ke Graz (2024); Indonesia Coffee & Culture (2026)"), cell("Data singkat ekonomi Indonesia secara berkala")],
  [cell("C. Tata Kelola & Keamanan", { bold: true }), cell("Penjelasan Visa on Arrival (2022–2023); izin tinggal 10 tahun (2024)"), cell("Penjelasan pemilu dan sistem pemerintahan Indonesia untuk publik asing")],
], { ...TBL, x: 0.6, y: 1.7, w: 12.1, colW: [3.1, 5.0, 4.0], rowH: [0.6, 1.0, 1.25, 1.0] });
s.addText("Kolom “kemungkinan pengembangan” adalah usulan untuk didiskusikan, bukan hasil kajian.",
  { ...NOTE, fontSize: 16, x: 0.6, y: 6.05, w: 12.1, h: 0.6 });

// 8. Indicators
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Ukuran keberhasilan: bukan hanya jumlah suka", { placeholder: "title" });
s.addTable([
  [cell("Indikator", HEAD), cell("Yang diukur", HEAD), cell("Frekuensi", HEAD)],
  [cell("Proporsi konten", { bold: true }), cell("Persentase unggahan per kategori dibanding target"), cell("Bulanan")],
  [cell("Jangkauan", { bold: true }), cell("Persentase pengikut dan jangkauan dari Austria (Instagram Insights)"), cell("Bulanan")],
  [cell("Persepsi", { bold: true }), cell("Pertanyaan ICI kepada responden Austria di luar acara KBRI"), cell("Tahunan")],
  [cell("Respons", { bold: true }), cell("Suka, komentar, simpan; sebagai pelengkap, bukan ukuran utama"), cell("Bulanan")],
], { ...TBL, x: 0.6, y: 1.7, w: 12.1, colW: [2.8, 7.4, 1.9], rowH: 0.75 });
s.addText("Indikator ini menunjukkan apakah pembagian konten berjalan sesuai rencana dan apakah publik Austria terjangkau. Indikator ini tidak dapat membuktikan bahwa Instagram mengubah persepsi.",
  { ...NOTE, fontSize: 16, x: 0.6, y: 5.75, w: 12.1, h: 0.9 });

// 9. First three months
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Langkah tiga bulan pertama", { placeholder: "title" });
s.addTable([
  [cell("Waktu", HEAD), cell("Kegiatan", HEAD), cell("Pelaksana", HEAD)],
  [cell("Bulan 1"), cell("Pemeriksaan manual 50 unggahan untuk menguji ketepatan klasifikasi"), cell("Pengelola akun, dibantu magang")],
  [cell("Bulan 1"), cell("Pengambilan data asal pengikut dan jangkauan (Instagram Insights)"), cell("Pengelola akun")],
  [cell("Bulan 1"), cell("Penetapan proporsi awal kategori A, B, C"), cell("Pimpinan")],
  [cell("Bulan 2–3"), cell("Uji coba: setiap unggahan diberi kategori sebelum terbit; laporan bulanan"), cell("Pengelola akun, dibantu magang")],
  [cell("Bulan 3"), cell("Evaluasi dan penyesuaian"), cell("Pimpinan dan Fungsi Pensosbud")],
], { ...TBL, x: 0.6, y: 1.7, w: 12.1, colW: [1.8, 6.6, 3.7], rowH: 0.72 });

// 10. Decisions
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Hal yang dimohonkan arahan pimpinan", { placeholder: "title" });
s.addText([
  { text: "Dimensi citra mana yang ingin diperkuat di Austria, dan berapa proporsi awalnya?", options: { bullet: { type: "number" }, breakLine: true } },
  { text: "Apakah konten layanan dipisahkan dari konten citra?", options: { bullet: { type: "number" }, breakLine: true } },
  { text: "Apakah uji coba tiga bulan dapat dimulai?", options: { bullet: { type: "number" } } },
], { ...BODY, fontSize: 24, paraSpaceAfter: 24, x: 0.6, y: 1.9, w: 12.1, h: 3.8 });

// 11. Annex: limitations
s = pres.addSlide({ masterName: "CONTENT" });
s.addText("Lampiran: catatan dan keterbatasan kajian", { placeholder: "title" });
s.addText(bullets([
  "Klasifikasi dilakukan secara otomatis berdasarkan teks keterangan unggahan dan belum diperiksa secara manual; angka dapat berubah.",
  "Data mencakup 1.000 unggahan terakhir (Desember 2021 – Oktober 2026); Stories tidak termasuk.",
  "Belum ada data asal pengikut, sehingga belum diketahui seberapa jauh akun menjangkau publik Austria.",
  "Kajian ini tidak dapat membuktikan bahwa perubahan konten akan mengubah persepsi publik.",
  "Tampilan visual: dari 999 gambar, tidak ditemukan warna khas yang digunakan secara konsisten.",
  "Rincian metode dan data tersedia dalam dokumen terpisah.",
]), { ...BODY, fontSize: 18, paraSpaceAfter: 10, x: 0.6, y: 1.7, w: 12.1, h: 4.9 });

(async () => {
  await pres.writeFile({ fileName: "/tmp/dk3/KBRI_Wina_Penataan_Konten_Instagram.pptx" });
  await applyTheme("/tmp/dk3/KBRI_Wina_Penataan_Konten_Instagram.pptx", THEME);
  console.log("done");
})();
