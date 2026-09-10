# DONE: checked 2026-09-08 that dominanceAnalysis() cannot take a fitted mlm object
#       directly; this script uses the mlmWithCov() role-flip instead (see
#       dev/variable-importance.md, "Software support -- checked empirically")
# TODO: once RoyBargmann() exists (dev/Roy-Bargmann.md), compare its stepdown F's /
#       lambdas against the per-DV importance weights computed here on the same data

library(dominanceanalysis)
library(heplots)

data(NeuroCog)
NeuroCog <- na.omit(NeuroCog)

dvs <- c("Speed", "Attention", "Memory", "Verbal", "Visual", "ProbSolv", "SocialCog")

# Overall MANOVA, for reference / sanity-check target
mlm_fit <- lm(reformulate("Dx", response = sprintf("cbind(%s)", paste(dvs, collapse = ", "))),
              data = NeuroCog)
cat("=== Overall MANOVA (car::Anova) ===\n")
print(car::Anova(mlm_fit))

# Tonidandel & LeBreton (2013) role-flip: DVs become the "predictor" (X) side,
# dummy-coded group membership becomes the multivariate "criterion" (Y) side.
dx_dummy <- model.matrix(~ Dx, data = NeuroCog)[, -1, drop = FALSE]
colnames(dx_dummy) <- c("Dx2", "Dx3")

df <- cbind(as.data.frame(dx_dummy), NeuroCog[dvs])
cor_m <- cor(df)

f <- reformulate(dvs, response = "cbind(Dx2, Dx3)")
lwith <- mlmWithCov(f, cor_m)
cat("\n=== Multivariate fit index (Cramer & Nicewander) ===\n")
cat(glue::glue("r.squared.xy = {round(lwith$r.squared.xy, 4)}  (cf. Pillai's trace above)"), "\n")
cat(glue::glue("p.squared.yx = {round(lwith$p.squared.yx, 4)}"), "\n")

da <- dominanceAnalysis(lwith)
cat("\n=== Per-DV importance (dominance analysis) ===\n")
print(summary(da))
