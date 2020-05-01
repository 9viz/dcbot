# Sourced for using printfile
. lib/utils.sh

# Globals:
# _CONSUMED: It is reset by msg_extractmsg whenever it is called
#            It stores the string that is parsed by msg__parsesec
#       MSG: Temporary directory in which the message and its author are stored
#            It has to be removed in the main loop.

# Parse a section of the csv string. It can parse author and msg
# sucessfully but fails to parse json.
# To parse json, check msg__parsejson (WIP).
# ${1} is the csv string but with ${_CONSUMED} cut off from the beginning
msg__parsesec() {
	# _CONSUMED is the string that is already read by the function
	# This helps in separating off the section in msg_extractmsg
	# qskip - Set when the first / last character in the message is quotes
	# qqskip - Set when a double quotes appears. Used to replace double quotes
	# with single quotes.
	# quoted - Tracks if the section is quoted.
	# sskip - Set when the loop has to break -- section ends
	q=? p='' qskip=0 qqskip=0 sskip=0 quoted=0 content=''
	while [ ${sskip} -eq 0 ]; do
		chr="${1%"${1#${q}}"}"
		cchr="${chr#${p}}"
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
			[ -z "${pchr}" ] && [ "${cchr}" = \" ] &&
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
				# If the content string has quotes, then the section is quoted.
				# Handle it properly for looking at the characters surrounding the quote
				[ "${cchr}" = , ] && [ ${quoted} -eq 1 ] && [ "${pchr}" = \" ] &&
						[ -n "${nchr}" ] && [ "${nchr}" != \" ] && sskip=1
				[ ${sskip} -eq 0 ] && [ ${qqskip} -eq 0 ] && [ ${qskip} -eq 0 ] &&
						content="${content}${cchr}"
			}
		}
		ppchr=${pchr}
		pchr=${cchr}
		q="${q}?"
		p="${p}?"
		[ ${qqskip} -eq 1 ] && {
			_CONSUMED="${_CONSUMED}\""
			q="${q}?"
			p="${p}?"
			qqskip=0
		}
		[ ${qskip} -eq 1 ] && qskip=0
	done
	echo "${content}"
	unset q p qskip qqskip sskip quoted content pchr ppchr chr cchr
}

# This only returns the url field
msg__parsejson() {
	:
}

# Message and some metadata is encoded in csv
# See run/init if you want to see the exact format
# ${1} is the message string
msg_extractmsg() {
	_CONSUMED='' MSG=`mktemp -d` cnt=1
	while [ ${cnt} -le 2 ]; do
		case ${cnt} in
		1) msg__parsesec "${1#${_CONSUMED}}" >${MSG}/author ;;
		2) msg__parsesec "${1#${_CONSUMED}}" >${MSG}/msg    ;;
		esac
		: $((cnt+=1))
	done
	unset cnt
}

# ${1} is the csv string
msg_cmd() {
	msg_extractmsg "${1}"
	content=`printfile ${MSG}/msg`
	[ -n "${content}" ] && [ "${content%${content#?}}" = "${BPREFIX}" ]
}