# Variable importance in MANOVA
# 

These papers describe an approach to assessing the relative contribution and importance of each dependent variable to the overall multivariate effect, properly handling multicollinearity and shared variance. Would make a useful comparison to Roy-Bargmann approach

Tonidandel, S., & LeBreton, J. M. (2013). Beyond step-down analysis: A new test for decomposing the importance of dependent variables in MANOVA PsycNET. Journal of Applied Psychology, 98(3), 469–477. https://doi.org/10.1037/a0032001

LeBreton, J. M., & Tonidandel, S. (2008). Multivariate relative importance: Extending relative weight analysis to multivariate criterion spaces. Journal of Applied Psychology, 93(2), 329–345. https://doi.org/10.1037/0021-9010.93.2.329

## Software 

This is from Google, AI

* RWA-Web: https://www.scotttonidandel.com/rwa-web

* R packages

  + rwa package: https://cran.r-project.org/web/packages/rwa/index.html

```
install.packages("rwa")
library(rwa)

# Decompose variance of predictors/variables on an outcome
result <- rwa(df, outcome = "Your_Outcome", predictors = c("DV1", "DV2", "DV3"))
```

  * dominance analysis:  https://cran.r-project.org/web/packages/dominanceanalysis/index.html

```
# Install the package from CRAN if you haven't already
install.packages("dominanceanalysis")

# Load the required libraries
library(dominanceanalysis)

# Fit a multivariate linear regression model using cbind() for the DVs
iris.mod <- lm(cbind(Sepal.Length, Sepal.Width) ~ Petal.Length + Petal.Width + Species, data = iris)

# Inspect the standard model summary
summary(iris.mod)

# Run multivariate dominance analysis
da_result <- dominanceAnalysis(iris.mod)

# Retrieve a quick summary of the general weights
summary(da_result)
```

**Correction, checked 2026-09-08 (see "Software support -- checked empirically" below):
this snippet does not actually run.** `dominanceAnalysis()` has no method for a
plain multivariate-response `lm`/`"mlm"` object -- `da_result <- dominanceAnalysis(iris.mod)`
errors with `could not find function "da.mlm.fit"`. Multivariate support exists in the
package (`da.mlmWithCov.fit` / `mlmWithCov()`) but works from a covariance/correlation
matrix, is direction-reversed relative to what we actually want (see below), and does not
accept a fitted `mlm` object.

---

## Comparison with Roy-Bargmann stepdown analysis

See `dev/Roy-Bargmann.md` for the RB framework notes this compares against. The two
approaches answer different questions about "which DV matters" in a MANOVA, and make
opposite assumptions about what the researcher brings to the table:

| | Roy-Bargmann stepdown | Relative-weight / dominance importance |
|---|---|---|
| DV ordering | Required, *a priori*, theory-driven | Not required -- symmetric in the DVs by construction |
| Decomposition | Sequential conditional univariate F-tests; the $p$ stepdown $\lambda_i$'s multiply exactly to the overall Wilks' $\Lambda$ | Non-negative weights that sum exactly to a total multivariate effect size ($R^2$ / canonical variance explained) |
| Answers | "Does $Y_i$ add unique discriminating power beyond the higher-priority $Y_1,\dots,Y_{i-1}$?" | "How much of the overall multivariate effect is attributable to $Y_i$, once shared variance with the other DVs is fairly apportioned?" |
| Handles DV multicollinearity via | Explicit conditioning in a fixed order | Orthogonalization (RWA) or all-subsets averaging (dominance analysis) -- order-agnostic |
| Sensitivity | Result depends on the chosen priority order | Order-independent; agrees with a "natural" stepdown-style attribution only when the DVs are uncorrelated |

