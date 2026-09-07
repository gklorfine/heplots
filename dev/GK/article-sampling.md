# Article Sampling Plan

**GK: Still reviewing this**

## Purpose

The article sample will be used to answer two related questions:

1. How common are multivariate outcome analyses in the selected literature?
2. When researchers use these analyses, how do they interpret, visualize,
   and report the results?

These questions require different samples. Prevalence must be estimated from
a fixed sample of empirical articles, including articles that do not use a
multivariate analysis. The main survey requires a sample of articles that do
use an eligible multivariate analysis.

The two samples can be obtained from the same randomly ordered article lists.

## Scope

Before sampling begins, the following will be fixed in a written protocol:

* the field and subfields covered by the review;
* the journals included and the reason each was selected;
* a fixed calendar period;
* the definition of an empirical article;
* the definition of an eligible multivariate analysis;
* the prevalence sample size for each journal, denoted by $m_j$; and
* the target number of eligible articles for the main survey in each journal,
  denoted by $n_j$.

A fixed calendar period is preferable to working backward from the date of
data collection. It can be reproduced later and avoids ambiguity about
partial issues and articles published online ahead of an issue.

If the review covers several areas, the journals will be grouped by
subfield. Journal selection will not be based only on prestige. The aim is to
define clearly which part of the literature the results represent. Journal,
publisher, subfield, and publication year will be recorded so that differences
among them can be examined.

## Sampling Unit

The article will be the sampling unit. An article will be retained for the
main survey if it contains at least one eligible study or analysis.

If a retained article contains several eligible studies, all of them may be
coded, but they will be recorded as studies nested within one article. They
will not be treated as independent sampled articles. If coding every eligible
study is not practical, a rule for selecting one study per article will be
set before screening begins.

## Working Eligibility Rules

The final rules will be settled during the pilot. The intended main-survey
population is empirical articles that jointly analyze at least two continuous
response variables using MANOVA, MANCOVA, or a multivariate linear model.

The following will normally be excluded:

* editorials, corrections, book reviews, letters, and other nonresearch
  material;
* theoretical or review articles without an empirical study;
* articles that measure several outcomes but analyze each only in a separate
  univariate model;
* multilevel models that are called "MLMs" but are not multivariate linear
  models;
* structural equation, latent-variable, and dimension-reduction analyses
  unless they also include an eligible multivariate linear analysis; and
* repeated-measures or mixed-effects analyses unless they fall within the
  final stated scope.

Borderline cases and reasons for inclusion or exclusion will be recorded.
The eligibility rules will not be changed in response to whether an article
would make an interesting example.

## Constructing the Article Lists

For each journal, a list of articles published during the selected calendar
period will be assembled from a consistent bibliographic source. The list
will contain, where available:

* article title;
* authors;
* journal;
* publication year;
* volume and issue;
* DOI or another stable identifier;
* article type; and
* abstract.

Duplicate records will be removed. Clearly identified nonarticle material,
such as corrections and front matter, may be removed before randomization.
Any decisions made at this stage will be documented.

The article itself, rather than a randomly generated volume, issue, and
position within an issue, will be sampled. Issues contain different numbers
of articles, so choosing each level separately would not give every article
the same probability of selection.

## Randomization

Each journal's article list will be randomly ordered once. The randomization
script, random seed, original list, and randomized list will be saved.

All screening will follow this order. Articles will not be substituted at
the researcher's discretion. When an article is excluded, screening will
continue with the next record in the randomized list.

If the bibliographic list includes articles later found not to be empirical,
those articles will be logged and screening will continue until the required
number of empirical articles has been reached.

## Stage 1: Prevalence Sample

For journal $j$, screen the randomized list until $m_j$ empirical articles
have been examined. Every one of these articles remains in the prevalence
denominator, whether or not it contains an eligible multivariate analysis.

The journal-specific estimate is

$$
\widehat{p}_j =
\frac{\text{number of eligible articles among the }m_j\text{ articles}}
     {m_j}.
$$

