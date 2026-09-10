# Build script for the LearnDis dataset.
#
# Source: Tabachnick, B. G., & Fidell, L. S. (2013). Using Multivariate
# Statistics (6th ed.). Pearson. Table 7.1, p.256 -- the running
# small-sample example used throughout Chapter 7 ("Multivariate Analysis
# of Variance and Covariance") for MANOVA, MANCOVA, and (the reason this
# is being added) Roy-Bargmann stepdown analysis.
#
# See dev/Roy-Bargmann.md and dev/RB-SAS-SPSS.md for the background on why
# this data matters to heplots (a citable, hand-checkable stepdown-analysis
# example), and dev/T-F-example.R for a script that reproduces T&F's
# Tables 7.7-7.9 numbers exactly from this data as a validation check.
#
# Renamed columns from T&F's own `D`/`T` to `Disability`/`Treatment` here
# (descriptive names, and `T` as a column name shadows base R's `T`/`TRUE`
# alias -- fine inside a formula's data argument, which is all dev/
# T-F-example.R does with it, but a bad habit for a dataset going into the
# package proper).

LearnDis <- data.frame(
  Disability = factor(
    rep(rep(c("Mild", "Moderate", "Severe"), each = 3), times = 2),
    levels = c("Mild", "Moderate", "Severe"),
    ordered = TRUE
  ),
  Treatment = factor(
    rep(c("Treatment", "Control"), each = 9),
    levels = c("Treatment", "Control")
  ),
  WRAT_R = c(
    115, 98, 107,   100, 105, 95,   89, 100, 90,
    90, 85, 80,     70, 85, 78,     65, 80, 72
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

str(LearnDis)

save(LearnDis, file = "data-raw/LearnDis.RData")

# use_data_doc(LearnDis, "data-raw/LearnDis-doc.R")  # personal helper, not
# available here -- data-raw/LearnDis-doc.R was drafted by hand instead,
# matching the style of data-raw/Over-doc.R.
