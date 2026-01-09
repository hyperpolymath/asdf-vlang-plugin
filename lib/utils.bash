#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
set -euo pipefail

TOOL_NAME="v"
TOOL_REPO="vlang/v"
BINARY_NAME="v"

fail() {
  echo -e "\e[31mFail:\e[m $*" >&2
  exit 1
}

get_platform() {
  local os
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  echo "$os"
}

get_platform_alt() {
  local os
  os="$(uname -s)"
  case "$os" in
    Darwin) echo "apple-darwin" ;;
    Linux) echo "unknown-linux-gnu" ;;
    *) echo "$os" ;;
  esac
}

get_arch() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    i386|i686) echo "386" ;;
    *) echo "$arch" ;;
  esac
}

get_arch_alt() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) echo "x86_64" ;;
    aarch64|arm64) echo "aarch64" ;;
    *) echo "$arch" ;;
  esac
}

list_all_versions() {
  local versions
  versions="$(curl -sL "https://api.github.com/repos/$TOOL_REPO/releases" 2>/dev/null)"

  if command -v jq >/dev/null 2>&1; then
    echo "$versions" | jq -r '.[].tag_name // empty' 2>/dev/null | sed 's/^v//' | sort_versions
  else
    # Fallback without jq
    echo "$versions" | \
      command grep -o '"tag_name": "[^"]*"' | \
      sed 's/"tag_name": "//' | \
      sed 's/"$//' | \
      sed 's/^v//' | \
      sort_versions
  fi
}

sort_versions() {
  # Use sort -V if available, otherwise fall back to sort -t. -k1,1n -k2,2n -k3,3n
  if sort -V </dev/null 2>/dev/null; then
    sort -V
  else
    # macOS fallback: simple numeric sort (handles most semantic versions)
    sort -t. -k1,1n -k2,2n -k3,3n
  fi
}

get_download_url() {
  local version="$1"
  local os
  os="$(get_platform)"
  local Os
  Os="$(uname -s)"
  local os_alt
  os_alt="$(get_platform_alt)"
  local arch
  arch="$(get_arch)"
  local arch_alt
  arch_alt="$(get_arch_alt)"

  local pattern="v_{os}.zip"
  local asset_name
  asset_name="$(echo "$pattern" | sed "s/{version}/$version/g" | sed "s/{os}/$os/g" | sed "s/{Os}/$Os/g" | sed "s/{os_alt}/$os_alt/g" | sed "s/{arch}/$arch/g" | sed "s/{arch_alt}/$arch_alt/g")"

  # Try with v prefix first
  local url="https://github.com/$TOOL_REPO/releases/download/v$version/$asset_name"
  if curl -sfLI "$url" >/dev/null 2>&1; then
    echo "$url"
    return
  fi

  # Try without v prefix
  url="https://github.com/$TOOL_REPO/releases/download/$version/$asset_name"
  echo "$url"
}

download_release() {
  local version="$1"
  local download_path="$2"
  local url
  url="$(get_download_url "$version")"

  echo "Downloading $TOOL_NAME $version from $url"
local archive="$download_path/archive.zip"
curl -fsSL "$url" -o "$archive" || fail "Download failed"
unzip -q "$archive" -d "$download_path" || fail "Extract failed"
rm -f "$archive"
# Find binary
if [[ ! -f "$download_path/$BINARY_NAME" ]]; then
  local found
  found="$(find "$download_path" -name "$BINARY_NAME" -type f 2>/dev/null | head -1)"
  if [[ -n "$found" ]]; then
    mv "$found" "$download_path/$BINARY_NAME"
  fi
fi
chmod +x "$download_path/$BINARY_NAME" 2>/dev/null || true
}

install_version() {
  local version="$1"
  local install_path="$2"

  mkdir -p "$install_path/bin"
  if [[ -f "$ASDF_DOWNLOAD_PATH/$BINARY_NAME" ]]; then
    cp "$ASDF_DOWNLOAD_PATH/$BINARY_NAME" "$install_path/bin/"
    chmod +x "$install_path/bin/$BINARY_NAME"
  else
    fail "Binary $BINARY_NAME not found in download"
  fi
}