So the two are genuinely complementary rather than competing: Roy-Bargmann is the right
tool when a defensible substantive ordering of the DVs exists and the scientific question
is incremental ("does this outcome tell us anything new after the more important ones");
the Tonidandel-LeBreton / dominance-analysis family is the right tool when no such
ordering exists (or the researcher doesn't want to commit to one) but a fair apportionment
of "credit" for the omnibus effect across correlated DVs is still wanted. Both
decompositions should reconcile with the same overall MANOVA test (Wilks' $\Lambda$ /
Pillai's trace) on the same data, which is a natural sanity check once both a
`RoyBargmann()` function and a working variable-importance recipe exist.

### What Tonidandel & LeBreton (2013) actually do

Relative weight analysis (RWA; Johnson, 2000) gets non-negative importance weights for
correlated predictors that sum exactly to $R^2$: orthogonalize the predictors via an
eigendecomposition of their correlation matrix, regress the outcome on the orthogonal
components, then use the component loadings to map component-level importance back onto
the original (correlated) predictors. LeBreton & Tonidandel (2008) extend this to a
*multivariate* criterion space (several $Y$'s at once). Tonidandel & LeBreton (2013) then
apply that multivariate-RWA machinery to MANOVA by **flipping the usual roles**: the DVs
$Y_1, \dots, Y_p$ play the role of "predictors," and the group-membership information
(the MANOVA's $X$ side, dummy-coded) plays the role of the multivariate "criterion." The
relative weight of each DV is then its share of the total multivariate effect
(canonical $R^2$ / Pillai-type index) explaining group membership -- i.e., DV
multicollinearity gets handled exactly the way ordinary RWA handles predictor
multicollinearity.

### Software support -- checked empirically 2026-09-08

Both packages are installed locally (`dominanceanalysis` 2.1.1, `rwa`). Tested against
`NeuroCog` (`heplots`) and `iris`, via `C:\R\R-4.6.1\bin\Rscript.exe`:

* **`dominanceanalysis::dominanceAnalysis()` does NOT accept a fitted multivariate
  `lm`/`"mlm"` object directly**, contrary to what the snippet above (and some
  AI-generated summaries of the package) suggest. `dominanceAnalysis(iris.mod)` on
  `lm(cbind(Sepal.Length, Sepal.Width) ~ ..., data = iris)` errors:
  `could not find function "da.mlm.fit"`. On `lm(cbind(<7 NeuroCog DVs>) ~ Dx)` (a single
  predictor term) it instead errors `You should have at least two predictors in a
  dominance analysis` -- so neither direction of the naive "just fit the mlm and call
  dominanceAnalysis()" recipe works as documented.

* The package's real multivariate support is `da.mlmWithCov.fit()` / `mlmWithCov()`,
  which computes Cramer & Nicewander's multivariate fit indices ($R^2_{XY}$,
  $P^2_{YX}$) **from a correlation/covariance matrix**, not a fitted model, and treats
  the RHS of the formula as the side whose variables get dominance-decomposed against the
  whole LHS set jointly. That is the *opposite* direction from what we want by default
  (predictor importance across a $Y$ set, i.e. the LeBreton-Tonidandel 2008 setup) -- to
  get **DV importance within a MANOVA** (the 2013 paper's question) you have to apply the
  Tonidandel-LeBreton role-flip yourself: dummy-code the group factor as the multivariate
  "$Y$" side and put the cognitive DVs on the "$X$"/predictor side of `mlmWithCov()`.

* **Confirmed this flip works**, using `NeuroCog`: fit
  `mlmWithCov(cbind(Dx2, Dx3) ~ Speed + Attention + Memory + Verbal + Visual + ProbSolv + SocialCog, cor_m)`
  (`Dx2`/`Dx3` = dummy codes for the 3-level `Dx` factor) followed by
  `dominanceAnalysis()` on the result. This runs without error and gives:
  `r.squared.xy = 0.339` (close to, though not identical to, `car::Anova()`'s Pillai's
  trace of 0.348 for `lm(cbind(<7 DVs>) ~ Dx)` -- expected, since $R^2_{XY}$ and Pillai's
  trace are related-but-different multivariate association indices, and dummy vs.
  effect coding of `Dx` differs slightly too), decomposed into average per-DV
  contributions that sum to it: `Speed` 0.091 (largest), `SocialCog` 0.060, `Verbal`
  0.058, `ProbSolv` 0.057, `Attention` 0.026, `Visual` 0.024, `Memory` 0.024. Script:
  `dev/dominance-neurocog-flip.R` (see below).

* **`rwa::rwa()` only supports a single (univariate) `outcome` column** (see its
  signature: `rwa(df, outcome, predictors, ...)`) -- the true multivariate extension from
  LeBreton & Tonidandel (2008) is *not* implemented in the CRAN `rwa` package. It's only
  available via the RWA-Web tool (not scriptable/reproducible from R) or would need a
  custom implementation of the multivariate RWA algorithm to compare properly against
  `RoyBargmann()`. `dominanceanalysis` (via the `mlmWithCov()` role-flip above) is
  therefore the more promising off-the-shelf option for an R-based comparison, despite
  needing the manual reformulation.

### Worked example, for later comparison against `RoyBargmann()`

`dev/dominance-neurocog-flip.R` sets up the `NeuroCog` role-flip above end-to-end
(dummy-coding `Dx`, building the correlation matrix, running `mlmWithCov()` +
`dominanceAnalysis()`) and prints the per-DV importance weights next to
`car::Anova()`'s overall Pillai/Wilks test for
`lm(cbind(Speed, Attention, Memory, Verbal, Visual, ProbSolv, SocialCog) ~ Dx, data = NeuroCog)`.

Once `RoyBargmann()` exists (see `dev/Roy-Bargmann.md`), run it on the same `NeuroCog`
model with a substantive DV ordering (needs deciding -- clinically, something like
`Speed, Attention, Memory, Visual, Verbal, ProbSolv, SocialCog` from more basic/perceptual
to more integrative cognitive functions, but that's a domain call, not a statistical one)
and compare:

* Do the DVs ranked highest by dominance-analysis importance (`Speed`, `SocialCog`,
  `Verbal`) also come out with significant/large stepdown $F$'s in `RoyBargmann()`,
  regardless of where they sit in the chosen priority order?
* Does a DV that's high priority in the RB ordering but *low* importance here (or vice
  versa) flag a case where the a priori ordering and the data-driven "credit" disagree --
  which would itself be a useful diagnostic to surface in a comparison vignette?
* Sanity check: `prod(stepdown lambdas from RoyBargmann())` should equal
  `car::Anova(mlm_fit)`'s Wilks' $\Lambda$ exactly (per `dev/Roy-Bargmann.md`); the
  dominance-analysis weights should sum to `r.squared.xy` exactly (confirmed above) --
  both are internal identities worth asserting in any vignette/test, not just eyeballing.


