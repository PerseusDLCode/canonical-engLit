This is a text-encoding project to refurbish the TEI encoding of the
works comprising Perseus's Early Modern English (Renaissance)
collection.

The primary goal is to include Perseus's Early Modern English
collection in the new Minimum Viable Perseus (MVP), starting with the
works of Shakespeare.

## Authority of this file

This file describes stable facts and conventions. It does **not**
record project decisions, scope, or task state. Those live in:

- `doc/forum.org` — design deliberation, one entry per question, with
  `CUSTOM_ID` anchors
- `doc/agenda.org` — task tracking, phases, assignees, dependencies

When this file and `forum.org` disagree, **`forum.org` wins** — and the
disagreement is a bug in this file that should be fixed. (This has
happened: a Gotcha here declared the non-dramatic works out of scope,
contradicting `forum.org`, and the error went unnoticed for weeks until
it distorted a citation-resolution survey.)

## Repository structure

### This repository

- `data/` — refurbished TEI P5 encodings. This is the working
  directory. All editing and transformation should target files here.
- `Renaissance/` — original P4 encodings. Read-only reference; do not
  modify. **See the Gotcha below: these are more trustworthy than the
  P5 derivatives in `data/`, and are the authority in any conflict.**
- `schemas/` — outdated TEI customizations from a prior refurbishment.
  Do not use.
- `src/` — one-off scripts from the prior corpus refurbishment, most of
  them specific to individual Marlowe plays or other non-Shakespeare
  texts. Do not reuse them for Shakespeare without careful inspection;
  write new tools instead.
- `doc/` — project documentation (see above).

### Sibling repositories

Located alongside this one under `PerseusDLCode/`:

- `perseus-schemas` — the current TEI customizations. Referenced from
  documents by raw-GitHub-URL `<?xml-model?>` PIs; this is the
  project-wide convention.
- `corpus-tools` — the shared transformation toolchain (Python CLI +
  XSLT + Schematron gate). New corpus-wide tooling belongs here, not in
  this repo's `src/`.
- `schmidt-lexicon-workshop` — the Schmidt record-extraction pipeline.
  See the Schmidt section below.
- `MinimumViablePerseus` — the consuming application.

## Branches

Work happens on topic branches (`schmidt`, `n-equal-chunk`, …) merged
into `mvp`, the integration branch for this sprint. `mvp` was branched
from `p6`. Check `git branch` rather than trusting this paragraph for
which branch is current.

## Tools

**XSLT:** Use Saxon for all XSLT processing. Stylesheets in this
project use XSLT 3.0 features and will not run correctly under
xsltproc (XSLT 1.0) or other processors.

```sh
saxon -s:input.xml -xsl:transform.xsl -o:output.xml
```

**Validation:** Validate against the appropriate schema from
`perseus-schemas`, using jing, plus the `corpus-tools` Schematron gate:

- Shakespeare plays → `perseus_drama.rng`
- Abbott (grammar) → `perseus_prose.rng`
- Schmidt, Onions, Dyce (lexica) → `perseus_lexical.rng`

## Encoding conventions

**`@part` on `<l>`:** Only the values `I`, `M`, `F`, and `Y` are
meaningful. `@part="N"` is the TEI default and carries no information;
never add it, and strip it if encountered. Do not confuse absence of
`@part` with the presence of `@part="N"` — they are equivalent.

**`<lb>` placement:** Per TEI P5 §3.10.3, `<lb/>` marks the
*beginning* of the line it labels, not the end. Place it immediately
before the content of the line it numbers.

**CTS URNs:** The namespace for this corpus is `urn:cts:engLit:`.
Settled with Alison Babeu (see `forum.org`
`#citations/cts-urns-and-citation-families`):

- Textgroup identifier is `shakespeare` (not `shak`).
- Works are identified by the MLA convention already used in the Globe
  filenames — King Lear is `urn:cts:engLit:shakespeare:lr`.
- Citation-family identifiers (`globe`, `f1`) double as file-level
  edition identifiers.

Identifiers for the reference works (Abbott, Schmidt, Onions, Dyce)
are less settled than the Shakespeare ones — check `forum.org` before
minting new URN components.

