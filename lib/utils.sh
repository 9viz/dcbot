log() {
	printf '%s: %s' `date +'%Y-%m-%d %H:%M` "${@}" >>data/log
}

# For smaller files, this function should be significantly faster than cat
printfile() {
	while read -r l; do
		printf '%s' "${l}"
	done <${1}
	printf '\n'
}
