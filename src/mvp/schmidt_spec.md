# Spec: Schmidt citeStructure and <bibl> resolver

Two coupled but independent tasks. Do them in separate commits.

## Task 1: citeStructure for Schmidt's lexicon

### Structure (confirmed by inspection)

```
<div type="edition" n="urn:cts:engLit:schmidt.lexicon.perseus-eng1">
  <div type="textpart" subtype="alpha" n="A">       ← 26 of these, A–Z
    <entryFree><orth>Abandon,</orth>...</entryFree>  ← 20,101 total; NO @n
    <entryFree><orth>Abase,</orth>...</entryFree>
    ...
  </div>
</div>
```

The existing `refsDecl` uses a single-level `cRefPattern` down to the
alpha div. `<entryFree>` elements have no identifying attribute.

### What to do

Replace the existing `<refsDecl n="CTS">` with a `<citeStructure>`
element that formalises the alpha-level citation — sufficient for MVP
navigation. Entry-level addressing requires adding `@n` to 20,101
`<entryFree>` elements; that is a separate, later task. Do NOT
attempt it here.

Target `<citeStructure>`:

```xml
<citeStructure unit="alpha"
               match="//tei:div[@type='textpart'][@subtype='alpha']"
               use="@n">
  <citeData use="." property="dc:title"/>
</citeStructure>
```

Remove the old `<refsDecl n="CTS">` block entirely; replace with the
`<citeStructure>` above. Leave all other `<refsDecl>` blocks (if any)
in place.

Validate that the file still passes `jing` against `perseus_lexical.rng`
after the change. The existing content-level RNG errors are pre-existing
and not introduced here — compare error counts before and after to
confirm nothing new was introduced.

---

## Task 2: Schmidt <bibl> resolver

Script: `src/mvp/resolve_schmidt_bibls.py`

Converts Shakespeare citations in Schmidt from `<bibl n="shak. ...">` to
`<bibl><ref target="urn:cts:...">`. Always run `--dry-run` first.

### Input / output

- Input: `data/schmidt/lexicon/lexicon.xml`
- Output: same file modified in place, or a path passed as `-o`
- Use lxml for parsing and serialization. Do NOT use regex on raw XML.
- Do NOT load the DTD.

### Play-abbreviation → CTS identifier table

Build as a dict in the script. The CTS play identifier is the lowercase
Folger idno (= DraCor playid). Verify each mapping against the DraCor
corpus before committing. 43 abbreviations appear in Schmidt:

| Schmidt abbr | Play / Poem                  | CTS playid  |
|--------------|------------------------------|-------------|
| tmp          | The Tempest                  | tmp         |
| ham          | Hamlet                       | ham         |
| r3           | Richard III                  | r3          |
| mm           | Measure for Measure          | mm          |
| 2h6          | 2 Henry VI                   | 2h6         |
| lll          | Love's Labour's Lost         | lll         |
| 1h6          | 1 Henry VI                   | 1h6         |
| cym          | Cymbeline                    | cym         |
| tgv          | Two Gentlemen of Verona      | tgv         |
| wiv          | Merry Wives of Windsor       | wiv         |
| h5           | Henry V                      | h5          |
| cor          | Coriolanus                   | cor         |
| 1h4          | 1 Henry IV                   | 1h4         |
| mv           | Merchant of Venice           | mv          |
| wt           | The Winter's Tale            | wt          |
| lr           | King Lear                    | lr          |
| tro          | Troilus and Cressida         | tro         |
| 2h4          | 2 Henry IV                   | 2h4         |
| ant          | Antony and Cleopatra         | ant         |
| 3h6          | 3 Henry VI                   | 3h6         |
| oth          | Othello                      | oth         |
| jn           | King John                    | jn          |
| luc          | The Rape of Lucrece          | luc         |
| r2           | Richard II                   | r2          |
| ayl          | As You Like It               | ayl         |
| mnd          | A Midsummer Night's Dream    | mnd         |
| ado          | Much Ado About Nothing       | ado         |
| aww          | All's Well That Ends Well    | aww         |
| h8           | Henry VIII                   | h8          |
| rom          | Romeo and Juliet             | rom         |
| err          | The Comedy of Errors         | err         |
| ven          | Venus and Adonis             | ven         |
| tn           | Twelfth Night                | tn          |
| tit          | Titus Andronicus             | tit         |
| mac          | Macbeth                      | mac         |
| shr          | The Taming of the Shrew      | shr         |
| son          | Sonnets                      | son         |
| tim          | Timon of Athens              | tim         |
| jc           | Julius Caesar                | jc          |
| per          | Pericles                     | per         |
| lc           | A Lover's Complaint          | lc          |
| pp           | The Passionate Pilgrim       | pp          |
| pht          | The Phoenix and the Turtle   | pht         |
| e3           | Edward III — NOT Shakespeare | FLAG, skip  |

