#!/usr/bin/env Rscript
# =============================================================================
# @inainvienna content audit against the Indonesia Image Index (ICI) dimensions
#
# Run from anywhere:   Rscript ici_analysis/analysis.R
#
# Inputs  (ici_analysis/data/)
#   posts_raw.csv            Instagram profile scrape (one row per post)
#   reels_raw.csv            Separate reels-tab scrape (profiled, not analysed; see step 1)
#   survey_responses.csv     OPTIONAL. ICI survey responses collected in person (step 6)
#   validation_hand_coded.csv OPTIONAL. validation_sample.csv with human_label filled in (step 3)
#   images/<post id>.jpg     OPTIONAL. Post thumbnails; downloaded in step 7 if the CDN is reachable
#
# Outputs
#   ici_analysis/output/     labelled_posts.csv, validation_sample.csv, profile.txt, results.txt, tables
#   ici_analysis/charts/     PNG, 300 dpi
#
# The classification rules live in codebook.md and are PARSED from it here
# (Appendix A = frozen v1.0 dictionaries; Appendix B = logged v1.1 changes),
# so the code cannot silently drift from the written codebook.
# =============================================================================

# ---- 0. Setup ---------------------------------------------------------------
pkgs <- c("ggplot2", "cluster", "Matrix", "jpeg", "png", "stringi")
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
suppressPackageStartupMessages({
  library(ggplot2); library(cluster); library(stringi)
})

# Locate this script's folder so relative paths work from any working directory
script_dir <- local({
  if (nzchar(Sys.getenv("ICI_DIR"))) return(normalizePath(Sys.getenv("ICI_DIR")))
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("^--file=", "", a[1]))) else getwd()
})
DATA   <- file.path(script_dir, "data")
OUT    <- file.path(script_dir, "output")
CHARTS <- file.path(script_dir, "charts")
dir.create(OUT, showWarnings = FALSE); dir.create(CHARTS, showWarnings = FALSE)

SEED <- 20261002                      # every random step uses this seed
ACCOUNT <- "inainvienna"
results_file <- file.path(OUT, "results.txt")
cat("", file = results_file)
say <- function(...) {                # print AND append to results.txt
  txt <- paste0(...)
  cat(txt, "\n"); cat(txt, "\n", file = results_file, append = TRUE)
}
say_tbl <- function(x) {
  txt <- capture.output(print(x))
  cat(txt, sep = "\n"); cat(txt, sep = "\n", file = results_file, append = TRUE)
}

# Chart look: minimal, legible at half size on a slide.
# Fixed categorical order (validated reference palette); D = neutral grey because it is residual.
ICI_COLS <- c(A = "#2a78d6", B = "#eb6834", C = "#1baf7a", D = "#a3a29c")
ICI_NAMES <- c(A = "A  Culture & Tourism", B = "B  Economy & Business",
               C = "C  Governance & Safety", D = "D  None of the three")
theme_ici <- function() {
  theme_minimal(base_size = 13) +
    theme(panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_line(colour = "#e6e5e0", linewidth = 0.3),
          axis.title = element_text(colour = "#52514e", size = 11),
          axis.text = element_text(colour = "#52514e"),
          plot.title = element_text(face = "bold", size = 14, colour = "#0b0b0b"),
          plot.subtitle = element_text(colour = "#52514e", size = 10.5),
          plot.caption = element_text(colour = "#52514e", size = 8.5, hjust = 0),
          plot.title.position = "plot", plot.caption.position = "plot",
          legend.position = "top", legend.justification = "left",
          legend.title = element_blank(),
          plot.background = element_rect(fill = "white", colour = NA))
}
save_chart <- function(p, name, w = 8, h = 4.5) {
  ggsave(file.path(CHARTS, name), p, width = w, height = h, dpi = 300, bg = "white")
}
wilson <- function(x, n, z = 1.96) {  # Wilson 95% interval for a proportion
  if (n == 0) return(c(NA, NA))
  p <- x / n; d <- 1 + z^2 / n
  c <- (p + z^2 / (2 * n)) / d; h <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / d
  c(max(0, c - h), min(1, c + h))
}

# ---- 1. Profile the data before analysing it --------------------------------
read_scrape <- function(f) {
  d <- read.csv(f, check.names = FALSE, stringsAsFactors = FALSE, encoding = "UTF-8")
  # The scraper writes a byte-order mark that would otherwise corrupt the first header
  names(d) <- stri_replace_first_regex(enc2utf8(names(d)), "^\\x{FEFF}", "")
  d
}
posts <- read_scrape(file.path(DATA, "posts_raw.csv"))
reels <- read_scrape(file.path(DATA, "reels_raw.csv"))
blank <- function(x) is.na(x) | trimws(as.character(x)) == ""
parse_ts <- function(x) as.POSIXct(substr(x, 1, 19), format = "%Y-%m-%dT%H:%M:%S", tz = "UTC")

profile <- function(d, label) {
  ts <- parse_ts(d$timestamp)
  key <- intersect(c("id", "shortCode", "timestamp", "caption", "type", "productType",
                     "ownerUsername", "displayUrl", "images/0", "videoUrl", "alt",
                     "likesCount", "commentsCount", "videoViewCount", "videoPlayCount",
                     "locationName", "hashtags/0", "mentions/0",
                     "coauthorProducers/0/username"), names(d))
  miss <- vapply(d[key], function(x) mean(blank(x)), numeric(1))
  c(sprintf("== %s ==", label),
    sprintf("Rows: %d | Columns: %d (most are flattened JSON arrays: childPosts/i/..., hashtags/i, taggedUsers/i/...)",
            nrow(d), ncol(d)),
    sprintf("Unique post ids: %d", length(unique(d$id))),
    sprintf("Date range (UTC): %s to %s", format(min(ts, na.rm = TRUE)), format(max(ts, na.rm = TRUE))),
    "Posts per calendar year:", capture.output(print(table(format(ts, "%Y")))),
    "Media type:", capture.output(print(table(d$type))),
    "productType:", capture.output(print(table(d$productType))),
    sprintf("Rows whose ownerUsername is %s: %d; other owners: %d",
            ACCOUNT, sum(d$ownerUsername == ACCOUNT), sum(d$ownerUsername != ACCOUNT)),
    "Share missing/blank for key fields:",
    capture.output(print(round(miss, 3))), "")
}
prof_txt <- c(profile(posts, "posts_raw.csv"), profile(reels, "reels_raw.csv"),
  sprintf("Posts in both files (same id): %d", length(intersect(posts$id, reels$id))),
  "",
  "== Fields that do NOT exist in either file ==",
  "  reach, impressions, saves, shares, follower count at time of post, audience location/demographics,",
  "  any image file (only CDN URLs, which expire), any field saying who wrote a post or why.",
  "")
