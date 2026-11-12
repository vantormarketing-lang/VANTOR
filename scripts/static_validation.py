#!/usr/bin/env python3
"""Lightweight static checks for the DOMA/VANTOR standalone HTML pages."""
from __future__ import annotations

import subprocess
import sys
import re
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



def top_level_function_names(source: str) -> list[str]:
    """Return classic-script function declarations at brace depth zero."""
    names: list[str] = []
    i = 0
    brace_depth = 0
    state = "code"
    quote = ""
    previous = ""

    while i < len(source):
        char = source[i]
        nxt = source[i + 1] if i + 1 < len(source) else ""

        if state == "line_comment":
            if char == "\n":
                state = "code"
            i += 1
            continue
        if state == "block_comment":
            if char == "*" and nxt == "/":
                state = "code"
                i += 2
            else:
                i += 1
            continue
        if state == "quoted":
            if char == "\\":
                i += 2
                continue
            if char == quote:
                state = "code"
            i += 1
            continue
        if state == "template":
            if char == "\\":
                i += 2
                continue
            if ord(char) == 96:
                state = "code"
            i += 1
            continue

        if char == "/" and nxt == "/":
            state = "line_comment"
            i += 2
            continue
        if char == "/" and nxt == "*":
            state = "block_comment"
            i += 2
            continue
        if char in ("'", '"'):
            state = "quoted"
            quote = char
            i += 1
            continue
        if ord(char) == 96:
            state = "template"
            i += 1
            continue

        # Skip regular-expression literals so quantifier braces do not alter scope depth.
        regex_can_start = previous in "=(,:;!&|?{}[]\\n+-*%^~<>"
        if not regex_can_start:
            j = i - 1
            while j >= 0 and source[j].isspace():
                j -= 1
            token_end = j + 1
            while j >= 0 and (source[j].isalnum() or source[j] in "_$"):
                j -= 1
            previous_word = source[j + 1:token_end]
            regex_can_start = previous_word in {
                "return", "throw", "case", "delete", "void", "typeof",
                "instanceof", "in", "of", "yield", "await", "else", "do"
            }
        if char == "/" and regex_can_start:
            j = i + 1
            in_character_class = False
            while j < len(source):
                if source[j] == "\\":
                    j += 2
                    continue
                if source[j] == "[":
                    in_character_class = True
                elif source[j] == "]":
                    in_character_class = False
                elif source[j] == "/" and not in_character_class:
                    j += 1
                    while j < len(source) and source[j].isalpha():
                        j += 1
                    break
                elif source[j] == "\n":
                    break
                j += 1
            if j > i + 1 and source[j - 1] != "\n":
                i = j
                previous = "x"
                continue

        if brace_depth == 0:
            match = re.match(r"(?:async\s+)?function\s+([A-Za-z_$][\w$]*)\s*\(", source[i:])
            if match:
                names.append(match.group(1))
                i += len(match.group(0))
                previous = "("
                continue

        if char == "{":
            brace_depth += 1
        elif char == "}":
            brace_depth = max(0, brace_depth - 1)
        if not char.isspace():
            previous = char
        i += 1

    return names


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
    global_function_names: list[str] = []

    for number, (attrs, body) in enumerate(parser.scripts, start=1):
        if attrs.get("src") or not body.strip():
            continue
        script_type = (attrs.get("type") or "").split(";", 1)[0].strip().lower()
        if script_type in SKIP_SCRIPT_TYPES:
            continue
        if script_type != "module":
            global_function_names.extend(top_level_function_names(body))
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

    if page.name in ("admin.html", "index.html"):
        seen: set[str] = set()
        duplicates: set[str] = set()
        for name in global_function_names:
            if name in seen:
                duplicates.add(name)
            seen.add(name)
        if duplicates:
            names = ", ".join(sorted(duplicates))
            print(f"FAIL: {page.name} has duplicate top-level function declarations: {names}")
            return False

    if page.name == "admin.html":
        for marker in ('id="section-dashboard"', 'id="studentsTable"', 'id="salesTable"'):
            if marker not in source:
                print(f"FAIL: admin.html is missing expected element {marker}")
                return False

    print(f"PASS: {page.name} ({checked} inline JavaScript blocks syntax-checked)")
    return True


def validate_external_script(script: Path) -> bool:
    if not script.is_file() or script.stat().st_size == 0:
        print(f"FAIL: {script.name} is missing or empty")
        return False
    result = subprocess.run(
        ["node", "--check", str(script)],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode:
        print(f"FAIL: {script.name} has a JavaScript syntax error")
        print(result.stderr.strip())
        return False
    print(f"PASS: {script.name} syntax-checked")
    return True


def main() -> int:
    failures = [page.name for page in PAGES if not validate_page(ROOT / page)]
    for script_name in ("doma-mrfluent-kids-runtime.js", "mf-kids-learning-experiences.js"):
        if not validate_external_script(ROOT / script_name):
            failures.append(script_name)
    if failures:
        print("Static validation failed: " + ", ".join(failures))
        return 1
    print("Static validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
