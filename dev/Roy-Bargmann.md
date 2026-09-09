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

**What it tests**: In the case of a one-way MANOVA design, the $k$th step-down $F$ statistic tests the hypothesis that the means for $\mathbf{Y}_k = $Y_{k1}, Y_{k2}, \dots, Y_{kg}$
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

For the full MLM, Wilks' $\Lambda = |\mathbf{E}| / |\mathbf{E} + \mathbf{H}|$,
where $\mathbf{E}$ is the error (within-group) SSCP matrix and $\mathbf{H}$ is
the hypothesis SSCP matrix for the $X$ terms being tested.

A determinant of a $p \times p$ SSCP matrix can be factored, via successive
conditioning in a chosen variable order, into a product of $p$ terms: the
first is the (marginal) sum of squares of $Y_1$, and the $i$-th is the
*residual* sum of squares of $Y_i$ after regressing it on $Y_1, \dots,
Y_{i-1}$ (this is the same idea as a Cholesky decomposition of the SSCP
matrix, or building up $R^2$ one predictor at a time). Applying that
factorization to $\mathbf{E}$ *and* to $\mathbf{E} + \mathbf{H}$, in the same
variable order, and taking the ratio term-by-term, gives

$$
\Lambda = \prod_{i=1}^{p} \lambda_i, \qquad
\lambda_i = \frac{\text{error SS for } Y_i \mid Y_1,\dots,Y_{i-1}}
                 {\text{error} + \text{hypothesis SS for } Y_i \mid Y_1,\dots,Y_{i-1}}
$$

Each $\lambda_i$ is exactly the univariate "Wilks' lambda" for the stepdown
ANCOVA F-test of $Y_i$ from Sketch 2 above, related to its stepdown $F_i$ the
usual univariate way ($\lambda_i = 1 / (1 + (df_h/df_e) F_i)$ for the $X$
terms' hypothesis and error df at that step).

So the product of the $p$ stepdown $\lambda_i$'s **reconstructs the overall
multivariate $\Lambda$ exactly**, and -- this is Roy's actual result, not just
an identity -- the $p$ stepdown F-tests are *mutually independent* under the
null. That's what makes "test each step, reject overall if any step is
significant" a valid decomposition of the single multivariate test, rather
than just a post-hoc probe.

This is standard material covered in general multivariate-methods texts (e.g.
Bock 1975; Timm 2002) but I have not yet pinned down a fully worked citable
derivation for this note -- worth doing before writing this up for a paper or
vignette, but the identity itself is well established and not really in
question.

---

## Open attribution question

Sources consistently write "Roy-Bargmann," but the single reference the user
supplied is Roy (1958) alone. Bargmann is sometimes credited (in an
unpublished dissertation/technical report, ~1962-70) with formalizing the
ANCOVA-based computational procedure people actually use today from Roy's
more general step-down principle. Worth pinning down the actual Bargmann
citation before writing anything citable (a vignette, paper, or even
`RoyBargmann()`'s `@references`) -- flagging here rather than guessing.

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
  component univariate hypothesis holds.
  
* Roy, S. N., & Bargmann, R. E. (1958). Tests of Multiple Independence and the Associated Confidence
  Bounds. The Annals of Mathematical Statistics, 29(2), 491–503.
  https://doi.org/10.1214/aoms/1177706624

* Secondary descriptions consulted (general confirmation of the ANCOVA-style
  procedure, not the $\Lambda$-decomposition detail):
  [IBM: Where are the Roy-Bargman Stepdown tests?](https://www.ibm.com/support/pages/where-are-roy-bargman-stepdown-tests)
  and
  [Finch, "Performance of the Roy-Bargmann Stepdown Procedure as a Follow Up to a Significant MANOVA"](https://www.semanticscholar.org/paper/Performance-of-the-Roy-Bargmann-Stepdown-Procedure-Finch/394bca3bb0f25869318d18c2d57188be3335efee).

* Bock, R. D. (1975). *Multivariate Statistical Methods in Behavioral
  Research*. McGraw-Hill. -- standard textbook treatment of stepdown analysis
  and its relation to Wilks' $\Lambda$; not yet re-checked against this note,
  worth doing before citing formally.

* Timm, N. H. (2002). *Applied Multivariate Analysis*. Springer. -- likewise,
  a standard reference for the $\Lambda$-decomposition result; not yet
  re-checked.
