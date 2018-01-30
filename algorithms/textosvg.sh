#!/bin/bash

# This program converts all tex files encountered in the directory provided as first argument to svg files
# Script passed shellcheck 0.4.7 test, https://www.shellcheck.net

# SYNOPSIS
# textosvg.sh [working-directory]
#
# By default, working-directory set to where the bash script is present.

# SYSTEM DEPENDENCIES
# pdflatex
# pdf2svg
# inkscape
# texlive recommanded for texfot util

echoerr() {
  # shellcheck disable=SC1117
  echo -e "\033[0;31m$1\033[0m"  1>&2
}

dirarg="$1"
if [ ! -z "$dirarg" ] && [ ! -d "$dirarg" ]; then
  echoerr "Directory \"$dirarg\" does not exists. Exiting."
  exit 1
fi
if [ ! -z "$dirarg" ] && [ -d "$dirarg" ]; then
  workdir="$( cd "$dirarg" && pwd )"
else
  workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
fi

tempdir=$(mktemp -d -t textosvg.XXXXXXXX)
if [ ! $? ]; then
  echoerr "Could not create temporary folder $tempdir, exiting"
  exit 1
else
  echo "Working directory: $workdir"
fi

pkgmgr=""
if [ ! -z "$(which yum)" ]; then
	pkgmgr="yum install"
fi
if [ ! -z "$(which apt-get)" ]; then
	pkgmgr="apt-get install"
fi

istexof=0
if [ ! -z "$(which texfot)" ]; then
  istexof=1
fi

# Function to check for and install needed packages
checkpkg() {
	if [[ $(which "$1") == "" ]]; then
		echo -n "Package '$1' not found!"
    if [[ ! $pkgmgr == "" ]]; then
      echo "Attempt installation? (y/n)"
      read -r -n1 answer
      echo
      case $answer in
        y) $pkgmgr "$1"
        ;;
        n) echo -n "Proceed anyway? (y/n) "
        read -r -n1 answer2
        echo
        if [[ "$answer2" == "n" ]] ; then exit
        fi
        ;;
      esac
    fi
	fi
}

cleanup() {
  if [ -d "$tempdir" ]; then
    rm -r "$tempdir"
  fi
}

# MAIN

echo "Checking dependencies..."
checkpkg pdflatex
checkpkg pdf2svg
checkpkg inkscape

for filename in "$workdir"/*.tex; do
  [ -e "$filename" ] || continue
  basefilename=$(basename "$filename")
  rootname=${basefilename%.tex}
  pdfpath="$tempdir/$rootname.pdf"
  svgpath="$workdir/$rootname.svg"
  texexitstatus=1
  echo "Converting \"$basefilename\" ..."
  if [ $istexof ]; then
    # texfot filters latex output to retain interresting feedback
    texfot --quiet --ignore "^This is pdfTeX" --ignore "^Output written on" pdflatex -output-directory "$tempdir" -shell-escape -synctex=1 -file-line-error -interaction=nonstopmode "$filename"
    texexitstatus=$?
  else
    # texfot is not available so we filter with a little regex
    pdflatex -output-directory "$tempdir" -shell-escape -synctex=1 -file-line-error -interaction=nonstopmode "$filename" | grep ".*:[0-9]*:.*"
    texexitstatus=${PIPESTATUS[0]}
  fi
  if [ "$texexitstatus" -ne 0 ]; then
    echoerr "Pdftex failed to compile file  \"$filename\", exiting"
    cleanup
    exit 1
  fi
  pdf2svg "$pdfpath" "$svgpath"
  if [ ! $? ]; then
    echoerr "pdf2svg failed to compile file \"$pdfpath\", exiting"
    cleanup
    exit 1
  fi
  echo "File \"$rootname.svg\" created successfully."
done
cleanup
echo "Done !"
