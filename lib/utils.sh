rand=1

log() printf '%s: %s\n' `date +'%Y-%m-%d:%H:%M'` "${*}" >>data/log;

# For smaller files, this function should be significantly faster than cat
printfile() {
	while read -r l; do
		printf '%s\n' "${l}"
	done <${1}
}

# A really shitty random number generator
# But works for choose
_genrand() {
	a=`date +%s`
	rand=$(((a*rand+2)%16777216))
}

# Generate a random between given range, both inclusive
rand() {
	[ ${rand} -eq 1 ] && for _ in 1 2 3 4; do _genrand; done
	_genrand
	echo $((rand%(${2}+1-${1})+${1}))
}
