# Notes: How SAS/SPSS Handle Roy-Bargmann Stepdown, and a Worked Example

## Goal

Companion to `dev/Roy-Bargmann.md` (which works out the statistical
derivation and an `RoyBargmann()` implementation sketch). That note settled
the theory; this one is about the practical/reporting side -- what existing
software actually does, how results get written up, and a citable worked
numeric example to validate the R implementation against once it exists.

Findings below are from web research (2026-09-09) -- citations included
throughout since this is meant to be pasted into `@references` blocks,
vignette text, or a paper later, not just a summary.

---

## 1. SPSS

Only the **legacy `MANOVA` command** supports this -- the modern `GLM`
procedure does not.

* Syntax: `PRINT=SIGNIF(STEPDOWN)`, one of the keywords under `SIGNIF` on
  the `PRINT` subcommand:
  `SIGNIF([MULTIV] [EIGEN] [DIMENR] [UNIV] [HYPOTH] [STEPDOWN] [BRIEF])`.
  Source: IBM SPSS Statistics docs, *MANOVA: Multivariate command, SIGNIF
  keyword* --
  <https://www.ibm.com/docs/SSLVMB_sub/statistics_reference_project_ddita/spss/advanced/syn_manova_multivariate_signif.html>
* IBM's own one-line description (verbatim): **"STEPDOWN: Roy-Bargmann
  stepdown F tests."** Sibling keywords on the same page: `MULTIV`
  (multivariate F tests for group differences, default), `UNIV` (univariate
  F tests, default), `EIGEN` (eigenvalues of $S_h S_e^{-1}$), `DIMENR`
  (dimension-reduction analysis), `HYPOTH` (hypothesis SSCP matrix), `BRIEF`
  (abbreviated ANOVA-style table using Wilks' approximate F -- overrides
  other `SIGNIF` specs).
* Corroborated independently by Tabachnick & Fidell (2013, 6th ed., p.274,
  footnote 12; full citation in §3 below): *"A full stepdown analysis is
  produced as an option through IBM SPSS MANOVA."*

