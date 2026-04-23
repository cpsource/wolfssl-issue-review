#!/bin/bash
# Install (or uninstall) the wolfssl-issue-review skill into
# ~/.claude/skills/wolfssl-issue-review/.
#
# Usage:
#   ./skill-install.sh            install or reinstall (default)
#   ./skill-install.sh --uninstall remove the installed skill
#   ./skill-install.sh --help     show this message
#
# The script copies SKILL.md, README.md, LICENSE, references/, and
# assets/ into ~/.claude/skills/wolfssl-issue-review/. It does NOT
# copy .git/ or the install script itself.

set -eu

SKILL_NAME="wolfssl-issue-review"
TARGET="$HOME/.claude/skills/$SKILL_NAME"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

uninstall() {
    if [ ! -d "$TARGET" ]; then
        echo "Nothing to uninstall: $TARGET does not exist."
        exit 0
    fi
    echo "Removing $TARGET"
    rm -rf "$TARGET"
    echo "Uninstalled."
}

install() {
    if [ ! -f "$HERE/SKILL.md" ]; then
        echo "ERROR: SKILL.md not found at $HERE. Run this script from the" >&2
        echo "       wolfssl-issue-review repo root."                        >&2
        exit 1
    fi

    mkdir -p "$(dirname "$TARGET")"

    if [ -d "$TARGET" ]; then
        echo "Reinstalling over existing $TARGET"
        # Wipe target first so removed files don't linger.
        rm -rf "$TARGET"
    else
        echo "Installing to $TARGET"
    fi

    mkdir -p "$TARGET"

    cp "$HERE/SKILL.md"    "$TARGET/"
    cp "$HERE/README.md"   "$TARGET/"
    cp "$HERE/LICENSE"     "$TARGET/"
    cp -r "$HERE/references" "$TARGET/"
    cp -r "$HERE/assets"     "$TARGET/"

    echo "Installed files:"
    find "$TARGET" -type f | sed "s|^$TARGET/|  |"

    echo
    echo "The skill is ready. Restart Claude Code (or start a new"
    echo "session) for it to appear in the skills list. Trigger with"
    echo "'review issue N' or '/$SKILL_NAME N'."
}

case "${1:-}" in
    --uninstall) uninstall ;;
    --help|-h)   usage 0 ;;
    "")          install ;;
    *)           echo "unknown flag: $1" >&2; usage 1 ;;
esac
