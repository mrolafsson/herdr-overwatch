#!/bin/sh
# Installs the herdr-overwatch plugins (herdr-linear, herdr-github,
# herdr-recap, herdr-snooze) and binds a key to each, in one go.
#
#   sh install.sh                 all four, asking before each install
#   sh install.sh recap snooze    just those
#   sh install.sh --yes           without asking
#   sh install.sh --no-keys       install, but leave config.toml alone
#
# A plugin that's already installed (or linked) is left as it is. A key is
# only added when neither the key nor the action is bound already, so your
# own bindings always win. config.toml is backed up before it's changed.
set -eu

ALL="linear github recap snooze"
owner=mrolafsson
yes=""
keys=1
want=""

for arg in "$@"; do
	case "$arg" in
	-y | --yes) yes="--yes" ;;
	--no-keys) keys=0 ;;
	-h | --help)
		sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
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
	echo "herdr isn't on your PATH: install it first, from https://herdr.dev" >&2
	exit 1
}

installed=$(herdr plugin list --json 2>/dev/null || true)

is_installed() {
	printf '%s' "$installed" | grep -q "\"plugin_id\":\"herdr-$1\""
}

for p in $want; do
	if is_installed "$p"; then
		echo "herdr-$p is already installed, leaving it as it is."
	else
		echo "Installing herdr-$p…"
		# shellcheck disable=SC2086
		herdr plugin install $yes "$owner/herdr-$p"
	fi
done

[ "$keys" = 1 ] || exit 0

config="${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml"
mkdir -p "$(dirname "$config")"
touch "$config"

# The key each plugin's README suggests: key, action, description.
bindings() {
	case "$1" in
	linear) echo "prefix+alt+l|herdr-linear.open|Linear: issues and projects" ;;
	github)
		echo "prefix+alt+g|herdr-github.open|GitHub: pull requests"
		echo "prefix+alt+p|herdr-github.pr|GitHub: this agent's pull request"
		;;
	recap) echo "prefix+alt+r|herdr-recap.open|Recap: your agents" ;;
	snooze)
		echo "prefix+shift+z|herdr-snooze.agent|Snooze or wake agent"
		echo "prefix+alt+z|herdr-snooze.manage|Snooze: every agent"
		;;
	esac
}

added=""
skipped=""
backup=""
for p in $want; do
	bindings "$p" | while IFS='|' read -r key action desc; do
		if grep -q "command = \"$action\"" "$config"; then
			echo "skip:$action already has a key"
		elif grep -q "key = \"$key\"" "$config"; then
			echo "skip:$key is taken, so $action has no key; bind one in $config"
		else
			echo "add:$key|$action|$desc"
		fi
	done
done >"${TMPDIR:-/tmp}/herdr-overwatch-keys.$$"

while IFS= read -r line; do
	case "$line" in
	skip:*) skipped="$skipped
  ${line#skip:}" ;;
	add:*)
		if [ -z "$backup" ]; then
			backup="$config.bak-overwatch"
			cp "$config" "$backup"
		fi
		rest=${line#add:}
		key=${rest%%|*}
		rest=${rest#*|}
		action=${rest%%|*}
		desc=${rest#*|}
		printf '\n[[keys.command]]\nkey = "%s"\ntype = "plugin_action"\ncommand = "%s"\ndescription = "%s"\n' \
			"$key" "$action" "$desc" >>"$config"
		added="$added
  $key  $desc"
		;;
	esac
done <"${TMPDIR:-/tmp}/herdr-overwatch-keys.$$"
rm -f "${TMPDIR:-/tmp}/herdr-overwatch-keys.$$"

if [ -n "$added" ]; then
	echo "Keys added to $config (the old one is at $backup):$added"
	herdr server reload-config >/dev/null 2>&1 || echo "Reload herdr's config to use them: herdr server reload-config"
fi
[ -z "$skipped" ] || echo "Left alone:$skipped"
echo "Done. The plugins find each other by themselves; there's nothing else to set up."