Only this fixed first sample will be used for the simple prevalence estimate.
Articles screened later under the stopping procedure will not be added to
the prevalence calculation, because the decision to stop then depends on the
number of eligible articles found.

If the aim is an overall estimate across journals, journal estimates will be
weighted by the number of empirical articles each journal published during
the sampling period. An unweighted average would give a small journal and a
large journal the same influence. Journal-specific estimates will also be
reported where the sample sizes are adequate.

## Stage 2: Main Survey Sample

Eligible articles found during Stage 1 will count toward the main-survey
target. Screening will then continue in the same randomized order until
$n_j$ eligible articles have been accumulated for journal $j$.

For example, if the prevalence sample contains 8 eligible articles and the
main-survey target is 30, screening will continue until another 22 eligible
articles have been found. Ineligible articles will be logged but will not be
included in the main survey.

Because the full article list was randomly ordered before screening, the
first $n_j$ eligible articles form a random sample of the eligible articles
in that journal. Eligibility must be determined using the prespecified rules,
not the perceived quality or usefulness of an article.

If the same number of eligible articles is taken from every journal, the
sample will be well suited to journal comparisons. It will not automatically
represent the overall distribution of eligible articles in the literature,
because journals differ in size and in the prevalence of multivariate work.
Pooled summaries will therefore either use suitable journal weights or be
described explicitly as summaries of a balanced journal sample.

## Screening Record

A screening log will be maintained with one row per article examined. It
will include:

* journal and article identifier;
* randomized position;
* whether the article is empirical;
* whether it contains an eligible multivariate analysis;
* the reason for exclusion, if excluded;
* whether full text was available;
* whether it belongs to the prevalence sample, main sample, or both;
* reviewer identifier; and
* notes on uncertain decisions.

Articles will not be marked ineligible merely because their full text cannot
be obtained. Reasonable attempts will be made to obtain the article through
library holdings or other legitimate sources. If it remains unavailable, it
will be recorded as unavailable and screening will continue to the next
article.

For the prevalence estimate, unavailable or unresolved articles will be
reported rather than silently removed. If necessary, a lower bound can treat
all unresolved articles as ineligible and an upper bound can treat all of
them as eligible. For the main survey, an unavailable eligible article may
be replaced by continuing through the same randomized list, with the
replacement and reason recorded.

## Coding Reliability

The eligibility form and main coding form will be tested during the pilot.
At least a subset of articles will be screened and coded independently by a
second reviewer. Disagreements will be discussed, and unclear rules will be
revised before the full study proceeds. Changes made after the pilot will be
dated and documented.

Particular attention will be given to distinctions that are easy to apply
inconsistently, including:

* multiple outcomes versus a joint multivariate analysis;
* an explicit response order versus an order inferred by the reviewer;
* a missing interpretation versus an interpretation with which the reviewer
  merely disagrees; and
* unavailable information versus evidence that a method was not used.

## Pilot and Final Sample Sizes

A pilot will be conducted before committing to the final values of $m_j$ and
$n_j$. It should include more than one journal and, if relevant, more than one
subfield. The pilot will estimate:

* the number of articles screened per hour;
* the proportion of empirical articles containing an eligible analysis;
* the time needed to code an eligible article;
* the frequency of unavailable full text;
* the frequency of ambiguous eligibility decisions; and
* agreement between reviewers.

The final prevalence sample size will be based on the desired precision of
the prevalence estimate and the available time. The main-survey sample size
will be based on the number of comparisons planned, the amount of detail in
the coding form, and the estimated coding workload. A smaller, carefully
coded sample with reliability checks is preferable to a larger sample that
cannot be coded consistently.

## Reporting

The final report will state:

* the journals and publication period;
* how the article lists were assembled;
* the randomization method and seed;
* the values of $m_j$ and $n_j$;
* the number screened, excluded, unavailable, and retained;
* reasons for exclusion;
* any departures from the protocol;
* prevalence estimates and their uncertainty;
* whether pooled results were weighted; and
* the amount of duplicate screening and coding agreement.

The randomized lists, screening rules, coding forms, and analysis code will
be retained so that the sampling procedure can be audited and reproduced.
