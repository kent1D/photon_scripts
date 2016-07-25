#!/bin/sh
# Bash update script of Photon geocoder Indexes
# Version 0.0.2
#
# Dependences : 
# - wget (to retrieve the updated file, should be by default on debian, not curl)
# - pbzip2 or bzip2 to uncompress retrieved file
# - python to retrieve Index creation date from elastic search json API
# - the photon start-stop script to restart photon easily
#
WGET=$(which wget)
PYTHON=$(which python)
BZIP=$(which pbzip2)

URL_DL_PHOTON=http://download1.graphhopper.com/public/photon-db-latest.tar.bz2
ELASTIC_PORT="9200"
PHOTON_DIR="/var/www/photon/"
USER="www-data"
GROUP="www-data"

# Include defaults if present
# It permits to modify the variables :
# - URL_DL_PHOTON : Url where to download the indexes
# - ELASTIC_PORT : the local port of elastic search
# - PHOTON_DIR : the directory where your photon db is stored
# - USER / GROUP : Unix user and group owners of the files 
if [ -r /etc/default/photon_update ]; then
	. /etc/default/photon_update
fi

# Use of pbzip2 or bzip2
# If none of them exists exit 
if [ "$BZIP" ] && [ -x $BZIP ]; then
	echo "We will use pbzip2 to uncompress the file"
else
	BZIP=$(which bzip2)
	if [ ! "$BZIP" ] || [ ! -x $BZIP ]; then
		echo "Bzip2 not installed"
		exit 1;
	fi
fi

# Is wget installed, if not exit
if [ "$WGET" ] && [ -x $WGET ]; then
	DATE_URL=$($WGET --server-response --spider $URL_DL_PHOTON 2>&1 |grep Last-Modified | awk -F 'Last-Modified: ' '{ print $2 }')
	# Is the server response OK, if not exit
	if [ "$DATE_URL" ] ; then
		DATE_URL=$(date --date="$DATE_URL" +"%s")
		echo "Date of the file on the server (timestamp) : $DATE_URL"
		# Is python installed, if not exit
		if [ "$PYTHON" ] && [ -x $PYTHON ]; then
			INDEX_DATE=$(wget -q -O - localhost:$ELASTIC_PORT/photon/_settings | python -W ignore -c "import json,sys;obj=json.load(sys.stdin);print obj['photon']['settings']['index']['creation_date'];")
			# If we can retrieve a creation date
			# Photon should be up and running
			if [ "$INDEX_DATE" ] ; then
				INDEX_DATE=$(expr $INDEX_DATE / 1000 + 162800);
				echo "Creation date of the Photon's Elastic search indexes : $INDEX_DATE (with 2 days delay to be assume the possible delay from the creation and end of the index)"
				INTERVAL=$(expr $DATE_URL - $INDEX_DATE);
				if [ ${DATE_URL} -ge ${INDEX_DATE} ]; then
					echo "Update of the Photon's Elastic Search indexes"
					cd $PHOTON_DIR
					if [ ! -d $PHOTON_DIR/photon_data_save ]; then
						mkdir -p $PHOTON_DIR/photon_data_save/
					fi
					rm -Rvf $PHOTON_DIR/photon_data_save/*
					mv $PHOTON_DIR/photon_data/* $PHOTON_DIR/photon_data_save
					wget -O - http://download1.graphhopper.com/public/photon-db-latest.tar.bz2 | $BZIP -cd | tar x
					chown -Rvf $USER:$GROUP photon_data
					sudo service photon restart
				else
					echo "Your Photon's Elasticsearch Indexes seem to be up to date"
					exit 1;
				fi
			else
				echo "Elastic search doesn't seem to be reachable on port $ELASTIC_PORT, are you sure Photon is up and running ?"
				exit 1;
			fi
		fi
	else
		echo "Bad andwer from the repository server"
	fi
else
	echo "Wget not installed ?"
	exit 1
fi