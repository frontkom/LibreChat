#!/bin/sh
set -eu

# Render persistent disks can be mounted at a single path.
# LibreChat stores:
# - Non-image uploads under: /app/uploads
# - Image uploads (served via /images/*) under: /app/client/public/images
#
# This script makes both paths point into a single mounted data directory by symlinking:
# - /app/uploads -> $LIBRECHAT_DATA_DIR/uploads
# - /app/client/public/images -> $LIBRECHAT_DATA_DIR/images
#
# Configure your Render disk mount to match LIBRECHAT_DATA_DIR (recommended: /app/data).

DATA_DIR="${LIBRECHAT_DATA_DIR:-/app/data}"

mkdir -p "${DATA_DIR}/uploads" "${DATA_DIR}/images"

link_dir() {
  src="$1"
  dest="$2"

  # If already linked correctly, do nothing.
  if [ -L "${src}" ] && [ "$(readlink "${src}")" = "${dest}" ]; then
    return 0
  fi

  # If it exists as a directory, copy any existing contents once.
  if [ -d "${src}" ] && [ ! -L "${src}" ]; then
    # Best-effort copy; don't fail on empty dirs.
    if ls -A "${src}" >/dev/null 2>&1; then
      cp -a "${src}/." "${dest}/" 2>/dev/null || true
    fi
    rm -rf "${src}"
  else
    # If it's a file or broken symlink, remove it.
    rm -f "${src}" 2>/dev/null || true
  fi

  # Ensure parent exists then link.
  mkdir -p "$(dirname "${src}")"
  ln -s "${dest}" "${src}"
}

link_dir "/app/uploads" "${DATA_DIR}/uploads"
link_dir "/app/client/public/images" "${DATA_DIR}/images"

