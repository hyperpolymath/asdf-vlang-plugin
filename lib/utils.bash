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
  local os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  case "$os" in
    darwin) echo "apple-darwin" ;;
    linux) echo "unknown-linux-gnu" ;;
    *) fail "Unsupported OS: $os" ;;
  esac
}

get_arch() {
  local arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) echo "x86_64" ;;
    aarch64|arm64) echo "aarch64" ;;
    *) fail "Unsupported architecture: $arch" ;;
  esac
}

list_all_versions() {
  curl -sL "https://api.github.com/repos/$TOOL_REPO/releases" |
    grep -oE '"tag_name": "[^"]+"' |
    sed 's/"tag_name": "v\?//' |
    sed 's/"//' |
    grep -E '^[0-9]' |
    sort -V
}

get_download_url() {
  local version="$1"
  local os="$(get_platform)"
  local arch="$(get_arch)"

  local asset_name
  asset_name="$(echo 'v_{os}.zip' | sed "s/{version}/$version/g" | sed "s/{os}/$os/g" | sed "s/{arch}/$arch/g")"

  local url="https://github.com/$TOOL_REPO/releases/download/v$version/$asset_name"
  if curl -sfLI "$url" >/dev/null 2>&1; then
    echo "$url"
  else
    echo "https://github.com/$TOOL_REPO/releases/download/$version/$asset_name"
  fi
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

  # Find and move binary
  if [[ ! -f "$download_path/$BINARY_NAME" ]]; then
    local found
    found="$(find "$download_path" -name "$BINARY_NAME" -type f | head -1)"
    if [[ -n "$found" ]]; then
      mv "$found" "$download_path/$BINARY_NAME"
    fi
  fi
  chmod +x "$download_path/$BINARY_NAME"
}

install_version() {
  local version="$1"
  local install_path="$2"

  mkdir -p "$install_path/bin"
  cp "$ASDF_DOWNLOAD_PATH/$BINARY_NAME" "$install_path/bin/"
  chmod +x "$install_path/bin/$BINARY_NAME"
}
