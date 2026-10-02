# =============================================================================
# Agreement between the hand-coded validation sample and the automated labels.
#
# HOW TO USE
#   1. Open output/validation_sample.csv. For each row, read the caption (and open the
#      url to see the visual), apply codebook.md, and fill in human_label (A/B/C/D/U)
#      and optionally human_sub (A1..D6). Do NOT look up the automated label first.
#   2. Save the filled file as data/validation_hand_coded.csv
#      (optionally also data/validation_supplement_hand_coded.csv from validation_supplement.csv).
#   3. Run:  Rscript ici_analysis/validation_kappa.R      (or the full analysis.R, which sources this)
#
# Until step 3 has been run, every automated label and every share built on it is PROVISIONAL.
# =============================================================================

# Cohen's kappa with an asymptotic SE (Fleiss, Cohen & Everitt 1969) and a bootstrap CI.
cohen_kappa <- function(a, b, levels = c("A", "B", "C", "D", "U"), boot = 2000, seed = 20261002) {
  a <- factor(a, levels); b <- factor(b, levels)
  ok <- !is.na(a) & !is.na(b); a <- a[ok]; b <- b[ok]
  k_of <- function(a, b) {
    t <- table(a, b) / length(a); po <- sum(diag(t)); pe <- sum(rowSums(t) * colSums(t))
    if (pe == 1) return(NA_real_); (po - pe) / (1 - pe)
  }
  t <- table(a, b) / length(a); n <- length(a)
  po <- sum(diag(t)); pr <- rowSums(t); pc <- colSums(t); pe <- sum(pr * pc)
  kappa <- (po - pe) / (1 - pe)
  # Asymptotic SE under the alternative (Fleiss et al. 1969)
  A1 <- sum(diag(t) * (1 - (pr + pc) * (1 - kappa))^2)
  off <- t; diag(off) <- 0
  B1 <- (1 - kappa)^2 * sum(off * outer(pc, pr, "+")^2)
  C1 <- (kappa - pe * (1 - kappa))^2
  se <- sqrt(max(A1 + B1 - C1, 0) / (n * (1 - pe)^2))
  set.seed(seed)
  bs <- replicate(boot, { i <- sample.int(n, n, replace = TRUE); k_of(a[i], b[i]) })
  list(n = n, observed_agreement = po, kappa = kappa, se = se,
       ci_asymptotic = kappa + c(-1.96, 1.96) * se,
       ci_bootstrap = quantile(bs, c(0.025, 0.975), na.rm = TRUE),
       confusion = table(human = a, auto = b))
}

report_kappa <- function(hand_file, labelled_file, title, say = function(...) cat(..., "\n", sep = "")) {
  h <- read.csv(hand_file, stringsAsFactors = FALSE, colClasses = c(id = "character"))
  l <- read.csv(labelled_file, stringsAsFactors = FALSE, colClasses = c(id = "character"))
  h$human_label <- toupper(trimws(h$human_label))
  h <- h[h$human_label %in% c("A", "B", "C", "D", "U"), ]
  if (nrow(h) == 0) { say(title, ": no hand codes filled in yet."); return(invisible(NULL)) }
  m <- merge(h[, c("id", "human_label")], l[, c("id", "ici_primary", "ici_primary_v10")], by = "id")
  for (v in c("ici_primary", "ici_primary_v10")) {
    k <- cohen_kappa(m$human_label, m[[v]])
    say(sprintf("%s | automated = %s | n = %d | agreement = %.0f%% | Cohen's kappa = %.2f (95%% CI asymptotic %.2f to %.2f; bootstrap %.2f to %.2f)",
                title, if (v == "ici_primary") "v1.1" else "v1.0", k$n, 100 * k$observed_agreement, k$kappa,
                k$ci_asymptotic[1], k$ci_asymptotic[2], k$ci_bootstrap[1], k$ci_bootstrap[2]))
    if (v == "ici_primary") {
      print(k$confusion)
      cm <- k$confusion
      pr <- diag(cm) / pmax(colSums(cm), 1); rc <- diag(cm) / pmax(rowSums(cm), 1)
      say("  Per label: precision (of posts the machine put here, share the human agrees) / recall (of posts the human put here, share the machine found):")
      for (lv in rownames(cm)) if (rowSums(cm)[lv] + colSums(cm)[lv] > 0)
        say(sprintf("    %s  precision %s (n=%d)  recall %s (n=%d)", lv,
                    ifelse(colSums(cm)[lv] > 0, sprintf("%.0f%%", 100 * pr[lv]), "-"), colSums(cm)[lv],
                    ifelse(rowSums(cm)[lv] > 0, sprintf("%.0f%%", 100 * rc[lv]), "-"), rowSums(cm)[lv]))
    }
  }
  say("  Reading guide (Landis & Koch): <0.20 slight, 0.21-0.40 fair, 0.41-0.60 moderate, 0.61-0.80 substantial, >0.80 almost perfect.")
  say("  With n = 30 the CI is wide (typically +/- 0.2); a label with fewer than 5 cases in the sample has no meaningful per-label estimate.")
  invisible(m)
}

# Run whichever hand-coded files exist
local({
  base <- if (exists("script_dir")) script_dir else {
    a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
    if (length(a)) dirname(normalizePath(sub("^--file=", "", a[1]))) else getwd()
  }
  sayf <- if (exists("say")) say else function(...) cat(..., "\n", sep = "")
  lab <- file.path(base, "output", "labelled_posts.csv")
  files <- c(`Random sample (30)` = file.path(base, "data", "validation_hand_coded.csv"),
             `B/C supplement (20)` = file.path(base, "data", "validation_supplement_hand_coded.csv"))
  found <- FALSE
  for (nm in names(files)) if (file.exists(files[[nm]]) && file.exists(lab)) {
    found <- TRUE; report_kappa(files[[nm]], lab, nm, sayf)
  }
  if (!found) sayf("Validation: no hand-coded file in data/ yet -> all automated labels are PROVISIONAL.")
})
