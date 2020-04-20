rand=17871

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
# Illegal numbers are way less frequent using this method.
genrand() {
	a=`date +%N`
	m=11529215
	rand=$(((a*rand+b)%m))
}
