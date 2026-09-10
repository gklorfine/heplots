# Build script for the ReadingDisability dataset.
#
# Source: Table 2.3 in Bray, J. H., & Maxwell, S. E. (1985). Multivariate
# Analysis of Variance. Sage. "Means, Standard Deviations, and Within-Cells
# Correlations for Real Data Example", p.38. B&M attribute the data to
# Fletcher, J. M., & Satz, P. (1977), but the paper we actually have (at
# C:\Dropbox\Documents\papers\Fletcher-Satz-1980.pdf -- Fletcher, J. M., &
# Satz, P. (1980). Developmental changes in the neuropsychological
# correlates of reading achievement: A six-year longitudinal follow-up.
# Journal of Clinical Neuropsychology, 2(1), 23-37) uses different
# variables than B&M tabulate. Likely B&M cite an earlier (1977) draft/
# report version of the same longitudinal project; B&M's Table 2.3 is the
# only source we have for these particular six measures on four
# reading-level groups. See dev/Roy-Bargmann.md.
#
# Only group-level summary statistics were published: means, SDs per
# group, and a single *pooled* (i.e. average within-cells/error) 6x6
# correlation matrix -- not per-group correlations, and no raw data. So
# there is no way to recover the original 571 individual cases exactly.
#
# Instead we simulate each group from a multivariate normal with
# mean = that group's reported means, and covariance built from that
# group's own SDs combined with the *pooled* correlation matrix (the same
# R applied to every group, since that's all that was reported):
#   Sigma_g = D_g %*% R %*% D_g
# and then force each group's simulated sample to match those target
# moments *exactly* via MASS::mvrnorm(..., empirical = TRUE). The
# resulting ReadingDisability data frame therefore reproduces B&M's
# Table 2.3 exactly (up to floating point) when summarized by Group --
# but the individual rows are synthetic, not the original observations.

library(MASS)

vars <- c("PPVT", "RD", "EF", "VF", "VMI", "SIM")
groups <- c("Severe", "Mild", "Average", "Superior")
Ns <- c(Severe = 93, Mild = 113, Average = 274, Superior = 91)

means <- rbind(
  Severe   = c(PPVT =  97.18, RD = 11.97, EF =  9.37, VF = 28.39, VMI = 74.25, SIM = 15.55),
  Mild     = c(PPVT = 103.19, RD = 13.17, EF = 11.84, VF = 31.85, VMI = 83.04, SIM = 16.97),
  Average  = c(PPVT = 107.88, RD = 13.54, EF = 12.76, VF = 34.31, VMI = 89.42, SIM = 17.79),
  Superior = c(PPVT = 121.87, RD = 14.12, EF = 14.21, VF = 39.74, VMI = 96.32, SIM = 19.18)
)

sds <- rbind(
  Severe   = c(PPVT = 11.19, RD = 1.96, EF = 2.95, VF =  6.97, VMI = 11.20, SIM = 2.94),
  Mild     = c(PPVT = 12.88, RD = 1.32, EF = 2.31, VF =  8.03, VMI = 17.63, SIM = 2.29),
  Average  = c(PPVT = 14.70, RD = 1.41, EF = 2.32, VF =  7.69, VMI = 17.71, SIM = 1.97),
  Superior = c(PPVT = 37.69, RD = 2.03, EF = 3.10, VF = 10.12, VMI = 20.59, SIM = 1.50)
)

# Pooled within-cells correlations -- applied identically to every group,
# since that is the only correlation structure B&M report.
R <- matrix(
  c(1.00, 0.42, 0.42, 0.08, 0.04, 0.17,
    0.42, 1.00, 0.52, 0.07, 0.22, 0.15,
    0.42, 0.52, 1.00, 0.15, 0.32, 0.19,
    0.08, 0.07, 0.15, 1.00, 0.09, 0.22,
    0.04, 0.22, 0.32, 0.09, 1.00, 0.08,
    0.17, 0.15, 0.19, 0.22, 0.08, 1.00),
  nrow = 6, dimnames = list(vars, vars)
)

set.seed(42)

sim_group <- function(group) {
  mu <- means[group, ]
  D <- diag(sds[group, ])
  Sigma <- D %*% R %*% D
  dimnames(Sigma) <- list(vars, vars)
  X <- mvrnorm(n = Ns[group], mu = mu, Sigma = Sigma, empirical = TRUE)
  data.frame(Group = group, X)
}

ReadingDisability <- do.call(rbind, lapply(groups, sim_group))
ReadingDisability$Group <- factor(ReadingDisability$Group, levels = groups,
                                   ordered = TRUE)
rownames(ReadingDisability) <- NULL

str(ReadingDisability)

# --- Verification against B&M Table 2.3 -------------------------------

# Per-group means, SDs, and correlations should reproduce the table exactly
for (g in groups) {
  Xg <- ReadingDisability[ReadingDisability$Group == g, vars]
  cat("\n--", g, "(N =", nrow(Xg), ") --\n")
  cat("means:", round(colMeans(Xg), 2), "\n")
  cat("SDs:  ", round(sqrt(diag(cov(Xg))), 2), "\n")
}

cat("\nPer-group correlations should all equal the pooled R above:\n")
print(round(cor(ReadingDisability[ReadingDisability$Group == "Average", vars]), 2))

# Overall (total-sample) means/SDs should be close to B&M's "Overall Means"
# column (107.44, 13.30, 12.26, 33.73, 86.78, 17.48 / 20.85, 1.73, 2.94,
# 8.73, 18.57, 2.41) -- these differ slightly from a simple weighted
# average of group SDs because they include between-group variance too.
cat("\nOverall means:\n")
print(round(colMeans(ReadingDisability[vars]), 2))
cat("\nOverall SDs:\n")
print(round(sapply(ReadingDisability[vars], sd), 2))

save(ReadingDisability, file = "data-raw/ReadingDisability.RData")
