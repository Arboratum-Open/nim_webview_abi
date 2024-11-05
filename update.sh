#!/usr/bin/env bash
set -eu -o pipefail
cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")"

#git diff --exit-code -- . ':(exclude)update.sh' > /dev/null || { echo "Commit changes before updating!" ; exit 1 ; }

(( ${HAS_NIMTEROP:-0} )) || nimble install -y nimterop@0.6.13

# https://www.sqlite.org/download.html
MAJOR="${1:-0}"
MINOR="${2:-12}"
PATCH="${3:-0}"

VER_INT="$(printf "%d.%d.%d" "$MAJOR" "$MINOR" "$PATCH")"

cd nim_webview_abi

ZIP="$VER_INT.zip"
[ -f "$ZIP" ] || wget https://github.com/webview/webview/archive/refs/tags/$ZIP

unzip -o $ZIP
rm -fr webview
mv webview-$VER_INT webview

nim c -r --skipParentCfg --verbosity:3 --hints:off wrap.nim

cd ..

sed -i.bak \
  -e "s|cdecl|wvdecl|g" \
  -e "\|Generated @|d" \
  -e "s|$PWD/||g" \
  -e "s|$HOME|~|g" \
  -e "s|--nim:[^ ]*|--nim:nim|g" \
  -e 's|{.experimental: "codeReordering".}|{.experimental: "codeReordering".}\nwhen (NimMajor, NimMinor) < (1, 4):\n  {.pragma: wvdecl, cdecl, gcsafe, raises: [Defect].}\nelse:\n  {.pragma: wvdecl, cdecl, gcsafe, raises: [].}|' \
  nim_webview_abi/webview_gen.nim
#rm -f nim_webview_abi/webview_gen.nim.bak  # Portable GNU/macOS `sed` needs backup

# sed -i.bak \
#   -e "s|version.*|version       = \"${MAJOR}.${MINOR}.${PATCH}.0\"|g" \
#   sqlite3_abi.nimble
# rm -f sqlite3_abi.nimble.bak  # Portable GNU/macOS `sed` needs backup

# ! git diff --exit-code > /dev/null || { echo "This repository is already up to date" ; exit 0 ; }

# git commit -a \
#   -m "bump sqlite-amalgamation to \`${MAJOR}.${MINOR}.${PATCH}\`" \
#   -m "- https://www.sqlite.org/releaselog/${MAJOR}_${MINOR}_${PATCH}.html"

# echo "The repo has been updated with a commit recording the update."
# echo "You can review the changes with 'git diff HEAD^' before pushing to a public repository."
