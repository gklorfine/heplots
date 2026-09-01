# Roy--Bargmann Implementation and Visualization Notes

These notes extend the RB ideas in [`august-notes.md`](./august-notes.md) and
[`../Roy-Bargmann.md`](../Roy-Bargmann.md). The basic sequence of univariate
ANCOVAs is classical; the opportunity is to make the R implementation more
auditable, explanatory, and extensible than implementations that primarily
print a table of stepdown F tests.

## Scope and terminology

The initial implementation should be described as Roy--Bargmann stepdown
analysis for effects in MANOVA and MANCOVA models fitted as R `"mlm"`
objects. Here, "general multivariate linear hypothesis" means a term or
contrast within such a model. It does not mean generalized linear models,
mixed models, or arbitrary multivariate procedures.

For responses in a substantively determined order, the component models are

```r
lm(Y1 ~ original predictors)
lm(Y2 ~ original predictors + Y1)
lm(Y3 ~ original predictors + Y1 + Y2)
```

The response order must be specified a priori, or the significance of the
column order of the original `cbind()` response must be clearly documented.
It must not be chosen by searching for the order with the most significant
component tests.

## Which lambda is being decomposed?

There are three related quantities that should be kept distinct in the code,
output, and plot labels.

1. $\Lambda_{\mathrm{model}}$ is the overall Wilks' lambda for the complete
   non-intercept predictor block.
2. $\Lambda_j$ is the multivariate Wilks' lambda for predictor term or
   hypothesis $j$, such as `Treatment` or `Treatment:Sex`, conditional on the
   other terms according to the chosen hypothesis type.
3. $\lambda_{ij}$ is the RB component lambda for term $j$ at ordered response
   step $i$. Similarly, $\lambda_{i,\mathrm{model}}$ is the component at step
   $i$ when the complete predictor block is tested.

Consequently,

$$
\Lambda_{\mathrm{model}}
  = \prod_{i=1}^p \lambda_{i,\mathrm{model}},
\qquad
\Lambda_j
  = \prod_{i=1}^p \lambda_{ij}.
$$

The term-specific $\Lambda_j$ values do **not** generally multiply together
to produce $\Lambda_{\mathrm{model}}$. In a one-way MANOVA with only one
non-intercept predictor term, the model and term hypotheses coincide, which
can obscure this distinction.

## Primary visualization: effect-by-response table

The table/glyph plot proposed in `august-notes.md` should be the primary
overview. A refined layout would have

* rows for `Y1`, `Y2 | Y1`, `Y3 | Y1,Y2`, and so on;
* columns for the original model terms being tested;
* a separate text column giving the earlier responses conditioned on;
* tile area or intensity proportional to the term-specific conditional
  partial $R^2_{ij} = 1 - \lambda_{ij}$;
* significance indicated by an outline, symbol, or a second visual channel;
* direction shown only for one-df hypotheses, for which direction is defined.

Squares or heat-map tiles may work better than circles because the matrix
structure is important. Earlier responses are adjustment covariates, not
target hypotheses, so they should not be shown as effect bubbles in the same
way as the original predictors.

Each term's overall multivariate $\Lambda_j$ could appear in its column
heading. The whole-model $\Lambda_{\mathrm{model}}$ should appear in a
separate header or panel. Neither multivariate quantity should be encoded as
though it were directly comparable with the conditional univariate effect
sizes in the body of the table.

## Companion visualization: decomposition of Wilks' lambda

The lambda-decomposition plot should be separate from, but linkable to, the
effect-by-response table. By default, the stacked bar should decompose the
whole-model $\Lambda_{\mathrm{model}}$ across the responses. The table has a
different role: it compares term-by-response component lambdas
$\lambda_{ij}$ for several predictor terms.

The decomposition plot should also allow the user to select one term column
from the table and decompose that term's $\Lambda_j$. The plot title and
labels must always state whether the hypothesis is the complete model or a
named term.

