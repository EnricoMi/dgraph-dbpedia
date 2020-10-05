#!/bin/bash

RELEASE=2016-10
DATASET=core-i18n
LANGS=${2:-ar az be bg bn ca cs cy de el en eo es eu fr ga gl hi hr hu hy id it ja ko lv mk nl pl pt ro ru sk sl sr sv tr uk vi zh}
FILENAMES="labels infobox_properties interlanguage_links article_categories"
EXT=.ttl.bz2

base=${1:-$(pwd)/dbpedia}
dir="$base/$RELEASE/$DATASET"

echo "Downloading $RELEASE release of $DATASET into $dir"
echo
echo "Languages: $LANGS"
echo "Filenames: $FILENAMES"
echo

for lang in $LANGS
do
	echo "==== Language $lang ===="
	lang_dir="$dir/$lang"

	file="$lang_dir/_checksums.md5"
	if [ ! -e "$file" ]
	then
		echo "fetching checksums"
		curl -s --create-dirs "http://downloads.dbpedia.org/$RELEASE/$DATASET/$lang/_checksums.md5" -o "$file.part"
		mv "$file.part" "$file"
	fi

	for filename in $FILENAMES
	do
		filename="${filename}_$lang$EXT"
		file="$lang_dir/$filename"
		if [ ! -e "$file" ]
		then
			echo "fetching $filename"
			curl -C - --progress-bar --create-dirs "http://downloads.dbpedia.org/$RELEASE/$DATASET/$lang/$filename" -o "$file.part"
			mv "$file.part" "$file"
		fi
	done

	echo "checking checksums"
	(cd "$base/$RELEASE"; md5sum -c --ignore-missing $DATASET/$lang/_checksums.md5)

	echo
done

