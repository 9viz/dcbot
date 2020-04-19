# Message and some metadata is encoded in csv
# See run/init if you want to see the exact format
# ${1} is the message string
msg_extractmsg() {
	cnt=1 q='?' p='' state=author qskip=0 skip=0 sskip=0 quoted=0
	while [ ${cnt} -le ${#1} ]; do
		chr=${1%"${1#${q}}"}
		cchr=${chr#${p}}
		case ${state} in
		author)
			[ "${cchr}" = ',' ] && {
				state=content
				sskip=1
			}
			[ ${sskip} -eq 0 ] && author="${author}${cchr}"
			;;
		content)
			# If a comma is preceeded by a quote, then content ends
			# Unless, the previous character wrt the quote is also a
			# quote, in which case, we add ,
			[ "${cchr}" = ',' ] && {
				[ ${quoted} -eq 1 ] && [ "${pchr}" = \" ] && [ "${ppchr}" != \" ] &&
						state=embed sskip=1
				[ ${quoted} -eq 0 ] && state=embed sskip=1
			}
			[ ${sskip} -eq 0 ] && {
				# If " is the first character in content field, ignore
				# If message is quoted, then there might be a comma in the message.
				[ "${pchr}" = ',' ] && [ "${cchr}" = \" ] && {
					quoted=1
					qskip=1
				}
				[ ${skip} -eq 0 ] && {
					nchr="${1#"${chr}"}"
					nchr="${nchr%"${nchr#?}"}"
					# If the current character and the next character is "
					# then push a single "
					[ "${chr}" = \" ] && [ -n "${nchr}" ] && [ "${nchr}" = \" ] && {
						content="${content}\""
						skip=1
					}
					[ ${skip} -eq 0 ] && content="${content}${cchr}"
				}
			}
			;;
		esac
		ppchr=${pchr}
		pchr=${cchr}
		q="${q}?"
		p="${p}?"
		[ ${skip} -eq 1 ] && {
			q="${q}?"
			p="${p}?"
			skip=0
		}
		[ ${sskip} -eq 1 ] && sskip=0
		[ ${qskip} -eq 1 ] && qskip=0
		: $((cnt+=1))
	done
	echo ${author} ${content}
	unset cnt q p chr cchr nchr pchr ppchr skip sskip quoted
}
