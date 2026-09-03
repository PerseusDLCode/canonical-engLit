#!/usr/bin/env python3
"""Resolve Shakespeare <bibl @n> citations in Schmidt's Lexicon to CTS <ref @target> URNs.

See src/mvp/schmidt_spec.md for the full specification.
"""

import argparse
import re
import sys
from collections import Counter, defaultdict

from lxml import etree

TEI_NS = "http://www.tei-c.org/ns/1.0"
NSMAP = {"tei": TEI_NS}

# Schmidt abbreviation -> CTS playid (lowercase Folger idno / DraCor playid).
# Verified against the imported ShakeDraCor corpus (data/shakespeare/*/*.f1.xml)
# 2026-08-24; see doc/forum.org #citations/schmidt-play-abbr-table.
PLAY_ABBR_TO_ID = {
    "tmp": "tmp", "ham": "ham", "r3": "r3", "mm": "mm", "2h6": "2h6",
    "lll": "lll", "1h6": "1h6", "cym": "cym", "tgv": "tgv", "wiv": "wiv",
    "h5": "h5", "cor": "cor", "1h4": "1h4", "mv": "mv", "wt": "wt",
    "lr": "lr", "tro": "tro", "2h4": "2h4", "ant": "ant", "3h6": "3h6",
    "oth": "oth", "jn": "jn", "luc": "luc", "r2": "r2", "ayl": "ayl",
    "mnd": "mnd", "ado": "ado", "aww": "aww", "h8": "h8", "rom": "rom",
    "err": "err", "ven": "ven", "tn": "tn", "tit": "tit", "mac": "mac",
    "shr": "shr", "son": "son", "tim": "tim", "jc": "jc", "per": "per",
    "lc": "lc", "pp": "pp", "pht": "pht",
    # e3 (Edward III) is not Shakespeare's; flagged and skipped, never resolved.
}

NOT_SHAKESPEARE = {"e3"}

# Roman numerals i-cliv (1-154), for Schmidt's sonnet citations ("cl.11").
_ROMAN_PAIRS = [
    ("c", 100), ("xc", 90), ("l", 50), ("xl", 40),
    ("x", 10), ("ix", 9), ("v", 5), ("iv", 4), ("i", 1),
]


def _roman_to_arabic(s):
    s = s.lower()
    i = 0
    total = 0
    while i < len(s):
        for sym, val in _ROMAN_PAIRS:
            if s.startswith(sym, i):
                total += val
                i += len(sym)
                break
        else:
            return None
    return total


ROMAN_TO_ARABIC = {}
for n in range(1, 155):
    # Build the roman numeral for n by greedy subtraction, then verify round-trip.
    remaining = n
    roman = ""
    for sym, val in _ROMAN_PAIRS:
        while remaining >= val:
            roman += sym
            remaining -= val
    assert _roman_to_arabic(roman) == n
    ROMAN_TO_ARABIC[roman] = n


def resolve_locator(abbr, loc):
    """Return (kind, passage) for a recognized locator, or None if unrecognized."""
    segs = loc.split(".")

    if len(segs) == 3 and all(s.isdigit() for s in segs):
        return ("act.scene.line", ".".join(segs))

    if len(segs) == 3 and segs[2] == "" and segs[0].isdigit() and segs[1].isdigit():
        # "3.0." -- act.scene with a stray trailing separator and no line
        # (Prol./stage-direction material within the scene; not in the original
        # spec's format table, but already folded into "act.scene" counts by
        # the phase1/bibl-survey — see doc/forum.org #citations/schmidt-play-abbr-table).
        return ("act.scene", f"{segs[0]}.{segs[1]}")

    if len(segs) == 2 and all(s.isdigit() for s in segs):
        return ("act.scene", ".".join(segs))

    if len(segs) == 1 and segs[0].isdigit():
        return ("line-only", segs[0])

    if len(segs) == 2 and abbr == "son" and segs[0].isalpha() and segs[1].isdigit():
        arabic = ROMAN_TO_ARABIC.get(segs[0].lower())
        if arabic is not None:
            return ("sonnet", f"{arabic}.{segs[1]}")

    if len(segs) == 2 and segs[0].isdigit() and segs[1].startswith("chorus"):
        return ("chorus", ".".join(segs))

    if len(segs) == 3 and segs[0] == "ind" and segs[1].isdigit() and segs[2].isdigit():
        return ("induction", f"induction.{segs[1]}.{segs[2]}")

    return None


