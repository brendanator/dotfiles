---
name: review-ai-writing
description: Review writing for AI-sounding patterns and propose fixes. Use when the user wants to check their writing for AI tells, improve naturalness, or humanize text.
argument-hint: <file-path>
allowed-tools: Read, Glob, Grep, Bash(uv run *)
---

# Review writing for AI tells

The rubric below is inlined deliberately. Do not fetch anything to run a review.

## Method

1. Read the file at `$ARGUMENTS`. If no path was given, ask which file to review.
2. Walk each paragraph against the rubric. Only report patterns actually present.
3. Weigh the counter-evidence in "Signs of human writing" before concluding.
4. Report as described under "Output".

**Mixed authorship is the normal case.** Most real documents are a human draft with assisted
sections, or the reverse. Whole-document density is meaningless there: a strong human section
dilutes the numbers, and a scaffolded section incriminates its neighbours by proximity. When
passages differ sharply, assess them separately. Do not average a document into a single verdict it
doesn't have.

**But naming a boundary is a high bar.** A seam is a sharper claim than a whole-document verdict, so
it needs more evidence, not less. Claim one only when **two adjacent passages each independently
clear a bar** — one saturated enough to stand as a finding on its own, one carrying real
counter-evidence. One clean passage beside one stray word is not a seam. Where hits merely cluster,
describe the distribution ("the hits are confined to the final sentence") and stop there. That
describes the text; a boundary claim asserts a history you cannot see.

Skip entirely: code blocks, YAML frontmatter, file paths, identifiers, command names, and any
quoted passage the text itself presents as a bad example.

## Calibration

Read this before flagging. It is the difference between a useful review and a nuisance. The pattern
lists below are a catalogue of shapes; this section is the judgment that decides which shapes are
evidence. When the two conflict, calibration wins — a shape that matches but carries real meaning is
not a finding.

- **Density over instance.** One or two rubric words may be coincidence. Many, repeatedly, is the
  tell. Measure density **per passage, not per document** — nine hits in one paragraph is a finding;
  the same nine spread over four pages is noise. Say "nine hits in a 45-word paragraph", not "this
  text contains 'crucial'". **Density has a floor**: a passage under roughly 100 words cannot carry
  a density finding by itself, because any rate computed over a short span is noise. Two hits in a
  short closing paragraph is two hits, not a cluster. Zooming in until the rate looks alarming is a
  way of manufacturing evidence.