writeLines(prof_txt, file.path(OUT, "profile.txt"))
cat(prof_txt, sep = "\n")

# Corpus decisions (documented in findings.md):
#  * Primary corpus = posts_raw.csv (the profile grid). It returned exactly 1000 rows,
#    which matches a scraper item cap: the account's history before the earliest row is
#    absent, so "the account" below means "its 1000 most recent grid posts".
#  * reels_raw.csv: all of its rows are owned by OTHER accounts (tagged/collab reels);
#    it is profiled above but not analysed as the account's own output.
#  * Grid posts owned by another account (collab posts) are kept and flagged; results
#    are re-run without them as a sensitivity check.
d <- posts[!duplicated(posts$id), ]
d$ts <- parse_ts(d$timestamp)
d <- d[order(d$ts), ]
d$year <- as.integer(format(d$ts, "%Y"))
d$own_post <- d$ownerUsername == ACCOUNT
capped <- nrow(posts) == 1000
say("=== STEP 1: corpus ===")
say(sprintf("Corpus: %d posts, %s to %s. Own posts: %d; collab posts owned by other accounts: %d.",
            nrow(d), format(min(d$ts), "%Y-%m-%d"), format(max(d$ts), "%Y-%m-%d"),
            sum(d$own_post), sum(!d$own_post)))
if (capped) say("WARNING: exactly 1000 rows -> consistent with a scraper cap; earlier history is missing.")

# ---- 2. Classify against the codebook (parsed from codebook.md) -------------
cb <- readLines(file.path(script_dir, "codebook.md"), encoding = "UTF-8")
parse_dict <- function(lines) {
  m <- stri_match_first_regex(lines, "^\\*\\*([A-D][0-9]) [^:]+:\\*\\* (.+)$")
  m <- m[!is.na(m[, 1]), , drop = FALSE]
  setNames(lapply(m[, 3], function(s) unique(trimws(strsplit(s, ",")[[1]]))), m[, 2])
}
appA <- cb[seq(grep("^## Appendix A", cb), grep("^## Appendix B|^## Change log", cb)[1] - 1)]
DICT_V10 <- parse_dict(appA)
stopifnot(all(c(paste0("A", 1:3), paste0("B", 1:3), paste0("C", 1:3), paste0("D", 1:5)) %in% names(DICT_V10)))

# Text preparation. Hashtags never count towards substance (codebook s.2), so they
# are removed from the scoring text; URLs and @mentions are removed too.
strip_tags <- function(x) {
  x <- stri_replace_all_regex(x, "https?://\\S+|www\\.\\S+|bit\\.ly/\\S+", " ")
  x <- stri_replace_all_regex(x, "[#@][\\p{L}\\p{N}_.]+", " ")
  stri_trim_both(stri_replace_all_regex(x, "\\s+", " "))
}
d$body <- strip_tags(d$caption)
d$lead <- vapply(stri_split_regex(d$body, "(?<=[.!?])\\s+|\\n+"), function(s) paste(head(s, 2), collapse = " "), "")
d$n_words <- stri_count_regex(d$body, "\\p{L}{2,}")

d$is_repost <- grepl("^\\s*Reposted from", d$caption)   # syndicated from another account
# A recurring daily series (COVID-19 infection-rate infographics for Austria/Slovenia, Dec 2021-2022)
# is large enough to move the shares on its own; it is flagged so results can be shown without it.
d$covid_series <- grepl("^\\s*Infografis angka tingkat infeksi", d$caption)

# Term matching -- behaviour is set per codebook version by a config object:
#   whole_word(t)     TRUE -> term must end at a word boundary (an optional plural "s" allowed)
#   case_sensitive(t) TRUE -> exact case required
term_regex <- function(term, whole_word = FALSE) {
  t <- stri_replace_all_regex(term, "([.\\\\+*?\\[^\\]$(){}=!<>|:\\-])", "\\\\$1")
  t <- stri_replace_all_fixed(t, " ", "\\s+")
  paste0("(?<![\\p{L}\\p{N}])", t, if (whole_word) "s?(?![\\p{L}\\p{N}])" else "")
}
count_terms <- function(text, terms, cfg) {
  tot <- integer(length(text)); hit <- character(length(text))
  for (t in terms) {
    n <- stri_count_regex(text, term_regex(t, cfg$whole_word(t)), case_insensitive = !cfg$case_sensitive(t))
    tot <- tot + n
    hit <- ifelse(n > 0, paste0(hit, ifelse(hit == "", "", "; "), t), hit)
  }
  list(n = tot, hits = hit)
}

# --- Codebook versions --------------------------------------------------------
# v1.0: frozen. Prefix match, case-insensitive, no Rule-7 proxy, substance threshold 2.
CFG_V10 <- list(version = "1.0", dict = DICT_V10, threshold = 2, rule7 = FALSE,
                whole_word = function(t) FALSE, case_sensitive = function(t) FALSE)
# v1.1: written AFTER inspecting v1.0 output; every change is logged with its reason
# in codebook.md Appendix B. Changes are mechanical (word collisions) plus implementing
# Rule 7, which the v1.0 automated procedure omitted. Threshold is NOT changed.
appB <- cb[seq(grep("^## Appendix B", cb), grep("^## Change log", cb) - 1)]
rm_lines <- stri_match_first_regex(appB, "^- REMOVE (D[0-9]|[ABC][0-9]): (.+)$")
rm_lines <- rm_lines[!is.na(rm_lines[, 1]), , drop = FALSE]
DICT_V11 <- DICT_V10
for (j in seq_len(nrow(rm_lines))) {
  drop <- trimws(strsplit(rm_lines[j, 3], ",")[[1]])
  DICT_V11[[rm_lines[j, 2]]] <- setdiff(DICT_V11[[rm_lines[j, 2]]], drop)
}
is_acronym <- function(t) grepl("^[A-Z]{2,5}$", t)
CFG_V11 <- list(version = "1.1", dict = DICT_V11, threshold = 2, rule7 = TRUE,
                whole_word = function(t) nchar(t) <= 4 || is_acronym(t),
                case_sensitive = function(t) is_acronym(t))

C3_FOREIGN <- c("visa on arrival", "e-VoA", "e-visa", "golden visa", "bebas visa")   # codebook s.6 step 4

