#' @name ReadingDisability
#' @aliases ReadingDisability
#' @docType data
#' @title
#' Cognitive and Achievement Test Scores by Reading Level
#'
#' @description
#' Six cognitive/achievement test scores for children classified into four
#' reading-achievement groups (`Severe`, `Mild`, `Average`, `Superior`),
#' reconstructed from the group means, standard deviations, and pooled
#' within-cells correlations reported as a worked "real data example" in
#' Bray & Maxwell (1985), Table 2.3.
#'
#' Individual rows are **simulated**, not the original observations: only
#' group-level summary statistics were published, with no raw data and no
#' per-group correlations (a single correlation matrix, pooled across all
#' four groups, was reported). Each group was drawn from a multivariate
#' normal with that group's reported means and a covariance matrix built
#' from that group's reported SDs combined with the pooled correlations,
#' then forced to match those exact moments via
#' `MASS::mvrnorm(..., empirical = TRUE)`. Summarizing this data frame by
#' `Group` exactly reproduces Bray & Maxwell's Table 2.3 (see
#' `data-raw/ReadingDisability.R`).
#'
#' B&M (p.38) describe the six measures as follows: "The PPVT is a general
#' verbal measure of IQ, whereas the VF and SIM tests are verbal criteria.
#' The EF taps higher-order nonverbal abilities, whereas the VMI and RD
#' are general nonverbal measures."
#'
#' @usage data("ReadingDisability")
#' @format
#' A data frame with 571 observations on the following 7 variables, a
#' 4-level between-subjects factor (`Group`) with unequal n.
#' \describe{
#'   \item{`Group`}{Reading achievement level, an ordered factor with
#'     levels (worst to best) `Severe` (n = 93) < `Mild` (n = 113) <
#'     `Average` (n = 274) < `Superior` (n = 91)}
#'   \item{`PPVT`}{Peabody Picture Vocabulary Test score -- a general
#'     verbal measure of IQ, numeric}
#'   \item{`RD`}{Recognition-Discrimination Test score -- a general
#'     nonverbal measure, numeric}
#'   \item{`EF`}{Embedded Figures Test score -- taps higher-order
#'     nonverbal abilities, numeric}
#'   \item{`VF`}{Verbal Fluency Test score -- a verbal criterion measure,
#'     numeric}
#'   \item{`VMI`}{Beery Visual-Motor Integration Test score -- a general
#'     nonverbal measure, numeric}
#'   \item{`SIM`}{Similarities subtest of the Wechsler Preschool and
#'     Primary Scale of Intelligence (WPPSI) score -- a verbal criterion
#'     measure, numeric}
#' }
#'
#' @source
#' Bray, J. H., & Maxwell, S. E. (1985). *Multivariate Analysis of
#' Variance*. Sage. Table 2.3, p.38, "Means, Standard Deviations, and
#' Within-Cells Correlations for Real Data Example."
#'
#' B&M attribute this table to Fletcher, J. M., & Satz, P. (1980), but
#' **that reference does not appear in B&M's own References section** --
#' a gap in the source book, not (so far as we can tell) a typo on our
#' part. A copy of Fletcher, J. M., & Satz, P. (1980), *Developmental
#' changes in the neuropsychological correlates of reading achievement:
#' A six-year longitudinal follow-up*, Journal of Clinical Neuropsychology,
#' 2(1), 23-37, is available, but its own reported variables differ from
#' the six tabulated here -- so it is not confirmed to be the exact source
#' of Table 2.3, only the most likely candidate (same authors, matching
#' year, matching four-group reading-disability design). Treat the B&M
#' attribution as unresolved pending a source that actually contains these
#' six measures.
#'
#' @keywords datasets
#' @concept MANOVA
#' @concept HE plots
#'
#' @examples
#' data(ReadingDisability)
#' str(ReadingDisability)
#'
#' rd.mod <- lm(cbind(PPVT, RD, EF, VF, VMI, SIM) ~ Group,
#'              data = ReadingDisability)
#' car::Anova(rd.mod)
#'
#' heplot(rd.mod, fill = TRUE, fill.alpha = 0.1)
#'
NULL
