import sys
import os
import xml.etree.ElementTree as ET
import polib


def normalize(s: str | None) -> str:
	return " ".join((s or "").strip().lower().split())


# -----------------------------
# PO CHECK
# -----------------------------


def checkPo(path: str) -> float:
	po = polib.pofile(path)
	translated = 0
	total = 0

	for entry in po:
		if not entry.msgid.strip():
			continue

		total += 1

		if entry.msgstr and normalize(entry.msgstr) != normalize(entry.msgid):
			translated += 1

	return translated / total if total else 0.0


# -----------------------------
# XLIFF CHECK
# -----------------------------


def checkXliff(path: str) -> float:
	tree = ET.parse(path)
	root = tree.getroot()
	translated = 0
	total = 0
	source = None

	for elem in root.iter():
		if elem.tag.endswith("source"):
			source = normalize(elem.text)

		elif elem.tag.endswith("target"):
			target = normalize(elem.text)

			if source:
				total += 1
				if target and target != source:
					translated += 1

	return translated / total if total else 0.0


def main():
	if len(sys.argv) < 2:
		print("Usage:")
		print("  checkTranslation.py <file>")
		sys.exit(2)

	args = sys.argv[1:]

	path = args[0]

	if not os.path.exists(path):
		print(f"File not found: {path}")
		sys.exit(2)

	ext = os.path.splitext(path)[1].lower()

	# -------------------------
	# PO
	# -------------------------
	if ext == ".po":
		ratio = checkPo(path)
		print(f"translation_ratio={ratio}")
		sys.exit(0 if ratio > 0.05 else 1)

	# -------------------------
	# XLIFF
	# -------------------------
	elif ext in [".xliff", ".xlf"]:
		ratio = checkXliff(path)
		print(f"translation_ratio={ratio}")
		sys.exit(0 if ratio > 0.05 else 1)

	else:
		print(f"Unsupported file type: {ext}")
		sys.exit(2)


if __name__ == "__main__":
	main()