**Shakespeare source text:** The Globe editions have been set aside in
favour of ShakeDraCor's F1 texts, imported as
`data/shakespeare/{work}/shakespeare.{work}.f1.xml` with a per-work
`__cts__.xml`. The older flat Globe files (`data/shakespeare/{work}.xml`)
are still present and not yet migrated to the nested layout. F1
editions additionally carry a Folger Through-Line-Number refsDecl
derived from ShakeDraCor's `xml:id="ftln-NNNN"`.

## Gotchas

**The P5 derivatives in `data/` are not trustworthy. Check them against
their P4 ancestors in `Renaissance/`.** The 2025 corpus-wide P4→P5
migration was lossy in ways that went undetected for a year, and the
losses are silent — structure disappears without leaving an error. The
confirmed case is Schmidt: the P4 source carries a unique `@key` on
every one of its 20,101 `<entryFree>` elements, already disambiguating
homographs (`Bate1`/`Bate2`, `A1`–`A7`); the P5 derivative has no `@key`
and no `@xml:id` at all. Before building anything on a P5 file, compare
element and attribute inventories against the P4 original. Assume other
non-Shakespeare derivatives have comparable damage until audited.

**Do not parse with DTD validation or DTD loading enabled.** lxml (and
libxml2 generally) materializes default attribute values from the DTD
during parsing and writes them to output, polluting the serialized
files. This is the source of the `@part="N"` proliferation in the
current files. Always parse without DTD loading.

**`data/shakespeare/tro.xml` and `data/shakespeare/per.xml`** are
under-encoded: Troilus and Cressida has no `<lb>` markup at all;
Pericles has only 4. Do not treat these as representative of the
corpus; do not use them as test cases.

**`data/shakespeare/ven.xml` and `data/shakespeare/luc.xml` have broken
citeStructures.** `ven.xml` declares
`<citeStructure unit="line" match=".//l[@n]" use="@n"/>` but none of its
1,196 `<l>` elements carries `@n`, so the citeStructure matches nothing.
`luc.xml` has correct global line numbers on `<lb n="704">`-style
milestones but declares stanza-relative line position instead, leaving
those numbers unaddressable. Both are known and unfixed; see `forum.org`
`#citations/poem-citestructure-gaps`. A declared citeStructure that
matches zero nodes is a defect class worth checking for generally.

**Non-dramatic works (`son`, `ven`, `lc`, `pht`, `pp`, `luc`) are in
scope.** They have different structural conventions from the plays and
need separate handling, but they are part of this sprint. (An earlier
version of this file said they were out of scope. That was wrong.)

**`__cts__.xml` files** are CTS catalog metadata, not TEI documents. Do
not validate them against TEI schemas, do not apply TEI transformations
to them, and do not modify them during encoding cleanup passes. They
are edited separately as part of CTS namespace work.

## Schmidt's Shakespeare-Lexicon

Schmidt is being handled differently from the rest of the corpus, and
the difference matters before touching any Schmidt file.

The Lexicon is **a database, not a text**: ~20,000 records that happen
to have been typeset. It is not being edited in place. It is being
re-derived from the P4 source through reviewable intermediate tables in
the `schmidt-lexicon-workshop` repository, which generates the TEI that
lands here.

Consequences:

- `data/schmidt/lexicon/schmidt.lexicon.perseus-eng1.xml` is being
  **superseded, not repaired**. Do not write new transforms against it.
  It remains the source of the already-resolved citations until those
  are extracted.
- Generated Schmidt TEI carries an `<encodingDesc>/<appInfo>` stamp
  naming the tool, its version, the workshop commit, and the sha256 of
  the P4 source. Generated files are marked `DO NOT EDIT` and that mark
  is enforced by a `make verify` target in the workshop. **A hand-edit
  here is a bug**: the fix belongs upstream in a workshop table.
- `<bibl @n>` in the P4 Schmidt source is unreliable (confirmed:
  `n="shak. mv 5.1.137"` on display text reading `Shr. Ind. 1, 137`).
  The display text is authoritative.
- `data/schmidt/lexicon/abate.xml` is a hand-encoded target exemplar,
  not production data.

Full strategy and evidence:
`doc/schmidt-record-extraction-strategy.org`.
