# Recommended Framing

**Result of a GPT conversation on 09/03/2026**

  **GK: Also includes my written notes in this format**

## From Omnibus Tests to Understanding: Improving the Interpretation of
## Multivariate Linear Models

  **GK: Don't like this title but something along the lines of improving interpretation + accessibility might work.**

The central problem is not that researchers lack ways to fit multivariate
linear models (MLMs). It is that conventional output often stops at an
omnibus significance test, leaving the substantive structure of the
multivariate effect unclear. Visualization, conditional interpretation, and
joint prediction remain underused or inaccessible.

The proposal could ask three connected questions:

1. **How are MLMs currently used and communicated?**

   Conduct a focused scoping review of applied studies using genuinely
   multivariate designs. Examine which analyses and visualizations are
   reported, what follow-up procedures are used, and where potentially
   important interpretations are missed.

   **GK: I feel like this is the step that's missing substance. RB should be a fleshed out example of this, e.g., one fork in the road, but I am having trouble thinking of what the other examples might be. I think  more substance here might make the following steps (2 & 3) fold neatly into this and give the overall idea.**

2. **When can ordered-response analysis provide additional insight?**

   Identify studies in which the responses have a substantively defensible
   priority order. Use these as case studies to evaluate what
   Roy--Bargmann stepdown analysis reveals beyond the reported omnibus
   MANOVA.

3. **How can these interpretations be made visual and accessible?**

   Develop an auditable R implementation and complementary visualizations:
   the effect-by-response display, decomposition of Wilks' lambda,
   conditional drill-down plots, and response-order sensitivity analysis.
   An interactive Shiny interface can disseminate the methods and make the
   conditional logic easier to explore.

This creates a clear progression:

> Observe current practice -> identify an interpretive gap -> develop and
> evaluate a response -> make it accessible

## Why This Is the Strongest Option

It combines the best elements of both sides of the email conversation:

* Michael's desire for a broader topic than Roy--Bargmann alone;
* Gavin's concrete, already-developed Roy--Bargmann work;
* an empirical basis for claiming that a problem exists;
* a natural route to applied examples and reanalyses; and
* accessible software and visualization as knowledge mobilization.

It also produces three kinds of contribution:

* **Empirical:** Evidence about how MLMs are used and visualized in applied
  research.
* **Methodological:** New visual and diagnostic treatment of an established
  stepdown procedure.
* **Translational:** Open-source and potentially interactive tools for
  applied researchers.

That is more compelling than "I will add functions to an R package," while
remaining far more coherent than "I will modernize everything about MLMs."

## How I Would Scope It

The literature review should not simply search for datasets suitable for
Roy--Bargmann analysis. That could make the review appear designed to
justify a predetermined method. Instead, begin with the broader
interpretability question and treat ordered responses as one important
pattern discovered or quantified within it.

A manageable sequence would be:

### Objective 1: Characterize Present Practice

Use a reproducible scoping review in one or two substantive fields where
multivariate outcomes are common. Code such features as:

  **GK: Focus only on psychology? Or across the behavioural sciences (perhaps too broad)?**
  
  **GK: Need to be careful here to keep things justifiably-NSERC, or switch to a SSHRC application**

* reasons given for using MANOVA or an MLM;
* number and nature of response variables;
* whether response variables have a natural or explicitly stated priority;
* omnibus statistics reported;
* univariate or multivariate follow-up procedures;
* treatment of response correlations;
* use and type of data visualization; and
* availability of data or sufficient summary information for reanalysis.

    **GK: Need to figure out how to code/operationalize "opportunity missed"**

Restricting the disciplinary scope, publication period, or journal sample
will be essential for feasibility.

  **GK: **
  
  - **See above "GK:" comment for disciplinary scope. Journal choice will follow this (will narrow by subdiscipline, choose most reputable journals for each; try to keep a balance of publishers to control for things like submission guidelines).**
  - **Publication period: 2020-2025?**
    
<!-- OUTDATED/WRONG: See `dev/GK/article-sampling.md`

    prioritize recency; log the date at which article collection starts. Articles will then be taken from the volume and issue most recent to this date, in reverse order of appearance. Moreover, the first article I record would be the last article in the most recent volume and issue. Once articles are exhausted, I would then move to the next-most recent journal volume and/or issue. I would then take the second to last article, third to last, etc., stopping when $n$ articles are collected for that given category.
-->
  - **Number of articles: 250-500**
  - **Further inclusion criteria: contains one or more studies with a reported multivariate outcome.**

### Objective 2: Develop and Evaluate Visual Stepdown Analysis

The Roy--Bargmann work would be the proposal's methodological centre:

* model-native analysis of terms in MANOVA and MANCOVA;
* computational checks showing how component lambdas reconstruct Wilks'
  lambda;
* effect-by-response visualization;
* additive $-\log(\lambda)$ decomposition;
* conditional plots for individual components; and
* sensitivity analysis across prespecified, substantively plausible
  response orders.

The key claim is not that Roy--Bargmann analysis itself is new. The
contribution is to make it **auditable, visual, order-aware, and
accessible**, rather than a printed sequence of ANCOVA tests.

### Objective 3: Demonstrate Usefulness and Accessibility

Reanalyse a small, purposively selected set of published examples for which:

* the response ordering has a substantive justification;
* adequate data are available; and
* the original analysis leaves an identifiable interpretive question
  unresolved.

  **GK: Is it necessary to specify a course of action for if no articles fit these criteria? I am thinking that all three are likely, but perhaps not all at once. An idea: make up plausible data if no adequate data is available, as RB would allow for an interpretive question to be resolved if response ordering has substantive justification (which I'd think would be practically certain to find at least one case in N > 250 multivariate articles).**


The Shiny app would be an important accessibility and dissemination
component. It would lower the technical barrier to using these methods by
allowing researchers to upload their data, select an analysis or display
through a guided interface, and interpret output without needing to
write R code. Embedded explanations could also help users understand what to
look for and how each display relates to the statistical results. Thus, the
app can reasonably be described as making the methods more accessible by
design. A stronger claim that the interface has been shown to improve
usability or interpretation would require formal user evaluation.

In particular, the app could:

* expose the conditional models behind each display;
* guide users through data upload and analysis selection;
* allow users to compare plausible response orders;
* connect effect-table cells to conditional plots; and
* illustrate how the decomposition relates to the omnibus result, with
  guidance on interpreting the visual output.
