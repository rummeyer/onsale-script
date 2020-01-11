#!/bin/bash

# calc week number with leading zero
WEEK=$(printf "%02d" "`date +%V`")
if [ "$WEEK" -eq "52" ]; then
  WEEK="01"
fi

TEMPDIR="/home/pi/.tmp_$WEEK"
# clean and create temp dir
if [ -d "${TEMPDIR}" ]; then
  rm -rf "${TEMPDIR}"
fi
mkdir "${TEMPDIR}"
cd "${TEMPDIR}"

# get files from website
wget -r -A.pdf https://www.gebauer-markt.de/

# send special offers via email
echo "Sending PDF via E-Mail..."
# search pdf
find . -iname "Gebauer*[-_]KW${WEEK}[-_]*.pdf" -exec mpack -s "GEBAUER ANGEBOTE - Prospekt KW${WEEK}" {} oliver@rummeyer.com \;

# send alert if favorite keywords found
IFS=$'\n'
KEYWORDS="Schweitzers Schüümli
Seitenbacher Müsli
Almighurt
Bonne Maman
Ensinger
Live Fresh Shot"

for KEYWORD in ${KEYWORDS}; do
  echo "Processing '${KEYWORD}' alert..."
  find . -iname "Gebauer*[-_]KW${WEEK}[-_]*.pdf" -print0 | xargs -I{} -0 pdftotext -q {} - | grep -i -C 10 "$KEYWORD" | mail --exec 'set nonullbody' -s "GEBAUER ANGEBOTE - Reduziert '${KEYWORD}'" oliver@rummeyer.com
done

# remove all downloaded files
echo "Deleting temp dir..."
rm -rf "${TEMPDIR}"
