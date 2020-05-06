# Simple commands that don't need 5 functions to do a thing

. lib/utils.sh

# ${1} is the choices separated by ' or '
choose() {
	q=? p= cnt=1 str='' cchr='' items=
	while [ ${cnt} -le ${#1} ]; do
		cchr="${1%"${1#${q}}"}"
		cchr="${cchr#${p}}"
		str="${str}${cchr}"
		[ "${str#"${str% or }"}" = " or " ] && {
			items="${items}
${str% or }"
			str=''
		}
		q="${q}?" p="${p}?"
		: $((cnt+=1))
	done
	[ -n "${str}" ] && items="${items}
${str}"
	oldifs="${IFS}"
	IFS='
'
	set -- ${items}
	eval echo \${`rand 1 ${#}`}
	IFS="${oldifs}"

	unset q p cnt str cchr items
}

# Effective shitposting, simply run the text through a sed script
shitpost() {
	sed '
y/ABCDEFGHIJKLMNOPQRSTUVWXYZ /abcdefghijklmnopqrstuvwxyz\t/
s/[^b\t]/:regional_indicator_&: /g
s/\t/:clap: /g
s/b/:b: /g
' <<EOF
${*}
EOF
}
