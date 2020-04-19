rand=1787123987

log() {
	printf '%s: %s' `date +'%Y-%m-%d %H:%M'` "${@}" >>data/log
}

# For smaller files, this function should be significantly faster than cat
printfile() {
	while read -r l; do
		printf '%s' "${l}"
	done <${1}
	printf '\n'
}

# A really shitty random number generator
# TODO: Fix illegal number error
genrand() {
	a=`date +%N`
	m=115292150460684
	rand=$(((a*rand+2)%(m+rand%3)))
	unset m a
}
