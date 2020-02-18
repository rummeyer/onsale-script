#!/bin/bash

# calc week number with leading zero
WEEK=$(printf "`date +%V`")
if [ "$WEEK" -eq "52" ]; then
  WEEK="01"
fi

TEMPDIR="/home/pi/.tmp_$WEEK"
# clean and create temp dir
if [ -d "${TEMPDIR}" ]; then
  rm -rf "${TEMPDIR}"
fi
echo "Tempdir is ${TEMPDIR}"
mkdir "${TEMPDIR}"
cd "${TEMPDIR}"

PATTERN="*[-_]KW${WEEK}[-_.]*pdf"

# get files from website
wget --ignore-case -r -A "${PATTERN}" https://www.gebauer-markt.de/

# send special offers via email
echo "Sending PDF via E-Mail..."
# search pdf
find . -iname "${PATTERN}" -exec mpack -s "GEBAUER ANGEBOTE - Prospekt KW${WEEK}" {} oliver@rummeyer.de \;

# send alert if favorite keywords found
IFS=$'\n'
KEYWORDS="Schweitzers Schüümli
Ensinger
Live Fresh Shot
Innocent
Garden Gourmet"

for KEYWORD in ${KEYWORDS}; do
  echo "Processing '${KEYWORD}' alert..."
  find . -iname "${PATTERN}" -print0 | xargs -I{} -0 pdftotext -q {} - | grep -i -C 10 "$KEYWORD" | mail --exec 'set nonullbody' -s "GEBAUER ANGEBOTE - Reduziert '${KEYWORD}'" oliver@rummeyer.de sarah@rummeyer.de
done

# remove all downloaded files
echo "Deleting temp dir..."
#rm -rf "${TEMPDIR}"
