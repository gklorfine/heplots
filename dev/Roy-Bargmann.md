# Notes: Roy-Bargmann Stepdown Analysis for MLMs

## Goal

Background/framework notes for the **Roy-Bargmann stepdown analysis** topic in
`dev/GK-Project.md` (Gavin's funding-project topic list), before sketching a
`RoyBargmann()` function. Follows up on Gavin's own note in his fork
(`gklorfine/heplots@GK-work:dev/GK/august-notes.md`), which already correctly
flagged that the StackOverflow-derived sketch in `GK-Project.md` is "not
strictly an RB test" and proposed an all-univariate alternative. This note
works out *why* that's the right call, from the original source.

---

## What the procedure is

Setup: a set of $p$ response variables $Y_1, \dots, Y_p$, ordered *a priori* by
theoretical/substantive importance (not chosen from the data), analyzed via a
single MLM

```r
lm(cbind(Y1, Y2, ..., Yp) ~ X1 + X2 + ...)
```

The overall MANOVA tests the _compound hypothesis_ that **none** of the $X$ terms
affect *any* linear combination of the $Y$'s. Roy-Bargmann stepdown analysis
decomposes that compound hypothesis into $p$ **univariate** hypotheses, tested
in the given priority order:

* **Step 1**: test $Y_1$ alone -- the ordinary univariate ANOVA/regression of
  $Y_1$ on the $X$'s.
* **Step $i$** (for $i = 2, \dots, p$): test $Y_i$ *conditional on* the
  higher-priority responses $Y_1, \dots, Y_{i-1}$ -- i.e. an ANCOVA: regress
  $Y_i$ on the $X$'s **with $Y_1, \dots, Y_{i-1}$ added as covariates**. The
  F-test for the $X$ terms in that model is the "stepdown F" for $Y_i$: does
  $Y_i$ add unique discriminating power beyond what the higher-priority
  responses already capture?

Every step uses the *same* $X$ terms; what grows from step to step is the set
of covariates. This only makes sense with a defensible substantive ordering --
it's explicitly not a data-driven variable-selection method.

This is confirmed directly from Roy (1958) itself (see References): step $i$
tests "the _conditional_ univariate distribution of the $i$-th variate given the
first $i-1$ variates," and "the compound multivariate hypothesis is accepted
[only] if all the component univariate hypotheses are accepted."

### What it tests

In the case of a one-way MANOVA design, the $k$th step-down $F$ statistic tests the hypothesis that the means for $\mathbf{Y}_k = $Y_{k1}, Y_{k2}, \dots, Y_{kg}$
do not differ, with all variation due to the variables $\mathbf{Y}_1, $\mathbf{Y}_2, \dots, $\mathbf{Y}_{k-1}$ eliminated.
Rejection of this hypothesis implies that the $k$th variable is reflecting differences between
groups that cannot be accounted for by any linear combinations of the previous $k-1$ responses.
(Bock, 1975, p. 411)

### Related motivating idea

This is similar, on the Y side, to what is done in _sequential, Type I_ tests for the Xs
in a uni/multi variate linear model. Each sequential test relates to the part of
Y not explained by the previous Xs, ordered by substance to aid in understanding the
overall F statistic in a model `lm(Y ~ x1 + x2 + x3 + ...)`

This may have been what motivated Sketch 1 below.

---

## Two candidate formulations -- and why only one is right

`GK-Project.md` currently records two sketches. Worth spelling out the
difference explicitly since it's easy to conflate them.

**Sketch 1** (from Stack Overflow -- a *shrinking multivariate block* at each
step):

```r
lm(cbind(y1, y2, y3) ~ x1 + x2 + x3 + ...)
lm(cbind(    y2, y3) ~ x1 + x2 + x3 + y1 + ...)
lm(cbind(        y3) ~ x1 + x2 + x3 + y1 + y2 + ...)
```

**Sketch 2** (Gavin's proposed correction -- a single univariate response at
each step):

```r
lm(y1 ~ x1 + x2 + x3 + ...)
lm(y2 ~ x1 + x2 + x3 + y1 + ...)
lm(y3 ~ x1 + x2 + x3 + y1 + y2 + ...)
```

**Sketch 2 is the actual Roy-Bargmann procedure.** Sketch 1 tests something
different at each step -- a MANOVA on the *remaining* variates, controlling for
the ones already stepped through -- rather than isolating a single conditional
univariate hypothesis. That distinction matters for more than terminology: as
laid out below, it's precisely the univariate, one-variate-at-a-time
construction of Sketch 2 that makes the stepdown F-tests:

(a) mutually independent under the null and 
(b) exactly reconstitute the overall Wilks' $\Lambda$ when multiplied together. Sketch 1 has neither property.

Sketch 1 was motivated by the idea of visualizing the multivariate tests using HE plots.
At each stage, could show the remaining associations of the remaining Ys, having controlled for
or partialed out the previous Ys. It doesn't have a neat decomposition associated with it,
but might still be worth considering for this project.

---

## Relation to overall Wilks' $\Lambda$

This section works the derivation from Roy (1958) §2.2-2.3 (pp. 1179-1182),
but *not* in Roy's own symbols. Roy writes the design matrix as $A$, the
coefficient matrix as $\Theta$, and then reuses $B$ for the hypothesis
(contrast) matrix and reuses $C$ for the covariance matrix of an estimator --
none of which match how this package (or the general MANOVA literature)
writes the model. Below uses the familiar

$$
Y = XB + \text{error}, \qquad \mathcal{H}_0 : \Phi = CB = 0
$$

convention instead -- $X_{n\times m}$ the design matrix (rank $r$), $B_{m\times
p}$ the coefficient matrix, $C_{t\times m}$ the **hypothesis/contrast
matrix** of rank $t$ (your guess was right: $\Phi = CB$ *is* the general
linear hypothesis, with $t$ = the hypothesis df, e.g. $g-1$ for a one-way
group effect). Everywhere Roy's own eq. numbers are cited as (R*n*) for
traceability, but the symbols are ours, not his. Roy also silently
*reindexes* partway through his own §2.3 -- his eqs. (12)-(15) describe "given
$Y_i$, predict $y_{i+1}$" (subscript $i$ = conditioning set), while his eqs.
(16)-(23) switch to subscript $i$ meaning "the test at step $i$." That
mismatch is worth naming as a second, independent source of confusion in the
original, on top of the $A/\Theta/B/C$ symbol reuse. Below uses one
consistent convention throughout: **step $i$ tests $y_i$, conditional on
$Y_{i-1} = [y_1 \cdots y_{i-1}]$** -- matching how the rest of this note
already describes the procedure.

### Setup

For the overall MLM, $\mathcal{E}Y = XB$, the hypothesis $\mathcal{H}_0: \Phi
= CB = 0$ is tested via the error and hypothesis SSCP matrices

$$
\mathbf{E} = Y'P_E Y, \qquad \mathbf{H} = Y'P_H Y \tag{R9}
$$

for idempotent projections $P_E$ (rank $n-r$, error) and $P_H$ (rank $t$,
hypothesis), giving the likelihood-ratio test

$$
\Lambda = \frac{|\mathbf{E}|}{|\mathbf{E}+\mathbf{H}|} \tag{R10}
$$

-- exactly the overall Wilks' $\Lambda$ already used elsewhere in this note,
with $\mathbf{H}$ the SSCP for the $X$ terms and $n-r$ the error df of the
full MLM.

### The stepdown conditional model *is* the ANCOVA step (Roy §2.3, eqs. 12-15, reindexed)

Let $b_i$ be column $i$ of $B$ (the $X$-coefficients for response $y_i$),
$B_{i-1} = [b_1 \cdots b_{i-1}]$, and $\Sigma_{i-1}$ the top-left
$(i-1)\times(i-1)$ block of $\Sigma$ (with $\Sigma_0 \equiv 1$, a formal
placeholder so the $i=1$ case needs no special-casing). Condition on
$Y_{i-1}$ and look at the conditional distribution of $y_i$. Because the rows
of $Y$ are iid multivariate normal, that conditional distribution is itself
an ordinary univariate general linear model,

$$
\mathcal{E}\,y_i \mid Y_{i-1} = X\eta_i + Y_{i-1}\gamma_{i-1} \tag{R12}
$$

$$
\gamma_{i-1} = \Sigma_{i-1}^{-1}(\sigma_{1,i}, \dots, \sigma_{i-1,i})', \qquad
\eta_i = b_i - B_{i-1}\gamma_{i-1}, \qquad
\sigma_i^2 = \frac{|\Sigma_i|}{|\Sigma_{i-1}|} \tag{R13-15}
$$

($\gamma_0$ and $B_0$ are empty/null, so $\eta_1 = b_1$ and $\sigma_1^2 =
\sigma_{11}$ at step 1, with no covariates.) Reading this off directly:
$\gamma_{i-1}$ is the population regression of $y_i$ on $y_1,\dots,y_{i-1}$
(nothing to do with the $X$ terms -- it's the covariate-adjustment step);
$\eta_i$ is the $X$-effect coefficient vector $b_i$ *adjusted* for that
regression; and $\sigma_i^2$ is the residual (conditional) variance of $y_i$
given $y_1,\dots,y_{i-1}$. (R12) says the conditional model for $y_i$ given
$Y_{i-1}$ has the *same* design matrix $X$ (same $X$ terms) plus $Y_{i-1}$ as
covariates -- i.e. this is precisely
`lm(y_i ~ x1 + x2 + ... + y1 + ... + y(i-1))`, Sketch 2's step $i$, derived
from first principles rather than assumed.

### The stepdown F (Roy §2.3, eqs. 16-17, 22)

Testing $\mathcal{H}_{0,i}: \Phi_i = C\eta_i = 0$ -- the *same* hypothesis
matrix $C$ as the overall test, now applied to the adjusted coefficient
$\eta_i$ instead of $b_i$ -- gives, by the ordinary univariate GLM result
(R2) applied to model (R12),

$$
F_i \equiv \frac{(\hat\Phi_i - \Phi_i)'V_i^{-1}(\hat\Phi_i-\Phi_i)/t}
                {s_i^2/(n-r-i+1)}, \qquad i = 1,\dots,p \tag{R17}
$$

where $V_i$ is the (scaled) covariance matrix of the estimator $\hat\Phi_i$
(this is what Roy calls "$C$" in his §2.1 -- renamed here to $V$ to keep it
distinct from the hypothesis matrix $C$). $F_i$ is distributed, conditional
on $Y_{i-1}$, as $F(t,\ n-r-i+1)$. This is exactly the joint stepdown F-test
for the $X$ terms in the ANCOVA at step $i$ -- `RoyBargmann()`'s per-step
full-vs-reduced comparison. The error df $n-r-i+1$ matches the
implementation directly: $n-r$ at step 1 (no covariates), losing one more df
per additional $Y_{i-1}$ covariate.

### Independence of the stepdown F's (Roy §2.3, p. 1181, between eqs. 17 and 18)

This is Roy's actual theorem, not an assumption (quoted, with his original
subscript convention intact since it's a direct quote): "the statistic $F_i$
involves only $Y_i$ ($i = 1, 2, \dots, p$) and [...] the conditional
distribution of $F_i$, given $Y_{i-1}$, does not involve $Y_{i-1}$ [...]
Therefore the statistics $F_1, F_2, \dots, F_p$ are independent."

Spelled out: $F_i$'s conditional distribution given $Y_{i-1}$ is the fixed
$F(t, n-r-i+1)$ law from (R17), with no dependence left on $Y_{i-1}$'s
realized value. Since $F_1,\dots,F_{i-1}$ are themselves functions only of
$Y_{i-1}$ (each $F_j$, $j<i$, is a function of $Y_j \subseteq Y_{i-1}$), $F_i$
is independent of $(F_1,\dots,F_{i-1})$ for every $i$ -- hence, by induction,
all $p$ are mutually independent. That's what licenses treating "accept
$\mathcal{H}_{0,i}$ for all $i$" as a valid decomposition of the compound
test with combined level $P = \prod_{i=1}^p (1-\alpha_i)$ (Roy's eq. 19),
rather than a set of correlated post-hoc probes.

### The $\Lambda$-product identity (Roy §2.3, eq. 23)

Roy states this explicitly as a known result (citing Wilks for the moments
of $L$ under $\mathcal{H}_0$), with $u_i$ the value of $F_i$'s numerator
statistic evaluated under $\Phi_i = 0$ (his eq. 22):

$$
L \equiv \Lambda = \prod_{i=1}^{p} \frac{(n-r-i+1)}{t + (n-r-i+1)\,u_i}
\tag{R23}
$$

Dividing numerator and denominator by $(n-r-i+1)$ gives the form used
earlier in this note:

$$
\Lambda = \prod_{i=1}^p \lambda_i, \qquad
\lambda_i = \frac{1}{1 + \dfrac{t}{n-r-i+1}\,F_i}
$$

which is exactly `1 / (1 + (df1/df2) * Fstat)` in the `Anova.RoyBargmann()`
sketch's `lambda` column, and confirms `cum.lambda[p]` (the cumulative
product) reconstructs the overall $\Lambda$ exactly -- this is a derived
identity from the source, not just a documented sanity check.

### Notation crosswalk (this note $\to$ Roy 1958)

| This note | Roy's symbol | Meaning |
|---|---|---|
| $X$ | $A$ | design matrix for the terms under test (the "$X$ terms") |
| $B$ | $\Theta$ | full coefficient matrix ($m \times p$) |
| $b_i$, $B_{i-1}$ | $\theta_i$ (relabeled), $\Theta_{i-1}$ (relabeled) | column $i$ of $B$; first $i-1$ columns |
| $C$ | $B$ | hypothesis/contrast matrix ($t \times m$, rank $t$), in $\Phi = CB$ |
| $\Phi$ | $\Phi$ | the estimable hypothesis, $\Phi = CB$ (overall) or $C\eta_i$ (step $i$) |
| $\gamma_{i-1}$ | $\beta_{i-1}$ (relabeled) | stepdown regression of $y_i$ on $Y_{i-1}$ (covariate adjustment) |
| $\eta_i$ | $\eta_i$ | $b_i$ adjusted for $\gamma_{i-1}$ (unchanged, but reindexed to mean "for testing $y_i$") |
| $V_i$ | $C_i$ | scaled covariance matrix of $\hat\Phi_i$ (renamed to avoid clashing with hypothesis matrix $C$) |
| $\mathbf{E}, \mathbf{H}$ | $S_e, S_h$ | error / hypothesis SSCP matrices |

### Summary: what's now settled vs. still open

* **Settled, with citation**: the stepdown ANCOVA model (R12) *is* Sketch 2;
  the stepdown F (R17) *is* `RoyBargmann()`'s per-step joint test; the $p$
  stepdown F's are mutually independent (proven, not assumed); and $\Lambda =
  \prod \lambda_i$ exactly (R23), reconciling the compound multivariate test
  with the $p$ univariate ones.
* **Attribution: resolved** -- see
  [Open attribution question](#open-attribution-question) below.
* Bock (1975, pp. 153-154) was offered as a fallback if Roy's notation proved
  too opaque to extract a citable derivation from -- turned out not to be
  needed, since Roy's own eqs. (12)-(23) give the full derivation directly,
  once re-expressed in $X/B/C$ notation as above. Still worth a skim later
  purely for exposition to crib from when writing this up for a vignette.

---

## Open attribution question -- resolved

Sources consistently write "Roy-Bargmann," but the derivation above cites
Roy (1958) alone, which never mentions Bargmann. The co-authored reference,
Roy, S. N., & Bargmann, R. E. (1958), *Tests of Multiple Independence and
the Associated Confidence Bounds*, has now been added to the References
below -- that's the actual Bargmann citation backing the "Roy-Bargmann" name,
so this is safe to cite in `RoyBargmann()`'s `@references`, a vignette, or a
paper.

---

## Implementation sketch for `RoyBargmann()` (for the follow-up)

Not attempting this yet -- just noting the shape of it for next time. Design
settled on 2026-09-08: `RoyBargmann()` takes the *same* model formula as the
overall MLM (`cbind(y1, ..., yp) ~ x1 + x2 + ...`), reads the response
priority order directly off the `cbind()`, and returns an object holding the
$p$ fitted stepdown `"lm"` models -- an `"lmlist"` -- with `Anova()`,
`summary()`, `coef()`, and `print()` methods hung off it.

### Required input

* Response priority order comes **only** from the left-to-right order of
  `cbind(y1, y2, ...)` in `formula` -- never inferred from the data, per
  Roy's original requirement of a defensible substantive ordering. Document
  this loudly in `@param formula`.
* The same `x` terms (right-hand side of `formula`) are used, unchanged, at
  every step; what grows at step $i$ is the covariate set
  $Y_1, \dots, Y_{i-1}$.

### The `"lmlist"` object

`"lmlist"` is meant as a lightweight, general base class for "a named list
of `lm` fits sharing a common thread" (distinct from `nlme::lmList`, which
fits *the same* formula across groups -- here each step's formula differs in
width). `RoyBargmann()` returns an object of class `c("RoyBargmann",
"lmlist")`: a list of $p$ `"lm"` fits, named by response, i.e.
`steps[["y2"]]` is the fit of `y2 ~ x1 + x2 + ... + y1`.

`mlm` is stored as an **attribute**, not a list element -- `steps[[i]]` for
`i in seq_along(steps)` are still exactly the `p` stepdown `"lm"` fits and
nothing else, so `"lmlist"` stays accurate for the list itself. (`unclass()`
would show the attribute alongside `names`/`class` the way any object's
attributes show, which is a bit more than a bare `list` carries, but
`length()`, `[[`, `lapply()` etc. all still behave as "list of `p` things.")

```r
# TODO: 🚩 Sketch only -- not implemented yet. Written 2026-09-08.

#' Roy-Bargmann Stepdown Analysis
#'
#' @description
#' Fits the sequence of Roy-Bargmann stepdown models for a multivariate
#' linear model `lm(cbind(y1, ..., yp) ~ x1 + x2 + ...)`, where the `y`
#' responses are listed in a substantively meaningful priority order. At
#' step `i`, `y_i` is regressed on the original `x` terms with
#' `y_1, ..., y_(i-1)` added as covariates; the joint F-test for the `x`
#' terms in that model is the stepdown test for whether `y_i` adds unique
#' discriminating power. See `dev/Roy-Bargmann.md` for the background.
#'
#' @param formula A model `formula` of the form
#'        `cbind(y1, y2, ..., yp) ~ x1 + x2 + ...`. The left-to-right order
#'        of the responses in `cbind()` **is** the priority order for the
#'        stepdown sequence -- it is read directly from the formula and is
#'        never inferred from the data.
#' @param data A `data.frame` containing the variables named in `formula`.
#' @param ... Additional arguments passed on to `lm()` for every step and
#'        for the overall MLM fit (e.g. `subset`, `weights`, `na.action`).
#'
#' @return An object of class `c("RoyBargmann", "lmlist")`: a list of `p`
#'         fitted `"lm"` objects, one per stepdown step, named by the
#'         response tested at that step, with attributes:
#'   * `responses`: character vector of response names, in priority order
#'   * `formula`: the original `formula`
#'   * `mlm`: the overall `lm(cbind(...) ~ ...)` fit, kept for the overall
#'     Wilks' $\Lambda$ reference used by `summary()`/`Anova()`
#'
#' @references 
#' Roy, S. N. (1958). Step-Down Procedure in Multivariate Analysis.
#' *The Annals of Mathematical Statistics*, 29(4), 1177-1187.
#' \doi{10.1214/aoms/1177706449}.
#' 
#' Roy, S. N., & Bargmann, R. E. (1958). Tests of Multiple Independence
#' and the Associated Confidence Bounds. *The Annals of Mathematical
#' Statistics*, 29(2), 491-503. \doi{10.1214/aoms/1177706624}.
#'
#' @export
RoyBargmann <- function(formula, data, ...) {
  # 1. Input validation and preprocessing
  lhs <- formula[[2]]
  if (!identical(lhs[[1]], as.name("cbind"))) {
    stop(glue::glue(
      "The left-hand side of `formula` must be a `cbind(...)` of response ",
      "variables in priority order, e.g. `cbind(y1, y2, y3) ~ x1 + x2`"
    ))
  }
  responses <- vapply(as.list(lhs)[-1], deparse, character(1))
  p <- length(responses)
  if (p < 2) {
    stop(glue::glue("Need at least 2 response variables for a stepdown analysis, got {p}"))
  }
  x_terms <- attr(terms(formula), "term.labels")

  # 2. Overall MLM fit -- kept for the Wilks' Lambda sanity check
  mlm_fit <- lm(formula, data = data, ...)

  # 3. Fit the p stepdown models. Sequential by construction -- step i's
  #    formula depends on steps 1..(i-1), so this isn't vectorizable, but
  #    lapply() keeps it out of an explicit for-loop.
  steps <- lapply(seq_len(p), function(i) {
    rhs_terms <- c(x_terms, responses[seq_len(i - 1)])
    step_formula <- reformulate(rhs_terms, response = responses[i])
    lm(step_formula, data = data, ...)
  })
  names(steps) <- responses

  # 4. Return
  structure(
    steps,
    class = c("RoyBargmann", "lmlist"),
    responses = responses,
    x_terms = x_terms,
    formula = formula,
    mlm = mlm_fit
  )
}
```

### `Anova()` / `summary()` -- the stepdown table

The substantive per-step test is a *joint* test of all `x` terms together
(matching the single hypothesis SSCP matrix $\mathbf{H}$ in the $\Lambda$
decomposition above), not the per-term Type II/III rows `car::Anova()`
would give for a step's `lm` on its own. So each step needs a model
comparison: full model (`x` terms + `y` covariates) vs. reduced model
(`y` covariates only, `x` terms dropped). This generalizes the common
single-factor MANOVA case (where it reduces to the ordinary ANCOVA F-test
for the group effect) to designs with multiple `x` terms tested jointly.

```r
# TODO: 🚩 Sketch only -- not implemented yet.

#' @rdname RoyBargmann
#' @param object,mod A `"RoyBargmann"` object, as returned by `RoyBargmann()`.
#' @export
Anova.RoyBargmann <- function(mod, ...) {
  responses <- attr(mod, "responses")
  x_terms   <- attr(mod, "x_terms")
  data      <- model.frame(attr(mod, "mlm"))

  # For step i, compare the full stepdown model against the same model
  # with the x terms dropped (y covariates only, or intercept-only at i=1)
  tests <- lapply(seq_along(mod), function(i) {
    reduced_terms <- responses[seq_len(i - 1)]
    reduced_formula <- if (length(reduced_terms)) {
      reformulate(reduced_terms, response = responses[i])
    } else {
      reformulate("1", response = responses[i])
    }
    reduced_fit <- lm(reduced_formula, data = data)
    anova(reduced_fit, mod[[i]])[2, ]
  })

  df1    <- vapply(tests, function(a) a[["Df"]], numeric(1))
  df2    <- vapply(seq_along(mod), function(i) df.residual(mod[[i]]), numeric(1))
  Fstat  <- vapply(tests, function(a) a[["F"]], numeric(1))
  pval   <- vapply(tests, function(a) a[["Pr(>F)"]], numeric(1))
  lambda <- 1 / (1 + (df1 / df2) * Fstat)

  tab <- data.frame(
    response = responses,
    df1 = df1, df2 = df2, F = Fstat, p.value = pval,
    lambda = lambda,
    cum.lambda = cumprod(lambda),
    row.names = responses
  )
  # Sanity check (documented, not enforced): with a single x term, or when
  # the x terms are tested jointly, tab$cum.lambda[p] should match the
  # overall Wilks' Lambda from `anova(update(mlm, . ~ 1), mlm, test = "Wilks")`
  structure(tab, class = c("Anova.RoyBargmann", "data.frame"))
}

#' @rdname RoyBargmann
#' @export
summary.RoyBargmann <- function(object, ...) {
  structure(
    list(
      stepdown = Anova.RoyBargmann(object),
      steps = lapply(object, summary)
    ),
    class = "summary.RoyBargmann"
  )
}

#' @rdname RoyBargmann
#' @export
print.summary.RoyBargmann <- function(x, ...) {
  cat("Roy-Bargmann Stepdown Analysis\n\n")
  print(x$stepdown)
  invisible(x)
}
```

### `coef()` and `print()`

Each step's model has a *different* width (the covariate set grows), so
unlike `nlme::coef.lmList` (which can return a matrix because every group
shares one formula), `coef.RoyBargmann` returns a named list -- one
coefficient vector per step -- rather than forcing a ragged matrix:

```r
#' @rdname RoyBargmann
#' @export
coef.RoyBargmann <- function(object, ...) {
  lapply(object, coef)
}

#' @rdname RoyBargmann
#' @export
print.RoyBargmann <- function(x, ...) {
  cat("Roy-Bargmann Stepdown Analysis:", length(x), "steps\n\n")
  formulas <- lapply(x, formula)
  for (i in seq_along(x)) {
    cat(glue::glue("Step {i}: {deparse(formulas[[i]])}"), "\n")
  }
  invisible(x)
}
```

### Remaining open questions

* ~~Whether `Anova.RoyBargmann()` should dispatch on `car::Anova()`'s S3
  generic directly~~ -- **resolved**: `car` is already an `Imports` (not
  `Suggests`) in `DESCRIPTION`, and the package already has precedent for
  exactly this (`R/etasq.R` defines `etasq.Anova.mlm` with `#' @importFrom
  car Anova`). So `Anova.RoyBargmann <- function(mod, ...)` with
  `#' @importFrom car Anova` and `#' @export` is enough for roxygen2 to
  register `S3method(Anova, RoyBargmann)`, and `Anova(rb_fit)` (or
  `car::Anova(rb_fit)`) will just dispatch correctly once both packages are
  loaded.

  Checked what `car::Anova()` actually returns, since that shapes the
  sketch above: on a single-response `"lm"` (each stepdown model on its
  own) it returns an eager `c("anova", "data.frame")` -- one row per term,
  computed immediately, printed via `stats:::print.anova`. On an `"mlm"`
  (the overall fit) it instead returns a **lazy** `"Anova.mlm"` object that
  just holds the raw `SSP`/`SSPE`/`df` per term -- the actual Wilks/Pillai/
  etc. statistic is only computed inside `print.Anova.mlm()` /
  `summary.Anova.mlm()`. Two implications for us:
  
    + Our hand-rolled full-vs-reduced comparison in the sketch above is
      still necessary in general (car's per-term `Anova.lm()` rows test
      each `x` term *separately*, not jointly) -- except in the single-
      `x`-term case, where `car::Anova(step_fit)`'s one row for that term
      already *is* the joint test, so the reduced-model refit could be
      skipped there as a fast path.
    + Car's lazy pattern (store `SSPH`/`SSPE`, defer the F/lambda
      computation to `print`/`summary`) is a reasonable model to imitate
      if `Anova.RoyBargmann()` ever needs to support more than one test
      statistic (Pillai, Hotelling-Lawley, Roy) the way `Anova.mlm` does --
      not needed for the univariate stepdown F itself, but worth keeping
      in mind if this grows an `overall = TRUE` mode (next point).

* Whether the overall-$\Lambda$ sanity check belongs *in* `summary()`
  output or is left as a unit test only -- **resolved**: expose it via an
  `overall` argument on `Anova.RoyBargmann()` rather than hardcoding it into
  `summary()`:

  ```r
  Anova.RoyBargmann <- function(mod, overall = FALSE, ...) {
    tab <- ...  # as sketched above

    if (overall) {
      mlm_fit <- attr(mod, "mlm")
      x_terms <- attr(mod, "x_terms")
      reduced_mlm <- update(mlm_fit, reformulate(".", response = ".") ) # drop x terms
      # i.e. refit mlm_fit with x_terms removed from the RHS
      overall_test <- anova(reduced_mlm, mlm_fit, test = "Wilks")
      attr(tab, "overall") <- overall_test
      attr(tab, "lambda.check") <- c(
        cum.lambda = tab$cum.lambda[nrow(tab)],
        overall.wilks = overall_test$Wilks[2]
      )
    }
    tab
  }
  ```

  `summary.RoyBargmann()` can then just call `Anova.RoyBargmann(object,
  overall = TRUE)` and print the `lambda.check` pair as a footnote --
  keeps the expensive extra refit opt-in for `Anova()` callers who don't
  need it, while `summary()` always shows it.

* `print.summary.RoyBargmann()` above is bare-bones (just the stepdown
  table) -- decide whether to also show per-step `summary(lm)` output
  (`$steps`), and how verbose that should be by default vs. behind a
  `verbose = FALSE` argument.

* Visualization ideas already sketched in `GK-Project.md` (`heplot()`,
  `pvPlot()`-style conditioned scatterplots) -- not duplicating those here.

---

## References

* Roy, S. N. (1958). Step-Down Procedure in Multivariate Analysis. *The
  Annals of Mathematical Statistics*, **29**(4), 1177-1187.
  <http://www.jstor.org/stable/2236954> (open-access mirror:
  <https://projecteuclid.org/euclid.aoms/1177706449>). Confirmed directly
  from this source: at step $i$ the test is univariate, conditional on
  $Y_1, \dots, Y_{i-1}$; the compound hypothesis holds only if every
  component univariate hypothesis holds. **§2.2-2.3 (pp. 1179-1182, eqs.
  9-23) is now the primary source for the [Relation to overall Wilks'
  Λ](#relation-to-overall-wilks-lambda) derivation above** -- the stepdown
  ANCOVA model, the stepdown F, its independence proof, and the exact
  $\Lambda = \prod \lambda_i$ identity are all worked there directly, not
  just asserted from secondary sources.
  
* Roy, S. N., & Bargmann, R. E. (1958). Tests of Multiple Independence and the Associated Confidence
  Bounds. The Annals of Mathematical Statistics, 29(2), 491–503.
  https://doi.org/10.1214/aoms/1177706624

* Secondary descriptions consulted (general confirmation of the ANCOVA-style
  procedure, not the $\Lambda$-decomposition detail):
  [IBM: Where are the Roy-Bargman Stepdown tests?](https://www.ibm.com/support/pages/where-are-roy-bargman-stepdown-tests)
  and
  [Finch, "Performance of the Roy-Bargmann Stepdown Procedure as a Follow Up to a Significant MANOVA"](https://www.semanticscholar.org/paper/Performance-of-the-Roy-Bargmann-Stepdown-Procedure-Finch/394bca3bb0f25869318d18c2d57188be3335efee).

* Bock, R. D. (1975). *Multivariate Statistical Methods in Behavioral
  Research*. McGraw-Hill, pp. 153-154. -- standard textbook treatment of
  stepdown analysis and its relation to Wilks' $\Lambda$; not needed to
  source the derivation above (Roy's own eqs. 12-23 sufficed) but still
  worth a skim later for expository notation when writing this up for a
  vignette or paper.

* Timm, N. H. (2002). *Applied Multivariate Analysis*. Springer. -- likewise,
  a standard reference for the $\Lambda$-decomposition result; not
  re-checked, now lower priority since Roy (1958) itself is cited directly
  above.