For a selected hypothesis $h$ -- either the complete model or a term -- at
step $i$,

$$
\lambda_{ih} =
\frac{\mathrm{SSE}_{\mathrm{full},i}}
     {\mathrm{SSE}_{\mathrm{reduced},i}}
= \frac{E_i}{E_i + H_i}.
$$

Thus a **smaller** $\lambda_{ih}$ means that the response at that step has more
bearing on the multivariate effect. A value near one means that nearly all
the variation remains as error after conditioning on the earlier responses.
Both $1-\lambda_{ih}$ and $-\log(\lambda_{ih})$ increase with effect strength,
but the log scale has the important additive identity

$$
-\log(\Lambda_h) = \sum_i -\log(\lambda_{ih}),
\qquad
\Lambda_h = \prod_i \lambda_{ih}.
$$

The proposed plot is therefore a segmented or waterfall display in response
order. There are exactly $p$ segments for $p$ response variables, with segment
lengths $-\log(\lambda_{ih})$. Their total length is exactly
$-\log(\Lambda_h)$ for the selected hypothesis. Labels should use the
conditional response names, for example `Y2 | Y1`, rather than just `Y2`.

Possible interface:

```r
plot(rb, type = "effects")
plot(rb, type = "lambda", hypothesis = "model")
plot(rb, type = "lambda", term = "Treatment")
```

These could later be combined into a two-panel figure or linked so that a
selected cell in the table determines the term shown in the decomposition
plot. They should first be implemented as separate plot types. Predictor
terms must not be stacked as though their $\Lambda_j$ values were additive or
multiplicative components of $\Lambda_{\mathrm{model}}$.

## Order-sensitivity visualization

An order-sensitivity display could be a particularly distinctive feature.
The user would supply a small set of substantively plausible orders:

```r
orderSensitivity(
  rb,
  orders = list(
    theory_A = c("Y1", "Y2", "Y3"),
    theory_B = c("Y2", "Y1", "Y3")
  )
)
```

For a selected hypothesis, show each order as a stacked bar whose segments
are $-\log(\lambda_{ih})$. Subject to numerical error, every order has the
same total $-\log(\Lambda_h)$, while the allocation among responses changes.
This makes the order dependence of the RB interpretation immediately
visible. The default selected hypothesis could again be the complete model,
with a named term available as an option.

This must be labeled as a sensitivity analysis. The function should not
search all $p!$ permutations and select the most favorable ordering.

## Conditional drill-down plots

Each cell in the effect-by-response table should correspond to an inspectable
stepdown model. A drill-down plot could show

* a one-dimensional HE plot for the selected response and term;
* an added-variable plot for a one-df predictor;
* adjusted group means and confidence intervals; or
* residual and influence diagnostics for that component model.

For example:

```r
plot(rb, response = "Y3", term = "Treatment", type = "conditional")
```

This supplies the geometric and data-level explanation that is missing from
a conventional table of stepdown F tests.

## Auditable Wilks decomposition

For the complete model and for each requested term, the output should report

* response and conditioning set;
* hypothesis and error degrees of freedom;
* stepdown F statistic and p-value;
* component $\lambda_{ih}$;
* conditional partial $R^2_{ih} = 1-\lambda_{ih}$;
* cumulative $\prod_{k=1}^i \lambda_{kh}$; and
* the corresponding $\Lambda_h$ from the MLM.

The implementation should automatically compare each
$\prod_i\lambda_{ih}$ with its corresponding whole-model or term-specific
$\Lambda_h$ and store the numerical discrepancy. Calculations should use
sums of log lambdas, QR decompositions, or stable log-determinants rather than
multiplying many small values or taking raw determinants unnecessarily.

A discrepancy beyond tolerance should produce a useful diagnostic rather
than being silently ignored. Likely causes include different analysis
samples, rank deficiency, a nonestimable hypothesis, or an incorrectly
constructed component test.

## A model-native R interface

A tentative interface is

