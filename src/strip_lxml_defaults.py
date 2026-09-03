#!/usr/bin/env python3
"""Remove @default="false" and @status="draft" schema-default artifacts.

Both are RelaxNG-declared defaults (a:defaultValue="false" and "draft"
in perseus_drama.rng/perseus_verse.rng) that a parser materialized into
the serialized output -- the same artifact class as @part="N", just
from a schema default rather than a DTD one. A corpus-wide grep
confirmed exactly three fixed occurrences per file (sourceDesc,
biblStruct, langUsage), always in this exact form, with no other
values or elements using either attribute anywhere in the corpus.

A literal text substitution rather than an XSLT/lxml reserialization
pass, deliberately -- reserializing these files collapses their
hand-formatted multi-line citeStructure attribute lists onto one line,
a large, unrelated diff for what should be a three-line change. Same
rationale as strip_bibl_wrapper.py.
"""
import glob
import sys

SUBSTITUTIONS = [
    ('sourceDesc default="false">', "sourceDesc>"),
    ('biblStruct default="false" status="draft">', "biblStruct>"),
    ('langUsage default="false">', "langUsage>"),
]


def main():
    files = sorted(
        glob.glob("data/shakespeare/*/shakespeare.*.globe.xml")
        + glob.glob("data/shakespeare/*/shakespeare.*.f1.xml")
    )
    changed = 0
    mismatches = []
    for path in files:
        with open(path, encoding="utf-8") as f:
            content = f.read()
        original = content
        for old, new in SUBSTITUTIONS:
            n = content.count(old)
            if n != 1:
                mismatches.append((path, old, n))
            content = content.replace(old, new)
        if content != original:
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
            changed += 1

    print(f"files changed: {changed}")
    if mismatches:
        print(f"WARNING: {len(mismatches)} unexpected pattern counts:", file=sys.stderr)
        for path, pattern, n in mismatches:
            print(f"  {path}: {pattern!r} matched {n} times (expected 1)", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