- **Genre sets the base rate.** A construction's frequency in honest human prose varies by what is
  being written. Contrastive negation is native to debugging narratives and postmortems ("it wasn't
  latency, it was head-of-line blocking"); trailing significance is native to marketing. Judge a
  shape against its genre, not against a global average.
- **The word, not its synonyms.** A word being overused by LLMs says nothing about words that mean
  the same thing. `underscore` is a tell; `emphasise` is not, and neither is every long word.
- **Context defeats the list.** `underscore` can be an underline or incidental music. `key` can be
  a physical key. Read the sentence.
- **Humans are bad at this.** A 2025 study found people distinguish LLM from human text at about
  chance; another found 57% on AI text and 64% on human. Heavy LLM users reach roughly 90%, which
  still means one false positive in ten. Never assert authorship — describe patterns.
- **Detectors are not evidence.** GPTZero and similar have non-trivial error rates and are fooled by
  paraphrasing and spacing changes. Do not run one, do not cite one.
- **Human prose is drifting.** LLM influence on human writing is measurable, including in speech.
  These tells are weakening over time.
- **Pre-2023 text is exonerated.** ChatGPT launched 30 November 2022. Older writing predates all of
  this, however it reads.
- **The tells are era-stamped.** `delve` peaked in 2023–24 and collapsed in 2025; the current
  cluster is *emphasising*, *highlighting*, *showcasing* and the notability language. Absence of the
  famous words is not absence of the tell — check the current era's list before concluding a text is
  clean.

## Content patterns

**Inflated significance.** Arbitrary details are tied to broader trends or lasting legacies.
Watch: *stands/serves as*, *is a testament/reminder to*, *a vital/crucial/pivotal/key role/moment*,
*underscores/highlights its importance*, *reflects broader*, *symbolising its enduring/lasting*,
*contributing to the*, *setting the stage for*, *marks a shift*, *key turning point*, *evolving
landscape*, *focal point*, *indelible mark*, *deeply rooted*. Suspect it most on mundane subjects —
etymology, population counts — and where a hedge precedes the puffery anyway ("Though it saw only
limited application, it contributes to the broader history of…").

**Superficial analysis in a trailing participle.** A clause bolted to a sentence's end that
interprets rather than states. Watch sentences ending *, highlighting…*, *, ensuring…*, *,
reflecting…*, *, contributing to…*, *, fostering…*, *, enhancing…*. Delete the clause; if nothing is
lost, it was never carrying anything.

**Promotional drift.** Travel-guide or press-release tone regardless of subject. Watch: *boasts a*,
*vibrant*, *rich*, *profound*, *nestled*, *in the heart of*, *natural beauty*, *groundbreaking*,
*renowned*, *diverse array*, *commitment to*, *showcasing*, *exemplifies*. Note that newer models
are subtler than GPT-4 was — they avoid outright superlatives while staying relentlessly positive.

**Vague attribution.** Opinions credited to an unnamed authority: *Industry reports*, *Observers
have cited*, *Experts argue*, *Some critics argue*, *several publications* while one is cited, or
*such as* implying a list is non-exhaustive when it is exhaustive.

**Canned notability claims.** Insisting a subject matters by listing where it was covered and
what kind of outlet each is: *independent coverage*, *regional/national media outlets*, *trade
publications*, *profiled in*, *maintains an active social media presence*.

**Formulaic challenges-and-future endings.** "Despite its [positives], X faces challenges…"
resolving into vague optimism, or a standalone *Future Outlook* / *Challenges and Legacy* section.
The formula is the tell, not the mention of difficulty.

## Chatbot scaffolding

The strongest signal in the rubric, because it is not a stylistic tendency — it is the assistant's
own voice left in the text. Where you find one instance, read the whole document again.

**Correspondence pasted in as content.** Text addressed to the person who prompted, rather than to
the reader: *Certainly!*, *Of course!*, *You're absolutely right!*, *I hope this helps*, *Would you
like me to…*, *is there anything else*, *let me know*, *Here is a…*, *a more detailed breakdown*.
Also an assistant narrating what it produced, or naming the conventions it followed.

**Knowledge-cutoff disclaimers.** *As of my last knowledge update*, *up to my last training update*,
*while specific details are limited/scarce*, *not widely available/documented*, *based on available
information*, *in the provided sources*. Retrieval-based models produce these too, hedging about
gaps in what they found rather than about training data.

**Placeholder text.** Unfilled templates — `[insert X]`, `[Your Name]`, `[citation needed]` where
nobody would put it — and phrasal scaffolding left unresolved.

## Language patterns

**AI vocabulary at density.** *Additionally* (opening a sentence), *align with*, *boasts* (meaning
has), *bolstered*, *crucial*, *delve*, *emphasising*, *enduring*, *enhance*, *fostering*, *garner*,
*highlight* (verb), *interplay*, *intricate/intricacies*, *key* (adjective), *landscape* (abstract),
*meticulous*, *pivotal*, *robust*, *showcase*, *tapestry* (abstract), *testament*, *underscore*
(verb), *valuable*, *vibrant*. These cluster — where one appears, expect others. Rough eras: 2023 to
mid-2024 favoured *delve*, *tapestry*, *intricate*, *meticulous*, *bolstered*; mid-2024 to mid-2025
favoured *align with*, *fostering*, *showcasing*, *enhance*; mid-2025 on favours *emphasising*,
*highlighting*, *showcasing*. Grok skews to *causal*, *empirical*, *correlate*, and still
*underscore*.

**Copula avoidance.** *is/are* replaced by *serves as*, *stands as*, *functions as*, *operates as*,
*represents*, or by marketing verbs *features*, *offers*, *boasts*, *maintains* where *has* would
do. Also *refers to* in a definitional opener, and elaborations like *ventured into politics as a
candidate* for *was a candidate*. Usage of *is* and *are* fell over 10% in academic writing from
2023.

**Negative parallelism.** *Not only X but also Y*; *It's not X, it's Y*; *no X, no Y, just Z*; and
the reversed *X rather than Y* (common in Grok). Can span sentences: a claim, then "however," then
the reversal. Only flag it when **the negated half is a straw man** — the contrast exists to sound
incisive while both halves say the same thing. A real hypothesis being ruled out is not a tell:
"Latency was not the problem — the problem was head-of-line blocking" rules out one cause and names
another, and deleting the negation loses information. Apply the same delete-and-see test you would
to a trailing participle. Note also that *rather than* is a plain English comparative; a bare
preposition is not evidence of anything.

**Rule of three.** Adjective triples, or three parallel phrases, used to make thin analysis look
thorough. Only flag when the three items are interchangeable padding — three genuinely distinct
things are not a tell.

**Elegant variation.** Synonym-churn driven by repetition penalties: the same referent renamed each
time it appears. Note that non-native speakers are often taught to avoid repetition, so this is weak
alone.

## Style patterns

**Title Case Headings** where sentence case belongs.

**Mechanical boldface.** Every instance of a chosen term bolded, key-takeaways style, inherited from
READMEs and slide decks.

**Inline-header vertical lists.** Bullets shaped `**Header**: description`, often with literal `•`,
`-`, or `1.` markers. Sometimes the colon is missing and the header just runs into the text.

**Em dashes.** LLMs use them more than non-professional human writing of the same genre, and
formulaically — punching up a clause where a comma or colon would serve. Weak on its own, much more
common in discussion than prose, and useful only alongside other tells. Spacing is not a
discriminator: plenty of house styles set dashes spaced. A matched pair around an aside is ordinary
human punctuation. GPT-5.1 actively suppresses them, so absence proves nothing either.

**Emoji as structure.** Emoji prefixing headings or bullets. Mostly a 2023–25 artefact.

**Needless small tables** for content that should be prose.

**Curly quotes and apostrophes** (“ ” ‘ ’), especially mixed inconsistently with straight ones.
Weak: macOS, iOS, and Word produce these by default, as does any Chicago-styled publication, and
Claude and Gemini models typically do not emit them.

**Markdown artefacts in non-Markdown contexts**, thematic breaks (`---`) before every heading, or
heading levels starting at `###`.

## Signs of human writing

Treat these as evidence *against* AI authorship, and never flag them as faults:

- Simple *is/has* constructions: *there is a*, *it has a*.
- Plain words where a stiff synonym exists: *wrote* not *authored*, *moved* not *relocated*, *used*
  not *utilised*, *tried* not *attempted*, *died* not *passed away*.
- Superlative or definitive claims: *one of the best*, *is the only*, *was the first*.
- Hedges and intensifiers: *very*, *perhaps*, *tends to*.
- Wordy constructions: *as a result of*, *in order to*, *all of the*, *the fact that*.

## Ineffective indicators — do not flag these

- **Perfect grammar.** Plenty of people write well.
- **Mixed casual and formal register.** Common in technical writers, young writers, neurodivergent
  writers, and any multi-author document.
- **Bland or robotic prose.** LLM output skews positive and verbose, which is not the same thing.
- **Fancy or academic prose.** The tells are *specific words*, not long words generally.
- **Letter-like writing** with salutations and sign-offs. Predates LLMs by centuries.
- **Transition words alone.** Only a few are actually overused, and style guides endorse them.
- **Unsourced claims.** Over 570,000 Wikipedia articles predate LLMs and lack citations; modern
  chatbots cite constantly, if inaccurately.

## Output

For each finding:

- **Pattern** — which rule from the rubric
- **Location** — the text, quoted
- **Why** — one sentence
- **Fix** — a concrete rewrite or a deletion

Where a passage is saturated, report it as **one passage-level finding** with its hits broken out
beneath. That is more honest than a row per hit: they are not independent observations, they are one
insertion counted many times. The same trap exists at the word level — several rubric sections name
the same word (*pivotal* sits under both inflated significance and AI vocabulary), so one word can
masquerade as two corroborating patterns. Count the insertion, not the rules it matches.

**Weak findings are not additive, but a list makes them look additive.** Two Weak rows side by side
read as one Moderate to anyone skimming. When everything you have is Weak, write a sentence of prose
instead of a table.

Grade by the strength of the evidence, never by the name of the pattern. The same pattern can be a
Strong finding in one document and a Weak one in another; that is the intended behaviour.

1. **Strong** — chatbot scaffolding, which needs no corroboration. *Or*, independently of
   scaffolding: hits dense enough within a passage that coincidence is a poor explanation.
2. **Moderate** — a pattern rare in human prose, recurring, but not at a density that settles it.
3. **Weak** — isolated hits, or patterns that mean nothing without company.

Both doors to Strong are real. A passage with no scaffolding at all still qualifies on density
alone.

Your findings are a structured list, which is a genre where labelled fields are conventional. The
inline-header rule governs prose, so the report format below does not violate it — that is the
"context defeats the list" rule applied to your own output.

Close with: counts per group, the two or three changes that would matter most, and an honest
assessment — scoped per passage where the document is mixed, rather than one verdict it doesn't
have. If the text reads as human, say so plainly. A clean review is a valid result, and reaching for
weak signals to pad a short report is the failure mode here.

Apply this rubric to your own report.

## References

The rubric is adapted from the sources below. It is a restatement of their rules in our own words,
not a copy of their text.

- [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) —
  the primary source, and the only one still actively maintained. Content, language, and style
  patterns, the calibration notes, the human-writing signs, and the ineffective indicators all
  derive from it. Its own shortcuts are worth knowing: `WP:AIVOCAB` (vocabulary), `WP:AIPARALLEL`
  (negative parallelism), `WP:RO3` (rule of three), `WP:AIDASH` (em dashes), `WP:AIPUFFERY`
  (promotional tone), `WP:AIWEASEL` (vague attribution), `WP:SUPERFICIAL` (trailing participles),
  `WP:CERTAINLY` (chatbot correspondence), `WP:AICUTOFF` (knowledge-cutoff disclaimers),
  `WP:AIDETECTIVE` (why you are worse at this than you think). Text is CC BY-SA 4.0.
  Snapshot taken 2026-07-17. Run `refresh_rubric.py` to diff this against the live page.
- [tropes.fyi](https://tropes.fyi/tropes-md) — a single-file list of AI writing tropes.
- [How to Humanize Your AI Writing in 10 Steps](https://www.thealgorithmicbridge.com/p/how-to-humanize-your-ai-writing-in),
  The Algorithmic Bridge.
- [The Ten Telltale Signs of AI-Generated Text](https://www.theaugmentededucator.com/p/the-ten-telltale-signs-of-ai-generated),
  The Augmented Educator.
