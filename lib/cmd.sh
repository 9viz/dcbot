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
	# I could write a sed script but I want this to stay P U R E.
	cnt=0 q=? p='' res=''
	while [ ${cnt} -lt ${#1} ]; do
		chr="${1%"${1#${q}}"}"
		chr="${chr#${p}}"
		case ${chr} in
		[aA]) chr=":regional_indicator_a: " ;;
		[bB]) chr=":regional_indicator_b: " ;;
		[cC]) chr=":regional_indicator_c: " ;;
		[dD]) chr=":regional_indicator_d: " ;;
		[eE]) chr=":regional_indicator_e: " ;;
		[fF]) chr=":regional_indicator_f: " ;;
		[gG]) chr=":regional_indicator_g: " ;;
		[hH]) chr=":regional_indicator_h: " ;;
		[iI]) chr=":regional_indicator_i: " ;;
		[jJ]) chr=":regional_indicator_j: " ;;
		[kK]) chr=":regional_indicator_k: " ;;
		[lL]) chr=":regional_indicator_l: " ;;
		[mM]) chr=":regional_indicator_m: " ;;
		[nN]) chr=":regional_indicator_n: " ;;
		[oO]) chr=":regional_indicator_o: " ;;
		[pP]) chr=":regional_indicator_p: " ;;
		[qQ]) chr=":regional_indicator_q: " ;;
		[rR]) chr=":regional_indicator_r: " ;;
		[sS]) chr=":regional_indicator_s: " ;;
		[tT]) chr=":regional_indicator_t: " ;;
		[uU]) chr=":regional_indicator_u: " ;;
		[vV]) chr=":regional_indicator_v: " ;;
		[wW]) chr=":regional_indicator_w: " ;;
		[xX]) chr=":regional_indicator_x: " ;;
		[yY]) chr=":regional_indicator_y: " ;;
		[zZ]) chr=":regional_indicator_z: " ;;
		" ")  chr=":clap: "                 ;;
		esac
		res="${res}${chr}"
		p="${p}?"
		q="${q}?"
		: $((cnt+=1))
	done
	echo "${res}"
	unset cnt q p res
}