def classify(n):
    """Classify one <bibl @n> value.

    Returns a dict with at least 'status' in {'resolved', 'flagged', 'skip'}.
    'skip' = not a shak. citation (leave untouched, not part of the survey scope).
    """
    if not n.startswith("shak."):
        return {"status": "skip"}

    parts = n.split()
    if len(parts) < 2:
        return {"status": "flagged", "reason": "unrecognized", "n": n}

    abbr = parts[1]

    if abbr in NOT_SHAKESPEARE:
        return {"status": "flagged", "reason": "non-shakespeare", "n": n}

    if abbr not in PLAY_ABBR_TO_ID:
        return {"status": "flagged", "reason": "unknown-abbr", "n": n}

    if len(parts) == 2:
        return {"status": "flagged", "reason": "bare-work", "n": n}

    if len(parts) == 3 and parts[2] == abbr:
        return {"status": "flagged", "reason": "duplicated-token", "n": n}

    if len(parts) != 3:
        return {"status": "flagged", "reason": "unrecognized", "n": n}

    loc = parts[2]
    result = resolve_locator(abbr, loc)
    if result is None:
        return {"status": "flagged", "reason": "unrecognized", "n": n}

    kind, passage = result
    playid = PLAY_ABBR_TO_ID[abbr]
    urn = f"urn:cts:engLit:shakespeare.{playid}.globe:{passage}"
    return {"status": "resolved", "kind": kind, "urn": urn, "n": n}


def apply_resolution(bibl, urn):
    ref = etree.SubElement(bibl, f"{{{TEI_NS}}}ref")
    ref.set("target", urn)
    ref.text = bibl.text
    bibl.text = None
    del bibl.attrib["n"]


def run(path, dry_run, output_path):
    parser = etree.XMLParser(load_dtd=False, no_network=True, resolve_entities=False)
    tree = etree.parse(path, parser)
    root = tree.getroot()
    bibls = root.findall(".//tei:bibl", NSMAP)

    total = len(bibls)
    no_n = 0
    non_shak = 0
    resolved_by_kind = Counter()
    flagged_by_reason = Counter()
    flagged_items = defaultdict(list)
    samples_by_kind = defaultdict(list)
    to_apply = []

    for b in bibls:
        n = b.get("n")
        if n is None:
            no_n += 1
            continue
        result = classify(n)
        if result["status"] == "skip":
            non_shak += 1
            continue
        if result["status"] == "flagged":
            flagged_by_reason[result["reason"]] += 1
            entry = b.xpath("ancestor::tei:entryFree[1]", namespaces=NSMAP)
            orth = entry[0].find("tei:orth", NSMAP) if entry else None
            orth_text = "".join(orth.itertext()).strip() if orth is not None else ""
            alpha = b.xpath("ancestor::tei:div[@subtype='alpha'][1]", namespaces=NSMAP)
            alpha_n = alpha[0].get("n") if alpha else "?"
            flagged_items[result["reason"]].append((alpha_n, orth_text, result["n"]))
            continue
        # resolved
        resolved_by_kind[result["kind"]] += 1
        if len(samples_by_kind[result["kind"]]) < 5:
            samples_by_kind[result["kind"]].append((result["n"], result["urn"]))
        to_apply.append((b, result["urn"]))

    shak_candidates = total - no_n - non_shak
    would_resolve = sum(resolved_by_kind.values())
    would_flag = sum(flagged_by_reason.values())

    print("SCHMIDT <bibl> RESOLVER — DRY RUN" if dry_run else "SCHMIDT <bibl> RESOLVER — OUTPUT PASS")
    print("=" * 40)
    print(f"Total <bibl> elements:             {total}")
    print(f"  shak. @n (candidates):           {shak_candidates}")
    print(f"  Non-shak. @n (leave as-is):      {non_shak}")
    print(f"  No @n (leave as-is):             {no_n}")
    print()
    print(f"  Would resolve:                   {would_resolve}")
    for kind, count in resolved_by_kind.most_common():
        print(f"    {kind}:{' ' * max(1, 22 - len(kind))}{count}")
    print(f"  Would flag — malformed:          {would_flag}")
    for reason, count in flagged_by_reason.most_common():
        print(f"    {reason}:{' ' * max(1, 24 - len(reason))}{count}")
    print()
    print("MALFORMED (all)")
    print("-" * 18)
    for reason, items in flagged_items.items():
        for alpha_n, orth_text, n in items:
            print(f"[{alpha_n}] {orth_text!r} — {n!r}")
    print()
    print(f"SAMPLE RESOLUTIONS (up to 5 per locator type)")
    print("-" * 41)
    for kind, samples in samples_by_kind.items():
        print(f"{kind}:")
        for n, urn in samples:
            print(f"  {n}  ->  {urn}")

    if dry_run:
        return 0

    for bibl, urn in to_apply:
        apply_resolution(bibl, urn)

    out = output_path or path
    tree.write(out, xml_declaration=True, encoding="UTF-8")
    print()
    print(f"Wrote {out} ({len(to_apply)} <bibl> elements resolved)")
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("xml_file")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("-o", "--output")
    args = ap.parse_args()
    sys.exit(run(args.xml_file, args.dry_run, args.output))


if __name__ == "__main__":
    main()