classify <- function(d, cfg) {
  DICT <- cfg$dict; dims <- c("A", "B", "C"); dsub <- paste0("D", 1:5)
  sub_sc <- sapply(paste0(rep(dims, each = 3), 1:3), function(s) count_terms(d$body, DICT[[s]], cfg)$n)
  sub_hit <- lapply(setNames(paste0(rep(dims, each = 3), 1:3), paste0(rep(dims, each = 3), 1:3)),
                    function(s) count_terms(d$body, DICT[[s]], cfg)$hits)
  ds <- sapply(dsub, function(k) count_terms(d$body, DICT[[k]], cfg)$n)
  d_hit <- sapply(dsub, function(k) count_terms(d$body, DICT[[k]], cfg)$hits)
  lead_sc <- sapply(dims, function(k) count_terms(d$lead, unlist(DICT[paste0(k, 1:3)]), cfg)$n)
  # Rule 7 proxy (v1.1+): in a post naming a Vienna multilateral body, generic safety/security
  # vocabulary (C1) describes the body's mandate, not Indonesia -> C1 matches are not counted.
  c1_eff <- if (cfg$rule7) ifelse(ds[, "D4"] > 0, 0L, sub_sc[, "C1"]) else sub_sc[, "C1"]
  S <- cbind(A = rowSums(sub_sc[, paste0("A", 1:3)]), B = rowSums(sub_sc[, paste0("B", 1:3)]),
             C = c1_eff + sub_sc[, "C2"] + sub_sc[, "C3"])
  # Rule 6 proxy: citizen-service terms cancel C unless foreign-audience C3 terms are present
  c3f <- count_terms(d$body, C3_FOREIGN, cfg)$n
  rule6 <- ds[, "D3"] > 0 & S[, "C"] > 0 & c3f == 0
  S[rule6, "C"] <- 0L
  Q <- S >= cfg$threshold                                  # substance proxy (Rule 3)
  n <- nrow(d); prim <- sub <- sec <- rule <- character(n)
  for (i in seq_len(n)) {
    if (d$n_words[i] < 3) { prim[i] <- sub[i] <- "U"; rule[i] <- "U"; next }
    q <- dims[Q[i, ]]
    if (length(q) == 0) {
      prim[i] <- "D"; sub[i] <- if (max(ds[i, ]) == 0) "D6" else dsub[which.max(ds[i, ])]
      rule[i] <- if (rule6[i]) "R6" else "R3-residual"; next
    }
    s <- S[i, q]; top <- q[s == max(s)]; rule[i] <- "max"
    if (length(top) > 1) {                                 # Rule 5 tie-breaks
      l <- lead_sc[i, top]; top <- top[l == max(l)]; rule[i] <- "R5.1"
      if (length(top) > 1) { top <- intersect(c("C", "B", "A"), top)[1]; rule[i] <- "R5.3" }
    }
    prim[i] <- top
    rest <- setdiff(q, top); if (length(rest)) sec[i] <- rest[which.max(S[i, rest])]
    ss <- sub_sc[i, paste0(top, 1:3)]; sub[i] <- names(ss)[which.max(ss)]
  }
  join <- function(...) { x <- paste(..., sep = "; "); x <- gsub("(; )+", "; ", x); gsub("^; |; $", "", x) }
  data.frame(ici_primary = prim, ici_sub = sub, ici_secondary = sec, rule_applied = rule,
             hits_A = S[, "A"], hits_B = S[, "B"], hits_C = S[, "C"],
             terms_A = join(sub_hit$A1, sub_hit$A2, sub_hit$A3),
             terms_B = join(sub_hit$B1, sub_hit$B2, sub_hit$B3),
             terms_C = join(sub_hit$C1, sub_hit$C2, sub_hit$C3),
             terms_D = join(d_hit[, 1], d_hit[, 2], d_hit[, 3], d_hit[, 4], d_hit[, 5]),
             coder = paste0("auto_v", cfg$version), stringsAsFactors = FALSE)
}

lab10 <- classify(d, CFG_V10)
lab11 <- classify(d, CFG_V11)                              # HEADLINE labels
lab11_t1 <- classify(d, modifyList(CFG_V11, list(threshold = 1)))   # sensitivity: lenient substance
lab11_t3 <- classify(d, modifyList(CFG_V11, list(threshold = 3)))   # sensitivity: strict substance

say("\n=== STEP 2: classification ===")
say("Primary label counts under each codebook version / sensitivity setting:")
cmp <- rbind(`v1.0 (frozen)` = table(factor(lab10$ici_primary, c("A","B","C","D","U"))),
             `v1.1 (headline)` = table(factor(lab11$ici_primary, c("A","B","C","D","U"))),
             `v1.1 threshold=1` = table(factor(lab11_t1$ici_primary, c("A","B","C","D","U"))),
             `v1.1 threshold=3` = table(factor(lab11_t3$ici_primary, c("A","B","C","D","U"))))
say_tbl(cmp)
say(sprintf("v1.0 vs v1.1 agreement on primary label: %d of %d posts (%.1f%%)",
            sum(lab10$ici_primary == lab11$ici_primary), nrow(d), 100 * mean(lab10$ici_primary == lab11$ici_primary)))
say("v1.1 D sub-codes:"); say_tbl(table(lab11$ici_sub[lab11$ici_primary == "D"]))
say("v1.1 A/B/C sub-codes:"); say_tbl(table(lab11$ici_sub[lab11$ici_primary %in% c("A","B","C")]))
say("Rules that decided v1.1 labels:"); say_tbl(table(lab11$rule_applied))

# ---- 3. Validation sample (blind) -------------------------------------------
# 30 posts drawn by simple random sampling. The automated label is deliberately NOT
# in the file, so the hand-coder is blind to it. Kappa is computed by validation_kappa.R.
set.seed(SEED)
vs_idx <- sort(sample(seq_len(nrow(d)), 30))
blind <- function(idx, tag) data.frame(
  sample_no = paste0(tag, sprintf("%02d", seq_along(idx))), id = d$id[idx], url = d$url[idx],
  date = format(d$ts[idx], "%Y-%m-%d"), caption = d$caption[idx],
  human_label = "", human_sub = "", notes = "", stringsAsFactors = FALSE)
