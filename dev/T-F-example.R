# DONE: Data entry + MLM + HE plot for Tabachnick & Fidell (2013) worked
#       stepdown example (Table 7.1, p.256). See dev/RB-SAS-SPSS.md §3 for
#       the full citation and the published ANOVA/ANCOVA tables this script
#       checks against.
# TODO: 🚩 Once RoyBargmann() exists (see dev/Roy-Bargmann.md), replace the
#       manual step-2 ANCOVA below with RoyBargmann(cbind(WRAT_R, WRAT_A) ~
#       D * T, data = tf) and confirm it reproduces the same stepdown F.

library(heplots)
library(car)
library(glue)

# DONE: ✔️ Type III SS with sum-to-zero contrasts is required to reproduce
#       T&F's Table 7.9 ANCOVA -- adding the WRAT_R covariate breaks the
#       orthogonality of the balanced D*T factorial, so Type I (sequential)
#       SS no longer matches (confirmed empirically: Type I gives a huge,
#       wrong covariate SS of ~2084 vs T&F's 1.77). Type I is still fine,
#       and matches Type II/III exactly, for the two *balanced*, no-covariate
#       models in steps 1 and the plain (non-stepdown) WRAT-A ANOVA below.
options(contrasts = c("contr.sum", "contr.poly"))

# ---------------------------------------------------------------------------
# 1. Data: Tabachnick & Fidell (2013), Table 7.1, p.256
#    3 (D: Mild/Moderate/Severe) x 2 (T: Treatment/Control) factorial,
#    n = 3/cell, N = 18. Triples per subject are (WRAT_R, WRAT_A, IQ).
# ---------------------------------------------------------------------------

tf <- data.frame(
  D = factor(
    rep(rep(c("Mild", "Moderate", "Severe"), each = 3), times = 2),
    levels = c("Mild", "Moderate", "Severe")
  ),
  T = factor(
    rep(c("Treatment", "Control"), each = 9),
    levels = c("Treatment", "Control")
  ),
  WRAT_R = c(
    115, 98, 107,   100, 105, 95,   89, 100, 90,   # Treatment: Mild, Moderate, Severe
    90, 85, 80,     70, 85, 78,     65, 80, 72     # Control:   Mild, Moderate, Severe
  ),
  WRAT_A = c(
    108, 105, 98,   105, 95, 98,    78, 85, 95,
    92, 95, 81,     80, 68, 82,     62, 70, 73
  ),
  IQ = c(
    110, 102, 100,  115, 98, 100,   99, 102, 100,
    108, 115, 95,   100, 99, 105,   101, 95, 102
  )
)

cat(glue("Tabachnick & Fidell Table 7.1 data: {nrow(tf)} rows, {nlevels(tf$D)} x {nlevels(tf$T)} design"), "\n\n")
print(tf)

# Sanity check: cell means should match what T&F report for WRAT-R (Table 7.3-ish)
cat("\nCell means (D x T):\n")
print(aggregate(cbind(WRAT_R, WRAT_A, IQ) ~ D + T, data = tf, FUN = mean))

# ---------------------------------------------------------------------------
# 2. Fit the MLM and get the overall MANOVA
# ---------------------------------------------------------------------------

mlm_fit <- lm(cbind(WRAT_R, WRAT_A) ~ D * T, data = tf)

cat("\n--- Overall MANOVA (Type III) ---\n")
print(car::Anova(mlm_fit, type = "III"))

# ---------------------------------------------------------------------------
# 3. Univariate ANOVAs -- compare against T&F Table 7.7 (WRAT-R) and
#    Table 7.8 (WRAT-A, ignoring WRAT-R)
# ---------------------------------------------------------------------------

cat("\n--- Step 1: univariate ANOVA of WRAT-R (cf. Table 7.7, p.273) ---\n")
aov_r <- aov(WRAT_R ~ D * T, data = tf)
print(summary(aov_r))

cat("\n--- Plain univariate ANOVA of WRAT-A, ignoring WRAT-R (cf. Table 7.8) ---\n")
aov_a <- aov(WRAT_A ~ D * T, data = tf)
print(summary(aov_a))