**Not resolved**: the exact column-header layout of the printed `STEPDOWN`
table itself (e.g. whether it literally prints "Hyp. DF / Error DF / F /
Sig. of F" per row, in that order). The IBM knowledge-base page already
cited in `Roy-Bargmann.md`
(<https://www.ibm.com/support/pages/where-are-roy-bargman-stepdown-tests>)
is login-gated and no rendered sample output was found elsewhere. Tabachnick
& Fidell don't reproduce the SPSS table verbatim either -- only the by-hand
equivalent (§3). If we want the literal SPSS column layout later, the way to
get it is to actually run `MANOVA ... /PRINT=SIGNIF(STEPDOWN)` in a licensed
SPSS session, not further web search.

---

## 2. SAS

**Confirmed: no built-in SAS procedure or option** for Roy-Bargmann
stepdown, in `PROC GLM`, `PROC ANOVA`, `PROC DISCRIM`, `PROC CANDISC`, or
`PROC STEPDISC`.

Direct primary-source confirmation: Finch, W. H. (2007). Performance of the
Roy-Bargmann Stepdown Procedure as a Follow Up to a Significant MANOVA.
*Multiple Linear Regression Viewpoints*, 33(1), 12-22. Open PDF:
<http://www.glmj.org/archives/MLRV_2007_33_1.pdf>. Methodology section,
p.16: **"All simulations were conducted using SAS IML and PROC GLM."** --
i.e. even a peer-reviewed methodological study of this exact procedure had
to hand-roll it via SAS IML (matrix language) driving repeated `PROC GLM`
calls. There is no packaged SAS stepdown procedure, and no SAS
Institute-published macro or technical note for it was found either -- this
appears to be a genuine gap in SAS, not just an under-documented feature.

### Side finding worth carrying into the package docs

Finch (2007)'s simulation found the stepdown procedure's Type I error rate
for variables *after* the first in the sequence is **badly inflated** under
non-normality combined with heterogeneous covariance matrices (observed
rates up to .87 against a nominal .05). His recommendation: stepdown
analysis is fine as an *omnibus* multivariate follow-up test, but using it
to pinpoint *which* variable(s) differ needs caution under those conditions.
Worth a `@references` citation and a caveat sentence in `RoyBargmann()`'s
documentation (e.g. in `@details` or a "Warning" section) -- flagging here
so it isn't lost before the function is actually written.

---

## 3. Worked numerical example (full, citable, reconstructable)

Tabachnick, B. G., & Fidell, L. S. (2013). *Using Multivariate Statistics*
(6th ed.). Pearson. ISBN 978-0-205-89081-1. Chapter 7 ("Multivariate
Analysis of Variance and Covariance"), §7.5.3.2 "Roy-Bargmann Stepdown
Analysis" (p.273), applied to the chapter's running small-sample example
(§7.4.1, Table 7.1, p.256; computer output §7.4.2, Tables 7.3-7.5,
pp.263-265).

**Design**: 3x2 between-subjects factorial, $n=3$/cell, $N=18$. Factor D =
Degree of disability (Mild / Moderate / Severe, df=2), Factor T = Treatment
(Treatment / Control, df=1). Two DVs: WRAT-R (reading) and WRAT-A
(arithmetic), from the Wide Range Achievement Test; IQ is also recorded but
is used later in the chapter as a MANCOVA covariate, not part of the
stepdown itself.

**Raw data** (Table 7.1, p.256 -- triples are WRAT-R, WRAT-A, (IQ)):

| | Mild | Moderate | Severe |
|---|---|---|---|
| Treatment | 115,108,(110)<br>98,105,(102)<br>107,98,(100) | 100,105,(115)<br>105,95,(98)<br>95,98,(100) | 89,78,(99)<br>100,85,(102)<br>90,95,(100) |
| Control | 90,92,(108)<br>85,95,(115)<br>80,81,(95) | 70,80,(100)<br>85,68,(99)<br>78,82,(105) | 65,62,(101)<br>80,70,(95)<br>72,73,(102) |

**Priority order**: WRAT-R first ("reading problems represent the most
common presenting symptom for learning disabled children" -- T&F's
rationale, substantive not statistical), WRAT-A second. This matches the
requirement already established in `Roy-Bargmann.md` that the ordering must
come from outside the data.

**Step 1 -- univariate ANOVA of WRAT-R** (Table 7.7, p.273):

| Source | SS | df | MS | F |
|---|---|---|---|---|
| D | 520.7778 | 2 | 260.3889 | 5.7439 |
| T | 2090.8889 | 1 | 2090.8889 | 46.1225 |
| DT | 2.1111 | 2 | 1.0556 | 0.0233 |
| S(DT) | 544.0000 | 12 | 45.3333 | |

**Step 2 -- ANCOVA of WRAT-A on WRAT-R (the stepdown step)** (Table 7.9,
p.274):

| Source | SS | df | MS | F |
|---|---|---|---|---|
| Covariate (WRAT-R) | 1.7665 | 1 | 1.7665 | 0.0361 |
| D | 538.3662 | 2 | 269.1831 | 5.5082 |
| T | 268.3081 | 1 | 268.3081 | **5.4903** |
| DT | 52.1344 | 2 | 26.0672 | 0.5334 |
| S(DT) | 537.5668 | 11 | 48.8679 | |

For contrast, T&F also give the plain univariate ANOVA of WRAT-A *ignoring*
WRAT-R (Table 7.8): T effect $F = 33.2460$, $SS_T = 1494.2222$, df $(1,12)$
-- this is the "univariate F" column a stepdown report conventionally shows
side-by-side with the stepdown F (see §4).

**Alpha allocation and conclusion**: with two DVs, T&F split familywise
$\alpha = .05$ into per-DV $\alpha = .025$ each (Eq. 7.12/7.13, p.272) --
the same Bonferroni-style product-of-levels idea already derived
independently from Roy (1958) directly in `Roy-Bargmann.md`'s "Independence
of the stepdown F's" section ($P = \prod_i (1-\alpha_i)$). Critical
$F(1,12) = 6.55$ for the WRAT-R step (obtained 46.1225 -> significant);
critical $F(1,11) = 6.72$ for the WRAT-A stepdown step (obtained 5.4903 ->
**not** significant, despite the plain univariate F of 33.2460 being
significant on its own).

T&F's interpretation (p.274, verbatim): *"according to stepdown analysis,
the significant effect of treatment is represented in WRAT-R scores, with
nothing added by WRAT-A scores... The lack of significance for WRAT-A
scores in stepdown analysis does not mean that they are unaffected by
treatment, but rather that no unique variability is shared with treatment
after adjustment for differences in WRAT-R."*

This is a complete, citable, hand-checkable example -- raw data plus both
the plain-univariate and stepdown ANOVA tables -- good material for a
`dev/` validation script (or eventually a `testthat` fixture) once
`RoyBargmann()` exists: fit
`lm(cbind(WRAT_R, WRAT_A) ~ D * T)`, run `RoyBargmann()` on it, and check
the step-2 (T effect) stepdown F reproduces 5.4903 with df (1, 11).

---

## 4. Reporting-convention guidance

T&F don't give a fill-in-the-blank APA sentence template, but §7.5.3.4
"Choosing Among Strategies for Assessing DVs" (p.275) gives explicit
editorial guidance, verbatim highlights:

* *"If DVs are correlated and there is some compelling priority ordering of
  them, stepdown analysis is clearly called for, with univariate Fs and
  pooled within-cell correlations reported simply as supplemental
  information."*
* *"If a DV has a significant univariate F but a nonsignificant stepdown F,
  interpretation is straightforward: the variance the DV shares with the IV
  is already accounted for through overlapping variance with one or more
  higher-priority DVs."* -- the reverse case (nonsignificant univariate,
  significant stepdown) is flagged as "much more difficult" to interpret,
  and tied back to the context of how the variables were ordered.
* Recommends always reporting the **pooled within-cell correlation matrix**
  alongside the univariate/stepdown F's, so readers can judge the
  overlap-adjustment for themselves (stated at p.272 for univariate F
  reporting generally, and reiterated as relevant to stepdown
  interpretation).
* The per-DV $\alpha$-splitting convention (equal split, or a more liberal
  $\alpha$ for higher-priority DVs) so the product over the $p$ sequential
  tests stays at or below the desired familywise level -- same identity
  already in `Roy-Bargmann.md`.

**Implication for `RoyBargmann()`'s reporting**: a `summary()`/print table
that shows, per step, the **univariate F** (ignoring earlier covariates)
*next to* the **stepdown F** (adjusting for earlier covariates) would match
both SPSS's `UNIV` + `STEPDOWN` combination and T&F's explicit reporting
recommendation -- worth adding a column for the plain univariate F/df/p to
the `Anova.RoyBargmann()` sketch in `Roy-Bargmann.md`, not just the
stepdown one.

---

## Flagged as unresolved / not found

* Bray & Maxwell (1985), *Multivariate Analysis of Variance* (Sage) -- the
  expected classic monograph on this exact topic. Could not access content
  (only bibliographic/marketing pages surfaced); not verified to contain a
  worked stepdown example. Worth a follow-up if/when library access is
  available -- likely still the most authoritative applied treatment.
  
* Exact SPSS `STEPDOWN` printed-table column layout (verbatim headers) --
  not confirmed from a rendered sample. Only IBM's one-line functional
  description was found; the IBM troubleshooting page on this specific
  question is login-gated. Getting the literal layout requires actually
  running `MANOVA ... /PRINT=SIGNIF(STEPDOWN)` in a licensed SPSS session.
  
* No SAS Institute-published macro or technical note for a by-hand stepdown
  implementation was located -- only Finch (2007)'s confirmation that
  researchers roll their own via SAS IML + `PROC GLM`.
  
* Stevens (1972) and Huberty (1994) were not checked directly (both are
  cited within Finch (2007)'s reference list, if primary sources on
  alternative follow-up methods -- SCDFA, DDA, pairwise multivariate
  comparisons -- are wanted alongside stepdown for comparison later).

---

## References

* Tabachnick, B. G., & Fidell, L. S. (2013). *Using Multivariate
  Statistics* (6th ed.). Pearson. ISBN 978-0-205-89081-1. Chapter 7,
  §§7.4-7.5 -- source of the worked example in §3 above and the reporting
  guidance in §4.

* Finch, W. H. (2007). Performance of the Roy-Bargmann Stepdown Procedure
  as a Follow Up to a Significant MANOVA. *Multiple Linear Regression
  Viewpoints*, 33(1), 12-22. <http://www.glmj.org/archives/MLRV_2007_33_1.pdf>
  -- source for the SAS-implementation confirmation (§2) and the Type I
  error inflation caution (§2, side finding).

* IBM. *MANOVA: Multivariate Command, SIGNIF Keyword* (SPSS Statistics
  documentation).
  <https://www.ibm.com/docs/SSLVMB_sub/statistics_reference_project_ddita/spss/advanced/syn_manova_multivariate_signif.html>
  -- source for the `PRINT=SIGNIF(STEPDOWN)` syntax (§1).

* IBM. *Where are the Roy-Bargman Stepdown tests?* (knowledge base --
  login-gated, already cited in `Roy-Bargmann.md`).
  <https://www.ibm.com/support/pages/where-are-roy-bargman-stepdown-tests>
