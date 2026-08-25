#!/usr/bin/env python3
"""Unwrap <bibl><ref target="...">...</ref></bibl> to bare <ref target>.

Only the enclosing <bibl> that wraps a resolved CTS <ref target> is
removed, via a literal text substitution rather than a full XML
reserialization -- data/schmidt/lexicon/lexicon.xml is hand-formatted
and a parse/reserialize pass (Saxon or lxml) collapses tag-internal
line breaks across the whole file, producing a diff far larger than
the actual edit. <bibl @n="..."> (flagged/unresolved citations) and
plain-text <bibl>Appendix ...</bibl> cross-references are untouched --
neither matches the substrings below.
"""

import argparse
import sys

OPEN_OLD = "<bibl><ref target="
OPEN_NEW = "<ref target="
CLOSE_OLD = "</ref></bibl>"
CLOSE_NEW = "</ref>"


def run(path, output_path):
    with open(path, encoding="utf-8") as f:
        text = f.read()

    opens = text.count(OPEN_OLD)
    closes = text.count(CLOSE_OLD)
    if opens != closes:
        print(f"ERROR: {opens} '{OPEN_OLD}' vs {closes} '{CLOSE_OLD}' -- not 1:1, aborting", file=sys.stderr)
        return 1

    text = text.replace(OPEN_OLD, OPEN_NEW).replace(CLOSE_OLD, CLOSE_NEW)

    out = output_path or path
    with open(out, "w", encoding="utf-8") as f:
        f.write(text)

    print(f"Wrote {out} ({opens} <bibl> wrappers removed)")
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("xml_file")
    ap.add_argument("-o", "--output")
    args = ap.parse_args()
    sys.exit(run(args.xml_file, args.output))


if __name__ == "__main__":
    main()
