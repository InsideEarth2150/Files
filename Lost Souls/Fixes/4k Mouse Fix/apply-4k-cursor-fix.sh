#!/usr/bin/env bash
# apply-4k-cursor-fix.sh
# 4K cursor fix for Reality Pump Earth-engine games:
#   Earth 2150: The Moon Project (TheMoonProject.exe 2.2.2.3 / 2.2.2.5)
#   World War III: Black Gold    (WW3.exe 1.2.0.0)
#   WWII: Panzer Claws II        (PanzerClawsII.ex1 / PanzerClawsII.ex2 1.3.0.0)
#
# Root cause: the Direct3D renderer drops any triangle with a vertex Y > 2000.0. The cursor is
# drawn as two triangles, so at 3840x2160 it vanishes near the bottom of the screen.
# Fix: repoint the Direct3D renderer's Y-bound checks (fcomp dword ptr [2000.0]) to an existing
# 4096.0 constant in the same exe. The 2000.0 constant itself is untouched (other code uses it).
#
# Place this script in the game folder. It patches every supported exe it finds next to itself,
# identified by SHA256; unknown versions are refused untouched.
#
# Usage:  ./apply-4k-cursor-fix.sh
#         ./apply-4k-cursor-fix.sh --restore
# Pure bash + coreutils (dd, od, sha256sum or shasum). No Python.

set -uo pipefail

# file|version|original sha256|patched sha256|old operand|new operand|file offsets of operands
BUILDS=(
  "TheMoonProject.exe|2.2.2.3|2a130d074536b224f2952ab66e615f25db1a8797522e05e2a7fc92c780f99e25|59391bf1c0dd63beab83078eb62d4ea7d5ee3ea1d0aadca0eacb042642064dfd|84827500|2c807500|0x1C3D33 0x1C3DAF 0x1C3E2B 0x1C40C3 0x1C413F 0x1C41BB 0x1C4462 0x1C44DE 0x1C455A 0x1C485E 0x1C48D7 0x1C4950 0x1C4C02 0x1C4C7E 0x1C4CFA 0x1C4F92 0x1C500E 0x1C508A 0x1C535D 0x1C53D6 0x1C544F"
  "TheMoonProject.exe|2.2.2.5|dc6049fd5bfda5ea5706929fabb06db0024ea1e268dc1ecc031fcfe4aaf1c10f|e0b4bb032cb58dc0d6d86a6c772111cfffc1752aa2db26b5e6e77d432760c5a8|84827500|2c807500|0x1C3D33 0x1C3DAF 0x1C3E2B 0x1C40C3 0x1C413F 0x1C41BB 0x1C4462 0x1C44DE 0x1C455A 0x1C485E 0x1C48D7 0x1C4950 0x1C4C02 0x1C4C7E 0x1C4CFA 0x1C4F92 0x1C500E 0x1C508A 0x1C535D 0x1C53D6 0x1C544F"
  "WW3.exe|1.2.0.0|530fbf4709b47cbe0eeb7d4f3f778e74c2317d9dc82a5a6fb21d31ab8199fd3b|d7e5586f8febc6d6a468c30d9d7d7a9a06f3e6edb96cb968235d22167dec9a2e|a8a38200|2c9d8200|0x317C23 0x317C9F 0x317D1B 0x317FB3 0x31802F 0x3180AB 0x318352 0x3183CE 0x31844A 0x31873E 0x3187B7 0x318830 0x318AD2 0x318B4E 0x318BCA 0x318E62 0x318EDE 0x318F5A 0x31922D 0x3192A6 0x31931F 0x3195C2 0x31963E 0x3196BA"
  "PanzerClawsII.ex1|1.3.0.0|73f9795512dec21495ae85932256b7893865080729a1d4498603292cd7acdde3|0ffc7ae90357fef7155f890d55386450ccdd5e048acb51f13b2ec39b1f59de5b|c0017f00|b8c17e00|0x2C12D3 0x2C134F 0x2C13CB 0x2C1653 0x2C16CF 0x2C174B 0x2C19E2 0x2C1A5E 0x2C1ADA 0x2C1DCE 0x2C1E47 0x2C1EC0 0x2C2152 0x2C21CE 0x2C224A 0x2C24D2 0x2C254E 0x2C25CA 0x2C2F62 0x2C2FDD 0x2C3058 0x2C35D9 0x2C3654 0x2C36CF 0x2C374A 0x2C43ED 0x2C4466 0x2C44DF 0x2C4782 0x2C47FE 0x2C487A"
  "PanzerClawsII.ex2|1.3.0.0|cdc00616f510c29ef1c55eecc0118d3ae2721b87f1c294edc9c935641a25aac2|675578d20aa912bea63fc975600d7535c6df1b0081aaf15cded89b1d137e48c7|d0818200|d8418200|0x2BF673 0x2BF6EF 0x2BF76B 0x2BFAD8 0x2BFB54 0x2BFBD0 0x2BFF62 0x2BFFDE 0x2C005A 0x2C043E 0x2C04B7 0x2C0530 0x2C08B7 0x2C0933 0x2C09AF 0x2C0D2A 0x2C0DA6 0x2C0E22 0x2C1932 0x2C19AD 0x2C1A28 0x2C1F39 0x2C1FB4 0x2C202F 0x2C20AA 0x2C2E6D 0x2C2EE6 0x2C2F5F 0x2C32F2 0x2C336E 0x2C33EA"
)
OPCODE="d81d"   # fcomp dword ptr [imm32]