validation <- blind(vs_idx, "R")
write.csv(validation, file.path(OUT, "validation_sample.csv"), row.names = FALSE, fileEncoding = "UTF-8")
# Optional supplement: a random 30 is expected to hold only ~1-3 B or C posts, so it cannot
# tell us whether the scarce categories are labelled correctly. This oversample (10 auto-B,
# 10 auto-C, not overlapping the random 30) checks precision on exactly those labels.
set.seed(SEED + 1)
pick <- function(lbl, k) { p <- setdiff(which(lab11$ici_primary == lbl), vs_idx); p[sample.int(length(p), min(k, length(p)))] }
sup_idx <- sample(c(pick("B", 10), pick("C", 10)))
write.csv(blind(sup_idx, "S"), file.path(OUT, "validation_supplement.csv"), row.names = FALSE, fileEncoding = "UTF-8")
say(sprintf("\n=== STEP 3: validation sample written: 30 random posts (blind). The automated labels hold %s.",
            paste(names(table(lab11$ici_primary[vs_idx])), table(lab11$ici_primary[vs_idx]), sep = "=", collapse = ", ")))


# ---- 4. Latent structure: TF-IDF + k-means + hierarchical -------------------
# Language is detected first because in a trilingual corpus it is the most likely
# "structure" a bag-of-words clustering will find.
SW <- list(
  id = c("yang","dan","di","dengan","untuk","dari","ini","pada","dalam","telah","akan","oleh","itu",
         "ke","tersebut","juga","serta","para","kami","bagi","atas","sebagai","tahun","antara","secara",
         "kita","acara","dapat","lebih","adalah","tidak","atau","sudah","bapak","ibu","hari","tanggal","yuk"),
  en = c("the","and","of","to","in","with","for","on","is","at","by","from","this","that","as","an",
         "are","was","were","be","has","have","will","its","their","our","we","it","which","also","who"),
  de = c("der","die","das","und","mit","für","von","den","ist","im","zu","des","dem","ein","eine","auf",
         "sich","wir","sie","auch","als","bei","nicht","wird","zum","zur","unsere","einen","aus","am"))
tok <- stri_extract_all_regex(stri_trans_tolower(d$body), "\\p{L}{3,}")
tok[vapply(tok, function(x) all(is.na(x)), TRUE)] <- list(character(0))
lang_counts <- sapply(SW, function(sw) vapply(stri_extract_all_regex(stri_trans_tolower(d$body), "\\p{L}+"),
                                               function(x) sum(x %in% sw), 0L))
d$language <- apply(lang_counts, 1, function(r) {
  o <- sort(r, decreasing = TRUE)
  if (o[1] < 2) "unknown" else if (o[2] >= 0.5 * o[1] && o[2] >= 3) "mixed" else names(o)[1]
})
say("\n=== STEP 4: latent structure ===")
say("Detected caption language:"); say_tbl(table(d$language))

stop_all <- c(unlist(SW), "dalam", "wina", "vienna", "wien")   # city name appears in nearly every caption
N <- nrow(d)
df_cnt <- table(unlist(lapply(tok, unique)))
vocab <- names(df_cnt)[df_cnt >= 5 & df_cnt <= 0.5 * N & !names(df_cnt) %in% stop_all]
ii <- rep(seq_len(N), lengths(tok)); jj <- match(unlist(tok), vocab); keep <- !is.na(jj)
TF <- Matrix::sparseMatrix(i = ii[keep], j = jj[keep], x = 1, dims = c(N, length(vocab)), dimnames = list(NULL, vocab))
X <- log1p(as.matrix(TF)) %*% diag(log(N / as.numeric(df_cnt[vocab])))      # TF-IDF (log tf)
colnames(X) <- vocab
rn <- sqrt(rowSums(X^2)); has_text <- rn > 0
X <- X[has_text, ] / rn[has_text]                       # L2-normalised -> Euclidean ~ cosine
say(sprintf("TF-IDF matrix: %d posts x %d terms (terms kept if in >=5 posts and <=50%% of posts); %d posts with no retained term are left unclustered.",
            nrow(X), ncol(X), sum(!has_text)))

dist_X <- dist(X)
ks <- 2:15
set.seed(SEED)
km_fits <- lapply(ks, function(k) kmeans(X, centers = k, nstart = 20, iter.max = 100))
km_sil <- vapply(seq_along(ks), function(j) mean(silhouette(km_fits[[j]]$cluster, dist_X)[, 3]), 0)
km_wss <- vapply(km_fits, function(f) f$tot.withinss, 0)
hc <- hclust(dist_X, method = "ward.D2")
hc_sil <- vapply(ks, function(k) mean(silhouette(cutree(hc, k), dist_X)[, 3]), 0)
# Elbow located objectively: the k farthest from the straight line joining the first and last WSS points
elbow_k <- {
  x <- (ks - min(ks)) / diff(range(ks)); y <- (km_wss - min(km_wss)) / diff(range(km_wss))
  ks[which.max(abs((y[length(y)] - y[1]) * x - (x[length(x)] - x[1]) * y + x[length(x)] * y[1] - y[length(y)] * x[1]))]
}
k_best <- ks[which.max(km_sil)]
say("k selection (k-means silhouette, k-means within-SS, Ward silhouette):")
say_tbl(data.frame(k = ks, kmeans_silhouette = round(km_sil, 4), kmeans_wss = round(km_wss, 1), ward_silhouette = round(hc_sil, 4)))
say(sprintf("Chosen k = %d (maximum mean silhouette, the stated criterion). Elbow of WSS curve: k = %d. Maximum silhouette = %.3f.",
            k_best, elbow_k, max(km_sil)))
say(sprintf("Interpretation guide: silhouette > 0.5 strong, 0.25-0.5 weak, < 0.25 no substantial structure (Kaufman & Rousseeuw). Observed %.3f.", max(km_sil)))

km <- km_fits[[which(ks == k_best)]]
d$cluster_kmeans <- NA_integer_; d$cluster_kmeans[has_text] <- km$cluster
d$cluster_hclust <- NA_integer_; d$cluster_hclust[has_text] <- cutree(hc, k_best)
ari <- function(a, b) {                                   # adjusted Rand index
  t <- table(a, b); s <- function(x) sum(choose(x, 2))
  e <- s(rowSums(t)) * s(colSums(t)) / choose(sum(t), 2)
  (s(t) - e) / (0.5 * (s(rowSums(t)) + s(colSums(t))) - e)
}
say(sprintf("Agreement k-means vs Ward at k=%d: adjusted Rand index = %.3f (1 = identical, 0 = chance).",
            k_best, ari(km$cluster, cutree(hc, k_best))))
top_terms <- t(sapply(seq_len(k_best), function(k) {
  m <- colMeans(X[km$cluster == k, , drop = FALSE]); paste(names(sort(m, decreasing = TRUE))[1:8], collapse = ", ")
}))
say("k-means clusters: size and top TF-IDF terms:")
for (k in seq_len(k_best)) say(sprintf("  cluster %d (n=%d): %s", k, sum(km$cluster == k), top_terms[k]))

