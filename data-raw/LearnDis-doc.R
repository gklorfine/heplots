#' @name LearnDis
#' @aliases LearnDis
#' @docType data
#' @title
#' Reading and Arithmetic Achievement in Children with Learning Disabilities
#'
#' @description
#' A small factorial dataset from Tabachnick & Fidell (2013) relating a treatment/control intervention and
#' degree of disability to reading and arithmetic achievement test scores,
#' with IQ also recorded. It is not clear whether this is fictitious data or
#' derived from a real study.
#' 
#' It provides for simple examples of MANOVA, MANCOVA and stepdown analysis
#'
#' @usage data("LearnDis")
#' @format
#' A data frame with 18 observations on the following 5 variables, a
#' 3 (`Disability`) x 2 (`Treatment`) between-subjects factorial with
#' n = 3 per cell.
#' \describe{
#'   \item{`Disability`}{Degree of disability, an ordered factor with
#'     levels `Mild` < `Moderate` < `Severe`}
#'   \item{`Treatment`}{a factor with levels `Treatment` `Control`}
#'   \item{`WRAT_R`}{Wide Range Achievement Test, Reading subtest score,
#'     a numeric vector}
#'   \item{`WRAT_A`}{Wide Range Achievement Test, Arithmetic subtest
#'     score, a numeric vector}
#'   \item{`IQ`}{IQ score, a numeric vector -- used in the source as a
#'     MANCOVA covariate, not part of the stepdown analysis itself}
#' }
#'
#' @source
#' Tabachnick, B. G., & Fidell, L. S. (2013). *Using Multivariate
#' Statistics* (6th ed.). Pearson. Table 7.1, p.256.
#'
#' @references
#' The Roy-Bargmann stepdown analysis of this data (WRAT-R prioritized
#' over WRAT-A) appears in the same source, §7.5.3.2, Tables 7.7-7.9,
#' pp.273-274.
#'
#' Roy, S. N. (1958). Step-Down Procedure in Multivariate Analysis.
#' *The Annals of Mathematical Statistics*, 29(4), 1177-1187.
#' \doi{10.1214/aoms/1177706449}.
#'
#' @keywords datasets
#' @concept MANOVA
#' @concept MANCOVA
#' @concept "stepdown analysis"
#'
#' @examples
#' data(LearnDis)
#' str(LearnDis)
#'
#' ld.mod <- lm(cbind(WRAT_R, WRAT_A) ~ Disability * Treatment, data = LearnDis)
#' car::Anova(ld.mod)
#'
#' heplot(ld.mod, fill = TRUE, fill.alpha = 0.1)
#'
#' # Roy-Bargmann stepdown: does WRAT-A add anything to WRAT-R for the
#' # Treatment effect? 
#' # Needs Type III SS, since the WRAT_R covariate breaks the balanced
#' # factorial's orthogonality:
#' options(contrasts = c("contr.sum", "contr.poly"))
#' step2.mod <- lm(WRAT_A ~ WRAT_R + Disability * Treatment, data = LearnDis)
#' car::Anova(step2.mod, type = "III")
#'
NULL