# T&F report F(1,12) = 46.1225 for T on WRAT-R, and F(1,12) = 33.2460 for T
# on WRAT-A (plain, unadjusted). Check both to a few decimals.
F_r_T <- summary(aov_r)[[1]]["T", "F value"]
F_a_T_plain <- summary(aov_a)[[1]]["T", "F value"]
stopifnot(
  isTRUE(all.equal(F_r_T, 46.1225, tolerance = 1e-3)),
  isTRUE(all.equal(F_a_T_plain, 33.2460, tolerance = 1e-3))
)
cat("\n", glue("Reproduced: F(WRAT-R, T) = {round(F_r_T, 4)}, F(WRAT-A plain, T) = {round(F_a_T_plain, 4)}"), "\n", sep = "")

# ---------------------------------------------------------------------------
# 4. Step 2: the stepdown ANCOVA of WRAT-A on WRAT-R -- cf. Table 7.9, p.274.
#    This is exactly RoyBargmann()'s step-2 model, done by hand for now.
#    Needs Type III SS (see note on `options(contrasts=...)` above) --
#    car::Anova() rather than aov()/summary(), since aov() only gives
#    Type I sequential SS.
# ---------------------------------------------------------------------------

cat("\n--- Step 2: ANCOVA of WRAT-A on WRAT-R (stepdown step, cf. Table 7.9) ---\n")
lm_a_stepdown <- lm(WRAT_A ~ WRAT_R + D * T, data = tf)
stepdown_tab <- car::Anova(lm_a_stepdown, type = "III")
print(stepdown_tab)

F_a_T_stepdown <- stepdown_tab["T", "F value"]
df2_stepdown <- stepdown_tab["Residuals", "Df"]
stopifnot(isTRUE(all.equal(unname(F_a_T_stepdown), 5.4903, tolerance = 1e-3)))
cat("\n", glue(
  "Reproduced stepdown F(WRAT-A | WRAT-R, T) = {round(F_a_T_stepdown, 4)} ",
  "(T&F report 5.4903 on df 1, 11)"
), "\n", sep = "")

# lambda_2 from the stepdown F, and the product lambda_1 * lambda_2 should
# equal the overall Wilks' Lambda for the T effect (dev/Roy-Bargmann.md,
# "The Lambda-product identity" section)
df1_T <- 1
df2_1_T <- summary(aov_r)[[1]]["Residuals", "Df"]
lambda1_T <- 1 / (1 + (df1_T / df2_1_T) * F_r_T)
lambda2_T <- 1 / (1 + (df1_T / df2_stepdown) * F_a_T_stepdown)

cat("\n", glue(
  "Stepdown lambdas for T: lambda_1 = {round(lambda1_T, 4)}, ",
  "lambda_2 = {round(lambda2_T, 4)}, product = {round(lambda1_T * lambda2_T, 4)}"
), "\n", sep = "")

# `car::Anova(mlm_fit, type = "III")` returns a lazy "Anova.mlm" object (see
# dev/RB-SAS-SPSS.md/Roy-Bargmann.md notes on this) -- SSP/SSPE only, no
# data.frame to index into. summary() is what actually computes the
# per-term Wilks/Pillai/etc. statistics.
cat("Compare product above to the Wilks statistic for T in the overall MANOVA:\n")
print(summary(car::Anova(mlm_fit, type = "III"))$multivariate.tests$T)

# ---------------------------------------------------------------------------
# 5. HE plots
# ---------------------------------------------------------------------------

heplot(
  mlm_fit,
  main = "Tabachnick & Fidell (2013) Table 7.1: WRAT-R vs WRAT-A",
  fill = TRUE, fill.alpha = 0.1
)

# The Treatment effect is the one that survives stepdown for WRAT-R but not
# WRAT-A (per T&F's interpretation) -- isolate it
heplot(
  mlm_fit,
  terms = "T",
  main = "Treatment effect only",
  fill = TRUE, fill.alpha = 0.1
)