cramers_v <- function(a, b) {
  t <- table(a, b); t <- t[rowSums(t) > 0, colSums(t) > 0, drop = FALSE]
  chi <- suppressWarnings(chisq.test(t, correct = FALSE)$statistic)
  as.numeric(sqrt(chi / (sum(t) * (min(dim(t)) - 1))))
}
ct <- has_text & lab11$ici_primary != "U"
say("Cross-tab: k-means cluster x ICI label (v1.1):")
say_tbl(addmargins(table(cluster = d$cluster_kmeans[ct], ICI = lab11$ici_primary[ct])))
assoc <- c(ICI_label = cramers_v(d$cluster_kmeans[ct], lab11$ici_primary[ct]),
           language = cramers_v(d$cluster_kmeans[ct], d$language[ct]),
           year = cramers_v(d$cluster_kmeans[ct], d$year[ct]),
           repost = cramers_v(d$cluster_kmeans[ct], d$is_repost[ct]),
           format = cramers_v(d$cluster_kmeans[ct], d$productType[ct]))
say("Cramer's V between emergent cluster and each candidate organising variable (0 = none, 1 = perfect):")
say_tbl(round(sort(assoc, decreasing = TRUE), 3))
km_e <- km_fits[[which(ks == elbow_k)]]$cluster; ct_e <- (lab11$ici_primary != "U")[has_text]
assoc_e <- c(ICI_label = cramers_v(km_e[ct_e], lab11$ici_primary[has_text][ct_e]),
             language = cramers_v(km_e[ct_e], d$language[has_text][ct_e]),
             year = cramers_v(km_e[ct_e], d$year[has_text][ct_e]),
             repost = cramers_v(km_e[ct_e], d$is_repost[has_text][ct_e]),
             format = cramers_v(km_e[ct_e], d$productType[has_text][ct_e]))
say(sprintf("Robustness: same association at the elbow k = %d:", elbow_k))
say_tbl(round(sort(assoc_e, decreasing = TRUE), 3))
say("Note: the silhouette maximum lies at the edge of the pre-set range (k = 2..15) and rises only slowly, so no k is a natural partition.")
say("Cramer's V values for variables with different numbers of categories are only roughly comparable.")
say("Cross-tab: k-means cluster x language:")
say_tbl(table(cluster = d$cluster_kmeans[ct], language = d$language[ct]))

ksel <- rbind(data.frame(k = ks, value = km_sil, panel = "Mean silhouette (higher = more separated)", method = "k-means"),
              data.frame(k = ks, value = hc_sil, panel = "Mean silhouette (higher = more separated)", method = "Ward hierarchical"),
              data.frame(k = ks, value = km_wss, panel = "Within-cluster sum of squares (elbow)", method = "k-means"))
p_k <- ggplot(ksel, aes(k, value, colour = method)) +
  geom_line(linewidth = 0.7) + geom_point(size = 1.8) +
  geom_vline(xintercept = k_best, linetype = "dashed", colour = "#52514e", linewidth = 0.4) +
  facet_wrap(~panel, scales = "free_y") +
  scale_colour_manual(values = c(`k-means` = "#2a78d6", `Ward hierarchical` = "#eb6834")) +
  scale_x_continuous(breaks = ks) +
  labs(title = sprintf("Captions have no strong topic structure: best silhouette %.2f (k = %d)", max(km_sil), k_best),
       subtitle = sprintf("TF-IDF on %d captions. Dashed line = chosen k (max silhouette). WSS elbow at k = %d.", nrow(X), elbow_k),
       x = "Number of clusters (k)", y = NULL,
       caption = "Silhouette below 0.25 is conventionally read as no substantial structure.") +
  theme_ici() + theme(panel.grid.major.x = element_blank())
save_chart(p_k, "k_selection.png", w = 9, h = 4.2)

# ---- 5. Allocation: content share per ICI dimension -------------------------
say("\n=== STEP 5: allocation ===")
share_tbl <- function(lbl, label) {
  lbl <- lbl[lbl != "U"]; n <- length(lbl)
  do.call(rbind, lapply(c("A", "B", "C", "D"), function(k) {
    x <- sum(lbl == k); ci <- wilson(x, n)
    data.frame(setting = label, dimension = k, n_posts = x, n_total = n, share = x / n, ci_lo = ci[1], ci_hi = ci[2])
  }))
}
alloc <- rbind(share_tbl(lab11$ici_primary, "v1.1 headline"),
               share_tbl(lab10$ici_primary, "v1.0 frozen"),
               share_tbl(lab11_t1$ici_primary, "v1.1 threshold=1"),
               share_tbl(lab11_t3$ici_primary, "v1.1 threshold=3"),
               share_tbl(lab11$ici_primary[d$own_post], "v1.1 own posts only"),
               share_tbl(lab11$ici_primary[!d$is_repost], "v1.1 excluding reposts"),
               share_tbl(lab11$ici_primary[!d$covid_series], "v1.1 excluding COVID infographic series"))
write.csv(alloc, file.path(OUT, "allocation_by_setting.csv"), row.names = FALSE)
fmt <- alloc; fmt$share <- sprintf("%.1f%%", 100 * fmt$share)
fmt$ci95 <- sprintf("%.1f-%.1f%%", 100 * alloc$ci_lo, 100 * alloc$ci_hi); fmt$ci_lo <- fmt$ci_hi <- NULL
say_tbl(fmt)
# Ratio within the ICI-relevant posts (A+B+C), the comparison the hypothesis is about
abc <- function(lbl) { t <- table(factor(lbl[lbl %in% c("A","B","C")], c("A","B","C"))); round(100 * t / sum(t), 1) }
say("Within ICI-relevant posts only (A+B+C = 100%):")
say_tbl(rbind(`v1.0` = abc(lab10$ici_primary), `v1.1` = abc(lab11$ici_primary),
              `v1.1 t=1` = abc(lab11_t1$ici_primary), `v1.1 t=3` = abc(lab11_t3$ici_primary)))
say(sprintf("COVID infographic series: %d posts (%s).", sum(d$covid_series),
            paste(names(table(d$year[d$covid_series])), table(d$year[d$covid_series]), sep = ": ", collapse = ", ")))