`e3` appears exactly once. Flag it in the dry-run report; do not resolve.

### Locator format → CTS passage component

| Format            | Example        | CTS passage      | Notes                              |
|-------------------|----------------|------------------|------------------------------------|
| act.scene.line    | `2.4.261`      | `2.4.261`        | 87.8% of cases; pass through       |
| act.scene         | `2.5`          | `2.5`            | Valid scene-level citation; pass through |
| line-only integer | `200`          | `200`            | Poems (Lucrece, V&A); pass through |
| sonnet roman.line | `cl.11`        | `150.11`         | Convert roman numeral → arabic     |
| act.chorus        | `4.chorus`     | `4.chorus`       | Pass through                       |
| act.chorusN       | `5.chorus1`    | `5.chorus1`      | Pass through                       |
| ind.scene.line    | `ind.2.77`     | `induction.2.77` | Expand `ind` → `induction`         |

For roman numerals (sonnets only): implement a small lookup dict for
i–cliv (1–154). Do not use an external library.

### URN construction

```
urn:cts:engLit:shakespeare.{playid}.globe:{passage}
```

Examples:
- `shak. lr 2.4.261`  → `urn:cts:engLit:shakespeare.lr.globe:2.4.261`
- `shak. tn 2.5`      → `urn:cts:engLit:shakespeare.tn.globe:2.5`
- `shak. luc 200`     → `urn:cts:engLit:shakespeare.luc.globe:200`
- `shak. son cl.11`   → `urn:cts:engLit:shakespeare.son.globe:150.11`
- `shak. h5 4.chorus` → `urn:cts:engLit:shakespeare.h5.globe:4.chorus`
- `shak. shr ind.2.77`→ `urn:cts:engLit:shakespeare.shr.globe:induction.2.77`

### Element transformation

```xml
<!-- Before -->
<bibl n="shak. lr 2.4.261">Lr. II, 4, 261</bibl>

<!-- After -->
<bibl><ref target="urn:cts:engLit:shakespeare.lr.globe:2.4.261">Lr. II, 4, 261</ref></bibl>
```

- Remove `@n` from `<bibl>`; preserve any other `<bibl>` attributes
- Wrap existing text content and child nodes with `<ref target="...">`
- Non-`shak.` `@n` values (Bible, classical — 22 total): leave unchanged
- `<bibl>` without `@n` (14 total): leave unchanged

### Malformed @n: flag and skip

Leave the element unchanged; report in dry-run:

- Bare work: `shak. luc` (no locator) — 53 cases
- Duplicated token: `shak. ven ven` — 18 cases
- Non-Shakespeare: `shak. e3 ...` — 1 case

Total expected: ~72.

### Dry-run output

```
SCHMIDT <bibl> RESOLVER — DRY RUN
===================================
Total <bibl> elements:             233374
  shak. @n (candidates):           233360
  Non-shak. @n (leave as-is):          22
  No @n (leave as-is):                 14

  Would resolve:                   233216
    act.scene.line:                204766
    act.scene:                      15732
    line-only (poems):              12708
    sonnet (roman.line):               56
    chorus / induction:                 5
  Would flag — malformed:              72
    bare work-only:                    53
    duplicated token:                  18
    non-Shakespeare (e3):               1

MALFORMED (all 72)
------------------
[alpha div, orth context, @n value — one per line]

SAMPLE RESOLUTIONS (5 per locator type)
-----------------------------------------
act.scene.line:
  shak. lr 2.4.261  →  urn:cts:engLit:shakespeare.lr.globe:2.4.261
  ...
act.scene:
  shak. tn 2.5  →  urn:cts:engLit:shakespeare.tn.globe:2.5
  ...
```

Exit code 0 in dry-run. Do not run the output pass until Cliff has
reviewed this report.

### Validation (after output pass)

- lxml parses the output without error
- `grep` finds zero `<bibl n="shak.` remaining
- Count of `<ref target="urn:cts:engLit:shakespeare` matches "would
  resolve" from dry-run
- Spot-check: 5 malformed elements still have `@n` unchanged

### Usage

```sh
# Always dry-run first
python src/mvp/resolve_schmidt_bibls.py --dry-run \
    data/schmidt/lexicon/lexicon.xml

# Output pass — only after reviewing dry-run
python src/mvp/resolve_schmidt_bibls.py \
    data/schmidt/lexicon/lexicon.xml \
    -o data/schmidt/lexicon/lexicon.xml
```

---

## Out of scope for this task

- Abbott, Onions, Dyce: separate tasks with different prerequisites
- Entry-level `@n` on `<entryFree>`: deferred
- CorpusMap scene_range / act_range: a separate corpus-tools task;
  this resolver uses Globe URNs only — no CorpusMap lookup needed
