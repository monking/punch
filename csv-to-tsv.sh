#!/bin/bash
if [[ -z "$TIMECLOCKDIR" ]]; then
	echo "Please define TIMECLOCKDIR before running this utility."
	exit 1
fi
read -n 1 -p "Convert all CSV files in your timeclock directory ($TIMECLOCKDIR) to TSV? (Y/n) "
if [[ ! $REPLY =~ ^[nN] ]]; then
	echo converting CSV timeclock files to TSV
	for csv_filename in $TIMECLOCKDIR/*.csv; do
		tsv_filename="${csv_filename/csv/tsv}"
		mv "$csv_filename" "$tsv_filename"
		sed -i .bak -E 's/", ?"/"	"/g' "$tsv_filename"
	done
	read -n 1 -p "remove temporary files created during conversion? (Y/n) "
	echo
	if [[ ! $REPLY =~ ^[nN] ]]; then
		echo "removing temporary files..."
		rm $TIMECLOCKDIR/*.tsv.bak &&
			echo "done" ||
			echo "something went wrong. You may need to clean up the temporary files ($TIMECLOCKDIR/*.tsv.bak) yourself)"
	fi
fi
