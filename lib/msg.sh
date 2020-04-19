# Message and some metadata is encoded in csv
# See run/init if you want to see the exact format
# ${1} is the message string
msg_extractmsg() {
	oldifs="${IFS}"
	IFS=','
	set -- ${1}
	echo "${@}"
	IFS="${oldifs}"
}
