# -*- coding: utf-8 -*-
"""Convert each PDF in this folder into a folder of Markdown files.

For every PDF a folder named after the PDF (without extension) is created.
The PDF is split into Markdown files using its level-1 bookmarks (TOC).
Each section/chapter becomes one .md file; a README.md index is also written.
If a PDF has no usable TOC, it is split into fixed page-range chunks.
"""
import os
import re
import glob
import fitz  # PyMuPDF

HERE = os.path.dirname(os.path.abspath(__file__))
CHUNK_PAGES = 25  # used only when a PDF has no TOC


def clean_text(s: str) -> str:
    # remove zero-width spaces and other invisible junk
    s = s.replace("​", "").replace("﻿", "")
    # the eMMC datasheet encodes 'eMMC' with a stray char; normalise common case
    s = s.replace("e�MMC", "eMMC").replace("�", "-")
    return s


def sanitize_filename(s: str) -> str:
    s = clean_text(s).strip()
    s = re.sub(r'[\\/:*?"<>|]', " ", s)      # Windows-illegal chars
    s = re.sub(r"\s+", "_", s)               # spaces -> underscore
    s = re.sub(r"_+", "_", s).strip("_.")
    return s[:80] if s else "section"


def page_text_to_md(doc, start, end):
    """Extract text for pages [start, end] (1-based, inclusive) as markdown."""
    parts = []
    for pno in range(start - 1, end):
        page = doc.load_page(pno)
        txt = clean_text(page.get_text("text")).rstrip()
        parts.append(f"\n<!-- page {pno + 1} -->\n\n{txt}\n")
    return "".join(parts)


def build_ranges_from_toc(doc):
    """Return list of (title, start_page, end_page) from level-1 TOC entries."""
    toc = doc.get_toc()
    lvl1 = [(t[1], t[2]) for t in toc if t[0] == 1 and t[2] > 0]
    if not lvl1:
        return None
    # de-duplicate / sort by start page
    lvl1 = sorted(lvl1, key=lambda x: x[1])
    ranges = []
    # front matter before first entry
    first_start = lvl1[0][1]
    if first_start > 1:
        ranges.append(("Front Matter", 1, first_start - 1))
    for i, (title, start) in enumerate(lvl1):
        end = (lvl1[i + 1][1] - 1) if i + 1 < len(lvl1) else doc.page_count
        if end < start:
            end = start
        ranges.append((title, start, end))
    return ranges


def build_ranges_by_chunks(doc):
    ranges = []
    total = doc.page_count
    i = 1
    while i <= total:
        end = min(i + CHUNK_PAGES - 1, total)
        ranges.append((f"Pages {i}-{end}", i, end))
        i = end + 1
    return ranges


def convert(pdf_path):
    name = os.path.splitext(os.path.basename(pdf_path))[0]
    out_dir = os.path.join(HERE, name)
    os.makedirs(out_dir, exist_ok=True)
    doc = fitz.open(pdf_path)

    ranges = build_ranges_from_toc(doc)
    used_toc = ranges is not None
    if not used_toc:
        ranges = build_ranges_by_chunks(doc)

    index_lines = [
        f"# {clean_text(name)}",
        "",
        f"Tài liệu Markdown được chuyển đổi từ `{os.path.basename(pdf_path)}` "
        f"({doc.page_count} trang).",
        "",
        f"Phương pháp chia file: {'theo mục lục (TOC)' if used_toc else 'theo khoảng trang'}.",
        "",
        "## Danh sách file",
        "",
    ]

    made = []
    for idx, (title, start, end) in enumerate(ranges, 1):
        fname = f"{idx:02d}_{sanitize_filename(title)}.md"
        body = page_text_to_md(doc, start, end)
        content = (
            f"# {clean_text(title)}\n\n"
            f"> Nguồn: `{os.path.basename(pdf_path)}` — trang {start}–{end}\n"
            f"{body}\n"
        )
        with open(os.path.join(out_dir, fname), "w", encoding="utf-8") as fh:
            fh.write(content)
        index_lines.append(f"- [{clean_text(title)}](./{fname}) — trang {start}–{end}")
        made.append(fname)

    with open(os.path.join(out_dir, "README.md"), "w", encoding="utf-8") as fh:
        fh.write("\n".join(index_lines) + "\n")

    doc.close()
    print(f"[OK] {os.path.basename(pdf_path)} -> {out_dir} ({len(made)} md files)")
    return out_dir, made


def main():
    pdfs = sorted(glob.glob(os.path.join(HERE, "*.pdf")))
    print(f"Found {len(pdfs)} PDF(s)")
    for p in pdfs:
        convert(p)


if __name__ == "__main__":
    main()
