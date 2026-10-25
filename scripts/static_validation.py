#!/usr/bin/env python3
"""Lightweight static checks for the DOMA/VANTOR standalone HTML pages."""
from __future__ import annotations

import subprocess
import sys
import tempfile
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAGES = ("index.html", "admin.html")
SKIP_SCRIPT_TYPES = {
    "application/json",
    "application/ld+json",
    "importmap",
    "speculationrules",
}


class InlineScriptParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=False)
        self.scripts: list[tuple[dict[str, str | None], str]] = []
        self.current: tuple[dict[str, str | None], list[str]] | None = None

    def handle_starttag(self, tag: str, attrs) -> None:
        if tag.lower() == "script":
            # HTML does not permit nested script elements; preserve the first if malformed.
            if self.current is None:
                self.current = (dict(attrs), [])

    def handle_data(self, data: str) -> None:
        if self.current is not None:
            self.current[1].append(data)

    def handle_endtag(self, tag: str) -> None:
        if tag.lower() == "script" and self.current is not None:
            attrs, chunks = self.current
            self.scripts.append((attrs, "".join(chunks)))
            self.current = None


def validate_page(page: Path) -> bool:
    if not page.is_file() or page.stat().st_size == 0:
        print(f"FAIL: {page.name} is missing or empty")
        return False

    source = page.read_text(encoding="utf-8")
    lowered = source.lower()
    if "<html" not in lowered or "</html>" not in lowered:
        print(f"FAIL: {page.name} does not contain a complete HTML document")
        return False

    parser = InlineScriptParser()
    parser.feed(source)
    parser.close()
    checked = 0

    for number, (attrs, body) in enumerate(parser.scripts, start=1):
        if attrs.get("src") or not body.strip():
            continue
        script_type = (attrs.get("type") or "").split(";", 1)[0].strip().lower()
        if script_type in SKIP_SCRIPT_TYPES:
            continue
        suffix = ".mjs" if script_type == "module" else ".js"
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", suffix=suffix, delete=False
        ) as handle:
            handle.write(body)
            temp_path = Path(handle.name)
        try:
            result = subprocess.run(
                ["node", "--check", str(temp_path)],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=False,
            )
            if result.returncode:
                print(f"FAIL: {page.name} inline script #{number} has a syntax error")
                print(result.stderr.strip())
                return False
        finally:
            temp_path.unlink(missing_ok=True)
        checked += 1

    if checked == 0:
        print(f"FAIL: no inline JavaScript was checked in {page.name}")
        return False

    if page.name == "admin.html":
        for marker in ('id="section-dashboard"', 'id="studentsTable"', 'id="salesTable"'):
            if marker not in source:
                print(f"FAIL: admin.html is missing expected element {marker}")
                return False

    print(f"PASS: {page.name} ({checked} inline JavaScript blocks syntax-checked)")
    return True


def main() -> int:
    failures = [page.name for page in PAGES if not validate_page(ROOT / page)]
    if failures:
        print("Static validation failed: " + ", ".join(failures))
        return 1
    print("Static validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