say("Share of each dimension's posts that are reposts from other accounts (v1.1):")
rp <- table(dimension = lab11$ici_primary, repost = d$is_repost)[c("A","B","C","D"), ]
say_tbl(cbind(rp, repost_pct = round(100 * rp[, "TRUE"] / rowSums(rp), 1)))
say("A/B/C sub-attributes (v1.1); any cell under 10 is a count only, no share is read from it:")
say_tbl(table(factor(lab11$ici_sub[lab11$ici_primary %in% c("A","B","C")], paste0(rep(c("A","B","C"), each = 3), 1:3))))
recent <- d$year >= 2025 & lab11$ici_primary != "U"
say(sprintf("Most recent period (Jan 2025 - %s, n = %d posts): C count under each setting: v1.0 = %d, v1.1 = %d, threshold=1 = %d, threshold=3 = %d.",
            format(max(d$ts), "%d %b %Y"), sum(recent), sum(lab10$ici_primary[recent] == "C"), sum(lab11$ici_primary[recent] == "C"),
            sum(lab11_t1$ici_primary[recent] == "C"), sum(lab11_t3$ici_primary[recent] == "C")))
small_dims <- names(which(table(factor(lab11$ici_primary, c("A","B","C","D"))) < 10))
if (length(small_dims)) say("REFUSAL: dimension(s) ", paste(small_dims, collapse = ", "),
                            " have fewer than 10 posts in total; no trend is drawn for them.")

head_tab <- share_tbl(lab11$ici_primary, "v1.1")
head_tab$dimension_lab <- factor(ICI_NAMES[head_tab$dimension], rev(ICI_NAMES))
n_cls <- head_tab$n_total[1]
p_share <- ggplot(head_tab, aes(share, dimension_lab, fill = dimension)) +
  geom_col(width = 0.62) +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.18, colour = "#52514e", linewidth = 0.35) +
  geom_text(aes(x = ci_hi + 0.012, label = sprintf("%.0f%%  (n = %d)", 100 * share, n_posts)),
            hjust = 0, size = 3.9, colour = "#0b0b0b") +
  scale_fill_manual(values = ICI_COLS, guide = "none") +
  scale_x_continuous(labels = function(x) paste0(100 * x, "%"), limits = c(0, max(head_tab$ci_hi) + 0.17),
                     expand = expansion(mult = c(0, 0))) +
  labs(title = sprintf("Of %d classifiable posts, %.0f%% address none of the three ICI dimensions",
                       n_cls, 100 * head_tab$share[head_tab$dimension == "D"]),
       subtitle = sprintf("Among posts that do: A %d, B %d, C %d. Automated caption coding (codebook v1.1), provisional until hand-validated.",
                          head_tab$n_posts[1], head_tab$n_posts[2], head_tab$n_posts[3]),
       x = "Share of posts", y = NULL,
       caption = sprintf("@inainvienna grid posts %s to %s (n = %d; %d uncodable excluded). Bars: 95%% Wilson intervals (sampling only, not classification error).",
                         format(min(d$ts), "%b %Y"), format(max(d$ts), "%b %Y"), nrow(d), sum(lab11$ici_primary == "U"))) +
  theme_ici() + theme(panel.grid.major.y = element_blank(),
                      panel.grid.major.x = element_line(colour = "#e6e5e0", linewidth = 0.3),
                      axis.text.y = element_text(size = 12, colour = "#0b0b0b"))
save_chart(p_share, "content_share_by_ici.png", w = 9, h = 4.2)

# Time series by calendar year. Dec 2021 (two weeks at the cap boundary) is excluded;
# 2026 runs only to the scrape date and is labelled partial.
ts_d <- data.frame(year = d$year, lab = lab11$ici_primary)[d$year >= 2022 & lab11$ici_primary != "U", ]
yt <- table(year = ts_d$year, dimension = factor(ts_d$lab, c("A","B","C","D")))
say("Posts per year by ICI dimension (v1.1; n in every cell):")
say_tbl(addmargins(yt, 2))
say("Row shares (%):"); say_tbl(round(100 * prop.table(yt, 1), 1))
say("Cells with n < 10 are too small to read as a yearly share; see table above.")
trend_dims <- setdiff(c("A","B","C","D"), small_dims)
say("Year trend in share (logistic regression of 'post is in dimension k' on year; odds ratio per year, 95% CI):")
for (k in trend_dims) {
  f <- glm(I(lab == k) ~ year, family = binomial, data = ts_d)
  est <- coef(summary(f))["year", ]; or <- exp(est[1] + c(0, -1.96, 1.96) * est[2])
  say(sprintf("  %s: n=%d posts; OR/year = %.2f (%.2f-%.2f); p = %.3f", k, sum(ts_d$lab == k), or[1], or[2], or[3], est[4]))
}
for (k in small_dims) say(sprintf("  %s: n=%d -> fewer than 10 posts, trend not estimated.", k, sum(ts_d$lab == k)))
say(sprintf("Total posts per year: %s", paste(names(rowSums(yt)), rowSums(yt), sep = "=", collapse = ", ")))
say("Note: shares are composition, not volume. A falling share can come from fewer posts of that type OR more posts of other types.")

ts_long <- as.data.frame(prop.table(yt, 1)); names(ts_long)[3] <- "share"
ts_long$n <- as.vector(yt)
ts_long$year_lab <- factor(ifelse(ts_long$year == "2026", "2026\n(to 1 Oct)", as.character(ts_long$year)),
                           levels = c(as.character(2022:2025), "2026\n(to 1 Oct)"))
ts_long$dimension <- factor(ts_long$dimension, rev(c("A","B","C","D")))
tot_y <- data.frame(year_lab = levels(ts_long$year_lab), n = as.vector(rowSums(yt)))
p_time <- ggplot(ts_long, aes(year_lab, share, fill = dimension)) +
  geom_col(width = 0.66, colour = "white", linewidth = 0.5) +
  geom_text(aes(label = ifelse(n >= 10 & share >= 0.06, n, "")), position = position_stack(vjust = 0.5), size = 3.3, colour = "white") +
  geom_text(data = tot_y, aes(x = year_lab, y = 1.04, label = paste0("n = ", n)), inherit.aes = FALSE,
            size = 3.4, colour = "#52514e") +
  scale_fill_manual(values = ICI_COLS, labels = ICI_NAMES, breaks = c("A","B","C","D")) +
  scale_y_continuous(labels = function(x) paste0(100 * x, "%"), breaks = seq(0, 1, 0.25), expand = expansion(mult = c(0, 0.02))) +
  labs(title = sprintf("Since January 2025, Governance & Safety (C) has %d of %d posts", sum(lab11$ici_primary[recent] == "C"), sum(recent)),
       subtitle = "Share of posts per ICI dimension by year. Segment labels = post counts (large segments only).",
       x = NULL, y = "Share of posts",
       caption = "Automated caption coding, codebook v1.1, provisional until hand-validated. Dec 2021 (two weeks at the scrape boundary) excluded.") +
  theme_ici() + guides(fill = guide_legend(nrow = 2))