if [[ -t 1 ]]; then
  RED=$'\e[31m'; GRN=$'\e[32m'; YLW=$'\e[33m'; RST=$'\e[0m'
else
  RED=""; GRN=""; YLW=""; RST=""
fi
ok()   { printf '%s[ OK ]%s %s\n' "$GRN" "$RST" "$*"; }
warn() { printf '%s[WARN]%s %s\n' "$YLW" "$RST" "$*"; }
err()  { printf '%s[FAIL]%s %s\n' "$RED" "$RST" "$*" >&2; }
die()  { err "$*"; exit 1; }

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}'
  else die "Need sha256sum or shasum"; fi
}
read_hex() { dd if="$1" bs=1 skip="$(( $2 ))" count="$3" status=none | od -An -tx1 -v | tr -d ' \n'; }
write_hex() {
  local file=$1 off=$2 hex=$3 esc="" i
  for (( i=0; i<${#hex}; i+=2 )); do esc+="\\x${hex:i:2}"; done
  printf "$esc" | dd of="$file" bs=1 seek="$(( off ))" conv=notrunc status=none
}

# Sets REC_* from the build record matching file name + hash in the given field (3=orig, 4=patched)
find_build() {
  local name=$1 hash=$2 field=$3 rec f
  for rec in "${BUILDS[@]}"; do
    IFS='|' read -r REC_FILE REC_VER REC_ORIG REC_PATCHED REC_OLD REC_NEW REC_OFFS <<< "$rec"
    [[ "$REC_FILE" == "$name" ]] || continue
    if [[ $field == 3 ]]; then f=$REC_ORIG; else f=$REC_PATCHED; fi
    [[ "$f" == "$hash" ]] && return 0
  done
  return 1
}

restore_file() {
  local exe=$1 name bak
  name=$(basename -- "$exe"); bak="${exe}.orig-4kcursor.bak"
  [[ -f "$bak" ]] || { warn "$name: no backup found, skipped"; return 0; }
  find_build "$name" "$(sha256 "$bak")" 3 || { err "$name: backup does not match a known original; not restoring"; return 1; }
  cp -p -- "$bak" "$exe" || { err "$name: copy failed"; return 1; }
  ok "$name: restored original $REC_VER"
}

patch_file() {
  local exe=$1 name bak cur off op opnd new
  name=$(basename -- "$exe"); bak="${exe}.orig-4kcursor.bak"
  cur=$(sha256 "$exe")
  if find_build "$name" "$cur" 4; then ok "$name: already patched ($REC_VER)"; return 0; fi
  find_build "$name" "$cur" 3 || { err "$name: unknown version (SHA256 $cur); nothing changed"; return 1; }
  ok "$name: version $REC_VER verified (SHA256 match)"
  local -a offs=( $REC_OFFS )
  for off in "${offs[@]}"; do
    op=$(read_hex "$exe" $(( off - 2 )) 2); opnd=$(read_hex "$exe" "$off" 4)
    [[ "$op" == "$OPCODE" && "$opnd" == "$REC_OLD" ]] \
      || { err "$name: unexpected bytes at $off; nothing changed"; return 1; }
  done
  if [[ -e "$bak" ]]; then
    [[ "$(sha256 "$bak")" == "$REC_ORIG" ]] \
      || { err "$name: existing backup is a different file ($bak) - move it away and re-run; nothing changed"; return 1; }
    warn "$name: backup already exists, leaving it as is"
  else
    cp -p -- "$exe" "$bak" || { err "$name: could not write backup; nothing changed"; return 1; }
    ok "$name: backup written to $(basename -- "$bak")"
  fi
  for off in "${offs[@]}"; do
    write_hex "$exe" "$off" "$REC_NEW" || { cp -p -- "$bak" "$exe"; err "$name: write failed (is the game running?); original restored"; return 1; }
  done
  new=$(sha256 "$exe")
  if [[ "$new" != "$REC_PATCHED" ]]; then
    cp -p -- "$bak" "$exe"; err "$name: patched hash mismatch; original restored"; return 1
  fi
  ok "$name: patched ${#offs[@]} sites"
}

MODE="apply"
case "${1:-}" in
  "")        ;;
  --restore) MODE="restore" ;;
  *)         die "Unknown argument: $1 (only --restore is supported)" ;;
esac

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Unique supported file names
NAMES=()
for rec in "${BUILDS[@]}"; do
  n=${rec%%|*}; seen=0
  for x in ${NAMES[@]+"${NAMES[@]}"}; do [[ "$x" == "$n" ]] && seen=1; done
  [[ $seen == 0 ]] && NAMES+=( "$n" )
done

found=0; failed=0
for n in "${NAMES[@]}"; do
  exe="$SCRIPT_DIR/$n"
  [[ -f "$exe" ]] || continue
  found=$(( found + 1 ))
  if [[ "$MODE" == "restore" ]]; then restore_file "$exe" || failed=$(( failed + 1 ))
  else patch_file "$exe" || failed=$(( failed + 1 )); fi
done

[[ $found -gt 0 ]] || die "No supported exe found next to this script in $SCRIPT_DIR (looked for: ${NAMES[*]})"
[[ $failed -eq 0 ]] || die "$failed file(s) failed - see messages above"
ok "Done ($found file(s)). Undo with: $0 --restore"
