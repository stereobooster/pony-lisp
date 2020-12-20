#!/bin/sh

# https://gist.github.com/ohle/8c5129e148d3c5d8ac69
# https://github.com/idbrii/daveconfig/blob/master/multi/vim/scripts/buildtags
# https://github.com/blongden/ctags-iwatch

usage() {
	echo "USAGE: $0 [-t tagfile] [-d indexdir] directory" 1>&2
	echo "Watches for filesystem changes in the directory and runs ctags" 1>&2
	echo "Use -d indexdir to index a specific subdir" 1>&2
	exit 1
}

error() {
	echo $1 1>&2
	exit 1
}

TAGFILE=".tags"
WATCHDIR=$(pwd)

while getopts "t:d:" o
do
	case "$o" in
	t)
		TAGFILE=${OPTARG}
		;;
	d)
		INDEXDIR=${OPTARG}
		;;
	*)
		usage
		;;
	esac
done

shift $((OPTIND-1))
if [ -n "$1" ]
then
	WATCHDIR=$1
fi

[ -n "${INDEXDIR}" ] || INDEXDIR=${WATCHDIR}

command -v fswatch >/dev/null 2>&1 || error "Please install fswatch"
command -v ctags   >/dev/null 2>&1 || error "Please install ctags"

[ -d $WATCHDIR ] || error "${WATCHDIR} is not a directory"

echo "Tagfile:  ${TAGFILE}"
echo "Indexing: ${INDEXDIR}"
echo "Watching: ${WATCHDIR}"

fswatch -o $WATCHDIR -e ${TAGFILE} -l 10 --recursive | xargs -n1 -I{} ctags -R -f ${TAGFILE} ${INDEXDIR} >/dev/null 2>&1