save_chart(p_time, "content_share_over_time.png", w = 8, h = 5)

# ---- 6. Gap analysis: content share vs perception ---------------------------
# Expected file: data/survey_responses.csv, one row per respondent, columns
#   respondent_id, A1_visit, A2_culture, A3_plural, B1_stable, B2_business, B3_products,
#   C1_safe, C2_democratic, C3_regulations, info_source (optional)
# Item scores on the ICI answer scale. SET THE SCALE BELOW to the ICI questionnaire's own
# scale; it is deliberately left unset so no scale is assumed.
SURVEY_SCALE_MIN <- NA
SURVEY_SCALE_MAX <- NA
ITEMS <- list(A = c("A1_visit", "A2_culture", "A3_plural"),
              B = c("B1_stable", "B2_business", "B3_products"),
              C = c("C1_safe", "C2_democratic", "C3_regulations"))
survey_path <- file.path(DATA, "survey_responses.csv")
say("\n=== STEP 6: gap analysis ===")
content_side <- head_tab[head_tab$dimension %in% c("A","B","C"), c("dimension", "share", "n_posts", "n_total")]
perc <- NULL
if (file.exists(survey_path)) {
  if (is.na(SURVEY_SCALE_MIN) || is.na(SURVEY_SCALE_MAX))
    stop("survey_responses.csv found: set SURVEY_SCALE_MIN / SURVEY_SCALE_MAX to the ICI questionnaire scale first.")
  sv <- read.csv(survey_path, stringsAsFactors = FALSE)
  perc <- do.call(rbind, lapply(names(ITEMS), function(k) {
    m <- rowMeans(sv[ITEMS[[k]]], na.rm = TRUE); m <- m[is.finite(m)]
    data.frame(dimension = k, mean = mean(m), sd = sd(m), n_resp = length(m))
  }))
  say(sprintf("Survey responses: %d respondents.", nrow(sv)))
  say_tbl(perc)
  if ("info_source" %in% names(sv)) { say("Reported information source:"); say_tbl(table(sv$info_source)) }
  say("INDICATIVE ONLY. n this small supports no inference. The sample is self-selected at an Indonesian cultural event,",
      " the audience most favourably disposed to dimension A, so all perception means are biased upward and A most of all.",
      " No test, correlation or 'gap' statistic is computed: three dimensions are three data points.")
} else {
  say("No survey_responses.csv supplied: perception side left as a documented empty slot.")
}
gap <- rbind(data.frame(panel = "Content: share of posts", dimension = content_side$dimension,
                        value = content_side$share,
                        label = sprintf("%.0f%%\nn = %d", 100 * content_side$share, content_side$n_posts)),
             if (!is.null(perc)) data.frame(panel = "Perception: mean score (indicative only)", dimension = perc$dimension,
                                            value = (perc$mean - SURVEY_SCALE_MIN) / (SURVEY_SCALE_MAX - SURVEY_SCALE_MIN),
                                            label = sprintf("%.1f\nn = %d", perc$mean, perc$n_resp)))
gap$panel <- factor(gap$panel, c("Content: share of posts", "Perception: mean score (indicative only)"))
p_gap <- ggplot(gap, aes(dimension, value, fill = dimension)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = label), vjust = -0.25, size = 3.5, colour = "#0b0b0b", lineheight = 0.9) +
  facet_wrap(~panel, drop = FALSE) +
  scale_fill_manual(values = ICI_COLS, guide = "none") +
  scale_x_discrete(labels = c(A = "A\nCulture &\nTourism", B = "B\nEconomy &\nBusiness", C = "C\nGovernance\n& Safety")) +
  scale_y_continuous(limits = c(0, 1.12), labels = NULL, expand = expansion(mult = c(0, 0))) +
  labs(x = NULL, y = NULL,
       title = if (is.null(perc)) "Content side only: perception data not yet supplied"
               else "Content allocation beside perception: indicative only, no inference",
       subtitle = if (is.null(perc)) "Right panel is an intentionally empty slot for the in-person ICI responses."
                  else sprintf("Perception: n = %d self-selected respondents at an Indonesian cultural event (biased towards A).\nPerception bars rescaled to the answer scale; labels show raw means.", max(perc$n_resp)),
       caption = "Two panels, two different units: content share (%) and mean score are not on a common scale and are not compared numerically.") +
  theme_ici() + theme(panel.grid.major.y = element_blank(), strip.text = element_text(face = "bold", hjust = 0, size = 11))
if (is.null(perc))
  p_gap <- p_gap + geom_text(data = data.frame(panel = factor("Perception: mean score (indicative only)", levels(gap$panel)),
                                               dimension = "B", value = 0.5,
                                               label = "No survey data supplied.\nAdd data/survey_responses.csv\nand set the answer scale in analysis.R."),
                             aes(dimension, value, label = label), inherit.aes = FALSE, size = 3.5, colour = "#52514e")
save_chart(p_gap, "content_vs_perception.png", w = 9, h = 4.8)

