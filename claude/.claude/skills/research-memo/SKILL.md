---
name: research-memo
description: Turn a business or product question into a decision-grade memo — problem brief, verified evidence, open bets with priors, and an explicit proceed-or-stop.
disable-model-invocation: true
---

Produce **one document** that answers a question well enough to act on, and that is honest
enough to say no.

This file describes the **output**, not a procedure. Work out your own route to it. What is
not negotiable is what the finished thing contains and the properties it satisfies.

Publish it as an Artifact unless told otherwise — it is long, it has tables, and it will be
read by someone who wasn't in the room.

---

# The deliverable

Seven parts. In this order, because the order is an argument.

## 1 · The brief

**Agreed with the user before any research.** This is the only part that is a conversation
rather than something you produce alone. Ask these one at a time and wait:

1. Whose problem is this, and how do they handle it today?
2. What does it cost them — money, time, or something they can't name?
3. If this worked, what number would move, and by how much?
4. What do you believe right now, and how confident are you?
5. What would make you stop?
6. What has to be true for this to work that you haven't checked?
7. Do you already have a solution in mind?

From that, write:

- **The problem, stated without a solution in it.** Mechanical test: if you cannot write it
  without naming the thing they want to build, they have started from a solution and you
  must say so. A truism ("people can't find partners") fails differently — it must be
  specific enough to be wrong.
- **Who has it, how badly, and whether they already pay to solve it.**
- **The questions, numbered, each with what it decides.** If an answer would not change what
  they do, cut it before it costs a week.
- **What evidence would count, per question, fixed in advance.** This exists to stop the
  goalposts moving when an answer is inconvenient.
- **Kill criteria** — what would make them walk away, pre-committed.
- **Starting beliefs, with confidence.** On the record, numerically where possible.
- **Declared solution-attachment**, if any, kept out of the problem statement.

Revisit the brief at the end and **show what moved**. The update is the most informative
thing in a research project and it is invisible unless the starting position was written down.

## 2 · What's established

Findings that will not change with more work. Each carries its effect size, the sample it
came from, and a plain statement of what it means.

**Null and refuted results belong here and usually matter more than the positive ones.**
"Everyone does X and there is no evidence for it" changes more decisions than any confirmation.

## 3 · What's assumed

A register of open bets, one entry each, fixed schema:

> **claim** · **honest prior, with the reason** · **the specific data that would settle it** ·
> **what it costs to find out** · **what changes if true, and if false** · **status**

Priors are the part that gets fudged. "Probably false, and here is why" beats a neutral
description. Rank them by what they decide, not by how interesting they are.

Every bet must derive from a numbered question in the brief.

## 4 · What we'd do

The plan. **Every line tagged with its provenance** — an established finding with its
citation, or a bet ID.

The reader scans one column and sees how much of the plan is speculation. Expect this to be
uncomfortable: the defensible parts are usually the boring ones.

## 5 · Who else is doing this

Diagnostic, not descriptive. For each: what they do, how they are faring, and **specifically
which failure mode** — because different ones have opposite implications. A competitor dying
of long onboarding is fatal to a plan with longer onboarding; one dying of coordination
failure validates a plan that fixes coordination.

Two passes, at different times:

- **An existence check, early and cheap.** Who is funded, who is dead. An hour. It can end
  the project before the expensive work starts.
- **The diagnostic read, late.** You can only interpret a competitor's failure once you know
  what should work.

## 6 · Proceed or stop

Conditions that would have to hold. Alternatives if they don't. And **explicit permission to
stop** — a research document that can only conclude "yes" is not research.

## 7 · Reference

Glossary that says **how each construct was actually measured**, not just what it means.
Verified sources. Stated coverage limits.

---

# Acceptance criteria

Hard requirements. A memo that fails any of these is not finished.

- [ ] **Every finding traces to a numbered question in the brief.** Anything that doesn't
      gets cut, however interesting.
- [ ] **Every number sits on a scale the reader already has.** An effect size alone is
      decoration. Include an anchor table using quantities they have intuitions about before
      quoting anything.
- [ ] **Every number carries what was measured, in whom, by whom, and what it means.** In a
      research memo the measurement *is* the finding.
- [ ] **Every claim about the world was fetched, not remembered.** Anything about who exists,
      what they ship, what something costs. Memory produces confident, plausible, wrong.
- [ ] **Citations verified before publishing.** Assume roughly a fifth are wrong — wrong
      papers, near-miss identifiers, references that fuse two real sources. Check them.
- [ ] **Free full text linked where it exists**; where it doesn't, say "paywalled" rather
      than linking to a login wall.
- [ ] **The load-bearing assumption is named.** Every project has one thing everything rests
      on. State it, and state that it is a bet.
- [ ] **Falsification thresholds written before results exist** — including the awkward one:
      what result would be *too good* and should be investigated as a bug.
- [ ] **Corrections stay visible.** Where the memo was wrong, it says so. A reader who
      spot-checks one claim and finds it sound learns far less than one who can see the error
      rate and the fixes.
- [ ] **Coverage limits stated.** "Not found" and "didn't look" are different claims.
- [ ] **Section summaries state conclusions, not contents.** "This section covers X" is
      wasted space.

---

# How it fails

- **Starting from the solution.** The problem is the thing to fall in love with. If the brief
  can't be written without the product in it, stop and fix the brief.
- **A beautiful survey that decides nothing.** Every finding cashes out or is discarded with
  a reason.
- **Confusing what's known with what's hoped.** Parts 2 and 3 exist to keep them apart, and
  part 4's tagging exists to keep them apart under pressure.
- **Market claims from memory.** The most common source of confident error.
- **Quietly deleting your own mistakes** instead of recording them.
- **Concluding "yes" because the work was expensive.** The kill criteria were written in the
  brief for exactly this moment.
