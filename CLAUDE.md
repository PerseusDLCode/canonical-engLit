This is a text-encoding project to refurbish the TEI encoding of the
works comprising Perseus's Early Modern English (Renaissance)
collection.

The primary goal is to include Perseus's Early Modern English
collection in the new Minimum Viable Perseus (MVP), starting with the
works of Shakespeare.

## Repository structure

- `data/` — refurbished TEI P5 encodings. This is the working
  directory. All editing and transformation should target files here.
- `Renaissance/` — original encodings. Read-only reference; do not modify.
- `schemas/` — outdated TEI customizations from a prior refurbishment.
  Do not use. The current schemas are in the sibling repository
  `perseus-schemas` (`https://github.com/PerseusDLCode/perseus-schemas`).
- `src/` — scripts from the prior refurbishment; some may still be useful.
- `doc/` — project documentation, including `forum.org` (design
  deliberation) and `agenda.org` (task tracking).

## Current branch

`mvp` — branched from `p6`. All work for the Minimum Viable Perseus
sprint goes here.

## Tools

**XSLT:** Use Saxon for all XSLT processing. Stylesheets in this
project use XSLT 3.0 features and will not run correctly under
xsltproc (XSLT 1.0) or other processors.

```sh
saxon -s:input.xml -xsl:transform.xsl -o:output.xml
```

**Validation:** Validate against the appropriate schema from
`perseus-schemas`:
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
Textgroup and work identifiers are TBD pending agreement with Alison
Babeu (Perseus librarian); do not invent new URN components without
checking `doc/forum.org`.

## Gotchas

**Do not parse with DTD validation or DTD loading enabled.** lxml
(and libxml2 generally) materializes default attribute values from
the DTD during parsing and writes them to output, polluting the
serialized files. This is the source of the `@part="N"` proliferation
in the current files. Always parse without DTD loading.

**`data/shakespeare/tro.xml` and `data/shakespeare/per.xml`** are
under-encoded: Troilus and Cressida has no `<lb>` markup at all;
Pericles has only 4. Do not treat these as representative of the
corpus; do not use them as test cases.

**Non-dramatic works** (`son`, `ven`, `lc`, `pht`, `pp`, `luc`) have
different structural conventions from the plays and are out of scope
for the current MVP sprint. Leave them for later.

**`__cts__.xml` files** are CTS catalog metadata, not TEI documents.
Do not validate them against TEI schemas, do not apply TEI
transformations to them, and do not modify them during encoding
cleanup passes. They are edited separately as part of CTS namespace
work.
