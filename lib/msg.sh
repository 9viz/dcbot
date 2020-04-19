. lib/utils.sh

# Parse a section of the message
msg__parsesec() {
	# _CONSUMED is the string that is read by the function
	# This helps in separating off the section in msg_extractmsg
	# qskip - Set when the first / last character in the message is quotes
	# qqskip - Set when a double quotes appears. Used to replace double quotes
	# with single quotes.
	# quoted - Tracks if the section is quoted.
	# sskip - Set when the loop has to break -- section ends
	q=? p='' qskip=0 qqskip=0 sskip=0 quoted=0 content=''
	while [ ${sskip} -eq 0 ]; do
		chr=${1%"${1#${q}}"}
		cchr=${chr#${p}}
		[ -z "${cchr}" ] && break
		_CONSUMED="${_CONSUMED}${cchr}"
		# If a comma is preceeded by a quote, then content ends
		# Unless, the previous character wrt the quote is also a
		# quote, in which case, we add ,
		[ "${cchr}" = ',' ] && {
			[ ${quoted} -eq 1 ] && [ "${pchr}" = \" ] && [ "${ppchr}" != \" ] &&
				sskip=1
			[ ${quoted} -eq 0 ] && sskip=1
		}
		[ ${sskip} -eq 0 ] && {
			# If " is the first character in content field, ignore
			# If message is quoted, then there might be a comma in the message.
			[ "${cchr}" = \" ] &&
				quoted=1 qskip=1
			[ ${qskip} -eq 0 ] && {
				nchr="${1#"${chr}"}"
				nchr="${nchr%"${nchr#?}"}"
				[ "${cchr}" = \" ] && {
					# If the current character and the next character is "
					# then push a single "
					[ -n "${nchr}" ] && [ "${nchr}" = \" ] &&
						content="${content}\"" qqskip=1
					# If the current character is a quote and the next character is a comma
					# then don't push anything
					[ -n "${nchr}" ] && [ "${nchr}" = , ] &&
						qskip=1
				}
				[ ${qqskip} -eq 0 ] && [ ${qskip} -eq 0 ] && content="${content}${cchr}"
			}
		}
		ppchr=${pchr}
		pchr=${cchr}
		q="${q}?"
		p="${p}?"
		[ ${qqskip} -eq 1 ] && {
			q="${q}?"
			p="${p}?"
			qqskip=0
		}
		[ ${qskip} -eq 1 ] && qskip=0
	done
	echo "${content}"
	echo "${_CONSUMED}" >${tmpf}
	unset q p qskip qqskip sskip quoted content pchr ppchr chr cchr _CONSUMED
}


# Message and some metadata is encoded in csv
# See run/init if you want to see the exact format
# ${1} is the message string

# TODO: Think of a way to store the value of the variables
msg_extractmsg() {
	tmpf=$(mktemp)
	cnt=1
	while [ ${cnt} -le 4 ]; do
		[ -f ${tmpf} ] && _CONSUMED="$(printfile ${tmpf})"
		case ${cnt} in
		1)
			author="$(msg__parsesec "${1#${_CONSUMED}}")"
			: $((cnt+=1))
			;;
		2)
			content="$(msg__parsesec "${1#${_CONSUMED}}")"
			: $((cnt+=1))
			;;
		3)
			embed="$(msg__parsesec "${1#${_CONSUMED}}")"
			: $((cnt+=1))
			;;
		4)
			attach="$(msg__parsesec "${1#${_CONSUMED}}")"
			: $((cnt+=1))
			;;
		esac
	done
	rm -f ${tmpf}
}