```r
fit <- lm(cbind(Y1, Y2, Y3) ~ Treatment * Sex + Age, data = dat)

rb <- RoyBargmann(
  fit,
  response.order = c("Y1", "Y2", "Y3"),
  type = "II"
)
```

The returned object should retain at least

```r
rb$overall       # omnibus MANOVA tests
rb$steps         # tidy stepdown results
rb$models        # fitted component models
rb$order         # declared response order
rb$hypotheses    # coefficient hypotheses actually tested
rb$diagnostics   # rank, sample, and decomposition checks
```

Useful methods include `print()`, `summary()`, `as.data.frame()`, and
`plot()`. Users should be able to inspect every component model rather than
receiving only formatted output. Support should include factors, continuous
predictors, interactions, contrasts, unbalanced designs, and MANCOVA
covariates, while preserving the fitted MLM's contrasts and model frame.

For term-specific RB tests, every component must test the same coefficient
hypothesis as the corresponding omnibus MANOVA term. This is safer than
constructing a sequence of loosely related `drop1()` tests.

## Analysis-sample and estimability checks

Every component model must use exactly the observations used by the original
MLM. Refitting separate ANCOVAs from the original data can otherwise omit
different cases at different steps and invalidate the lambda decomposition.
The object should retain case identifiers and verify the sample at every
step.

Diagnostics and warnings should cover

* rank-deficient design matrices;
* singular residual covariance matrices;
* constant or linearly dependent responses;
* nonestimable terms or contrasts;
* inadequate residual degrees of freedom; and
* the homogeneity-of-regression-slopes assumption introduced when earlier
  responses are used as covariates.

## Robust and resampling extensions

An extension connected to `robmlm()` could provide genuine methodological
novelty rather than only software novelty. Possibilities include robust
conditional fits, bootstrap confidence intervals for conditional partial
$R^2$, permutation-calibrated tests, and classical-versus-robust
decomposition plots.

The classical exact distributions, independence results, and Wilks
decomposition must not automatically be claimed for a robust version.
Common weights, the appropriate resampling scheme, and the inferential target
would need to be defined explicitly. A simulation study should examine null
size, power, response correlation, unequal covariance matrices, contamination,
sample size, and response ordering before this is presented as an inferential
method.

## Proposed implementation priorities

1. Correct component models and term-specific hypothesis tests.
2. Common-sample, rank, estimability, and decomposition checks.
3. A structured `RoyBargmann` object with inspectable component models.
4. The effect-by-response table from `august-notes.md`.
5. The additive $-\log(\lambda_i)$ companion plot.
6. Conditional HE or added-variable drill-down plots.
7. Prespecified order-sensitivity analysis and visualization.
8. Robust or resampling-based inference as a separately validated extension.

## Position relative to other software

The defensible claim is not that the RB procedure itself is new. SPSS, for
example, provides stepdown tests through its older syntax-based `MANOVA`
procedure using `/PRINT SIGNIF(STEPDOWN)`. General MANOVA facilities also
exist in other languages. The stronger contribution is that this
implementation would treat RB as an inspectable and visual decomposition of
a MANOVA effect rather than only a printed sequence of ANCOVA tests.

Before claiming that this is the first dedicated R implementation, conduct a
more systematic software and literature review. A safer working description
is:

> An open-source, model-native implementation of Roy--Bargmann stepdown
> analysis that provides computational auditing, graphical attribution of
> Wilks' lambda, response-order sensitivity analysis, and conditional
> diagnostic plots.

Useful comparison links:

* [IBM: Where are the Roy-Bargman Stepdown tests?](https://www.ibm.com/support/pages/node/418181)
* [statsmodels multivariate linear-model documentation](https://www.statsmodels.org/stable/examples/notebooks/generated/multivariate_ls.html)
* [MATLAB `manova` documentation](https://www.mathworks.com/help/stats/manova.html)
* [Stata ANOVA/MANOVA features](https://www.stata.com/features/anova-manova/)