# ---- 7. Visual system: dominant colours per post ----------------------------
# Needs the post images. Thumbnails are fetched from the Instagram CDN URLs in the scrape
# (these expire a few days after scraping) into data/images/<id>.jpg; any images already
# in that folder are used without downloading.
say("\n=== STEP 7: colour ===")
img_dir <- file.path(DATA, "images"); dir.create(img_dir, showWarnings = FALSE)
img_path <- file.path(img_dir, paste0(d$id, ".jpg"))
need <- which(!file.exists(img_path) & !blank(d$displayUrl))
if (length(need)) {
  probe <- vapply(head(need, 3), function(i)
    isTRUE(tryCatch(download.file(d$displayUrl[i], img_path[i], mode = "wb", quiet = TRUE) == 0, error = function(e) FALSE,
                    warning = function(w) FALSE)), TRUE)
  if (any(probe)) {
    for (i in need[-(1:3)]) tryCatch(download.file(d$displayUrl[i], img_path[i], mode = "wb", quiet = TRUE),
                                     error = function(e) NULL, warning = function(w) NULL)
  } else say("Image CDN unreachable from this machine, or URLs expired. Re-scrape, or run this script where instagram CDN hosts are reachable.")
}
read_img <- function(f) {
  sig <- readBin(f, "raw", 4)
  if (length(sig) < 4) return(NULL)
  tryCatch(if (sig[1] == as.raw(0x89)) png::readPNG(f) else jpeg::readJPEG(f), error = function(e) NULL)
}
dominant <- function(f, k = 5) {
  im <- read_img(f); if (is.null(im) || length(dim(im)) < 3) return(NULL)
  step <- max(1, floor(min(dim(im)[1:2]) / 80))         # ~80x80 pixel grid is enough for dominant colour
  px <- cbind(as.vector(im[seq(1, dim(im)[1], step), seq(1, dim(im)[2], step), 1]),
              as.vector(im[seq(1, dim(im)[1], step), seq(1, dim(im)[2], step), 2]),
              as.vector(im[seq(1, dim(im)[1], step), seq(1, dim(im)[2], step), 3]))
  lab <- grDevices::convertColor(px, from = "sRGB", to = "Lab")       # perceptual space: distances ~ visible difference
  set.seed(SEED); f_k <- kmeans(lab, centers = min(k, nrow(unique(round(lab)))), nstart = 3, iter.max = 50)
  cen <- f_k$centers[which.max(f_k$size), ]
  c(L = cen[[1]], a = cen[[2]], b = cen[[3]], weight = max(f_k$size) / nrow(lab))
}
have_img <- which(file.exists(img_path) & file.size(img_path) > 0)
d$dominant_hex <- NA_character_
if (length(have_img) >= 30) {
  dom <- do.call(rbind, lapply(have_img, function(i) { r <- dominant(img_path[i]); if (is.null(r)) NULL else c(i = i, r) }))
  idx <- dom[, "i"]; LAB <- dom[, c("L", "a", "b")]
  hex <- rgb(pmin(pmax(grDevices::convertColor(LAB, from = "Lab", to = "sRGB"), 0), 1))
  d$dominant_hex[idx] <- hex
  # Dispersion: mean CIE76 Delta E of each post's dominant colour from the account centroid,
  # and the median pairwise Delta E. Delta E ~2.3 is a just-noticeable difference.
  de_cent <- sqrt(rowSums(sweep(LAB, 2, colMeans(LAB))^2))
  pw <- as.vector(dist(LAB))
  say(sprintf("Images analysed: %d of %d posts.", nrow(LAB), nrow(d)))
  say(sprintf("Dispersion: mean Delta E to account centroid = %.1f; median pairwise Delta E = %.1f.", mean(de_cent), median(pw)))
  by_year <- tapply(de_cent, d$year[idx], function(x) sprintf("%.1f (n=%d)", mean(x), length(x)))
  say("Mean Delta E to centroid by year: ", paste(names(by_year), by_year, sep = ": ", collapse = "; "))
  # Account palette: cluster the dominant colours; k by silhouette
  dl <- dist(LAB); pk <- 2:10
  set.seed(SEED); pf <- lapply(pk, function(k) kmeans(LAB, k, nstart = 20))
  psil <- vapply(pf, function(f) mean(silhouette(f$cluster, dl)[, 3]), 0)
  pbest <- pf[[which.max(psil)]]
  pal_hex <- rgb(pmin(pmax(grDevices::convertColor(pbest$centers, from = "Lab", to = "sRGB"), 0), 1))
  say(sprintf("Account palette: k = %d (max silhouette %.2f). Cluster centres / share of posts: %s", pk[which.max(psil)], max(psil),
              paste(sprintf("%s %.0f%%", pal_hex, 100 * pbest$size / sum(pbest$size)), collapse = ", ")))
  say("No benchmark exists for these dispersion figures (no comparator account or brand specification was supplied); they are reported for repeat measurement, not judged against a norm.")
  strip <- data.frame(ts = d$ts[idx], hex = hex)[order(d$ts[idx]), ]
  strip$pos <- seq_len(nrow(strip))
  yr_breaks <- vapply(unique(format(strip$ts, "%Y")), function(y) min(strip$pos[format(strip$ts, "%Y") == y]), 0)
  p_strip <- ggplot(strip, aes(pos, 1, fill = hex)) + geom_tile(width = 1, height = 1) +
    scale_fill_identity() +
    scale_x_continuous(breaks = yr_breaks, labels = names(yr_breaks), expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    labs(title = sprintf("Dominant colour of every post, in date order (n = %d)", nrow(strip)),
         subtitle = sprintf("Mean Delta E from account centroid %.1f; largest palette cluster covers %.0f%% of posts.",
                            mean(de_cent), 100 * max(pbest$size) / sum(pbest$size)),
         x = NULL, y = NULL, caption = "One column per post (largest k-means colour cluster in CIELAB). Photographs carry the colours of their scenes, so this measures the grid as published, not a design intent.") +
    theme_ici() + theme(axis.text.y = element_blank(), panel.grid.major.y = element_blank())
  save_chart(p_strip, "colour_strip.png", w = 10, h = 2.6)
} else {
  say(sprintf("Colour analysis NOT run: %d images available (need >= 30). Documented empty step.", length(have_img)))
}

# ---- Output: every post with its labels and the features used ---------------
out <- data.frame(
  id = d$id, shortCode = d$shortCode, url = d$url, timestamp = format(d$ts, "%Y-%m-%d %H:%M:%S"), year = d$year,
  owner = d$ownerUsername, own_post = d$own_post, is_repost = d$is_repost, media_type = d$type,
  product_type = d$productType, language = d$language, n_words = d$n_words,
  ici_primary = lab11$ici_primary, ici_sub = lab11$ici_sub, ici_secondary = lab11$ici_secondary,
  rule_applied = lab11$rule_applied, hits_A = lab11$hits_A, hits_B = lab11$hits_B, hits_C = lab11$hits_C,
  terms_A = lab11$terms_A, terms_B = lab11$terms_B, terms_C = lab11$terms_C, terms_D = lab11$terms_D,
  ici_primary_v10 = lab10$ici_primary, ici_primary_threshold1 = lab11_t1$ici_primary,
  ici_primary_threshold3 = lab11_t3$ici_primary,
  cluster_kmeans = d$cluster_kmeans, cluster_hclust = d$cluster_hclust,
  dominant_hex = d$dominant_hex, in_validation_sample = seq_len(nrow(d)) %in% vs_idx,
  caption = d$caption, stringsAsFactors = FALSE)
write.csv(out, file.path(OUT, "labelled_posts.csv"), row.names = FALSE, fileEncoding = "UTF-8")
say("\n=== STEP 3 (continued): agreement check ===")
source(file.path(script_dir, "validation_kappa.R"))   # computes kappa if hand-coded files exist in data/
say(sprintf("\nDone. %d posts written to output/labelled_posts.csv; charts in charts/.", nrow(out)))
