log() {
	printf '%s: %s' `date +'%Y-%m-%d %H:%M` "${@}" >>data/log
}
