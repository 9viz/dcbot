# Tags is sort of a database for images, messages, links, etc.
# You can set, delete and retrieve tags from the tags database.
# Tags database is simply a directory with the files named after
# the tag and its content will be the tag's content.
# To not let anyone delete someone's else tag, owner of the tag is
# stored in another directory. This is exactly the same as the tagdb
# but the content will the owner's name.

. lib/utils.sh

: ${_TAGDB:="${PREFIX}/data/tagdb"}
: ${_OWNDB:="${PREFIX}/data/tagowndb"}

# Is tag present?
# ${1} is the tag's name
tags__ispsr() {
	[ -e "${_TAGDB}/${1}" ]
}

# ${1} is the tag's name
# ${2} is the tag's author
# Everything else is tag's content
tags_set() {
	tags__ispsr "${1}" && {
		echo error: "${1}" already present!
		return 1
	}

	tag="${1}" auth="${2}"
	shift 2
	echo "${@}" >${_TAGDB}/"${tag}"
	echo "${auth}" >${_OWNDB}/"${tag}"
}

# ${1} is the tag's name
tags_get() {
	tags__ispsr || {
		echo error: "${1}" is not present!
		return 1
	}
	printfile "${_TAGDB}/${1}"
}

# Who is the owner of tag ${1}?
tags_owner() {
	printfile "${_OWNDB}/${1}"
}

# Parse a quoted set command
tags__quoted_set() {
	q=? p='' chr='' cchr='' nchr='' str="${1#\"}" consumed='' name=''
	while :; do
		chr="${str%"${str#${q}}"}"
		cchr="${chr#${p}}"
		consumed="${consumed}${cchr}"
		[ "${cchr}" = \" ] && {
			nchr="${str#"${chr}"}"
			nchr="${nchr%"${nchr#?}"}"
			[ "${nchr}" = ' ' ] && {
				consumed="${consumed} "
				break
			}
		}
		name="${name}${cchr}"
		q="${q}?"
		p="${p}?"
	done
	tags_set "${name}" "${2}" "${str#"${consumed}"}"
	unset q p chr cchr nchr str consumed name
}

# Parse the tag message
# ${1} is the message and ${2} is the author
tags_parse() {
	msg="${1#"${BPREFIX}tags "}" cmd="${msg%% *}"
	case ${cmd} in
	set)
		tag="${msg#set }"
		if [ "${tag%"${tag#?}"}" != \" ]; then
			tags_set "${tag%% *}" "${2}" "${tag#* }"
		else
			tags__quoted_set "${tag}" "${2}"
		fi
		;;
	get)
		tag="${msg#get }"
		# Remove trailing and leading quote
		tag="${tag#\"}"
		tags_get "${tag%\"}"
		;;
	del)
		tag="${msg#del }"
		# Remove trailing and leading quote
		tag="${tag#\"}"
		tag="${tag%\"}"
		tags__ispsr "${tag}" || {
			echo error: "${tag}" is not a valid tag
		}
		[ "${2}" != "$(tags_owner "${tag}")" ] && {
			echo error: ${2} is not the owner of "${tag}"
			skip=1
		}
		rm -f "${_TAGDB}/${tag}" "${_OWNDB}/${tag}"
		;;
	*)
		echo error: unknown tags command ${cmd}
		return 1
		;;
	esac

	unset msg tag
}
