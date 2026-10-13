#!/bin/sh
# Uninstalls the herdr-overwatch plugins and takes their keys out of
# config.toml.
#
#   sh uninstall.sh                 all four
#   sh uninstall.sh snooze          just that one
#   sh uninstall.sh --keep-keys     uninstall, but leave config.toml alone
#
# Only [[keys.command]] blocks for these plugins' actions are removed, yours
# or the installer's. config.toml is backed up before it's changed. Sidebar
# rows you added their tokens to ($pr, $issue, $snoozed...) are left for you.
set -eu

ALL="linear github recap snooze"
keys=1
want=""

for arg in "$@"; do
	case "$arg" in
	--keep-keys) keys=0 ;;
	-h | --help)
		sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	linear | github | recap | snooze) want="$want $arg" ;;
	herdr-linear | herdr-github | herdr-recap | herdr-snooze) want="$want ${arg#herdr-}" ;;
	*)
		echo "Unknown argument: $arg (try --help)" >&2
		exit 2
		;;
	esac
done
[ -n "$want" ] || want="$ALL"

command -v herdr >/dev/null 2>&1 || {
	echo "herdr isn't on your PATH" >&2
	exit 1
}

installed=$(herdr plugin list --json 2>/dev/null || true)

for p in $want; do
	if printf '%s' "$installed" | grep -q "\"plugin_id\":\"herdr-$p\""; then
		echo "Uninstalling herdr-$p…"
		herdr plugin uninstall "herdr-$p"
	else
		echo "herdr-$p isn't installed."
	fi
done

[ "$keys" = 1 ] || exit 0

config="${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml"
[ -f "$config" ] || exit 0

ids=""
for p in $want; do ids="$ids herdr-$p"; done

# A [[keys.command]] block runs until the next table header; it goes when its
# command is one of these plugins' actions.
tmp="$config.overwatch-tmp"
awk -v ids="$ids" '
	function flush() {
		if (inkey && drop) removed++
		else printf "%s", buf
		buf = ""; inkey = 0; drop = 0
	}
	BEGIN { n = split(ids, list, " ") }
	/^[ \t]*\[/ { flush(); if ($0 ~ /^[ \t]*\[\[keys\.command\]\][ \t]*$/) inkey = 1 }
	{
		buf = buf $0 "\n"
		if (inkey && $0 ~ /^[ \t]*command[ \t]*=/)
			for (i = 1; i <= n; i++)
				if (index($0, "\"" list[i] ".") > 0) drop = 1
	}
	END { flush(); print removed + 0 > "/dev/stderr" }
' "$config" >"$tmp" 2>"$tmp.count"
removed=$(cat "$tmp.count")
rm -f "$tmp.count"

if [ "$removed" -gt 0 ]; then
	cp "$config" "$config.bak-overwatch"
	mv "$tmp" "$config"
	echo "Removed $removed key binding(s) from $config (the old one is at $config.bak-overwatch)."
	herdr server reload-config >/dev/null 2>&1 || echo "Reload herdr's config: herdr server reload-config"
else
	rm -f "$tmp"
fi
echo "Done. herdr keeps each plugin's config and state directories; each plugin's README says where."
