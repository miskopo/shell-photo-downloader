#!/bin/bash

# Check for requirements
[[ -z $(command -v rsync) ]] && { echo "rsync required" >&2; exit 1; }
[[ -z $(command -v rsync) ]] && { echo "exiftool required" >&2; exit 1; }

# Define camera manufacturer
CAMERA_MODEL="NIKON D7200"
# Define target base directory
TARGET_PATH="/home/$USER/Pictures/Nikon"

# Check if SD card is in computer
if [ -d "/run/media/$USER/$MANUFACTURER" ]; then
	SD_PATH="/run/media/$USER/$CAMERA_MODEL";
	echo "SD card detected at $SD_PATH";
else
	echo "No SD card from $CAMERA_MODEL detected."; 
	exit 1;
fi

# Enter the DCIM folder
[[ -d "$SD_PATH/DCIM" ]] && cd "$SD_PATH/DCIM" || $(echo "Invalid directory structure on SD card"; exit 1);

# Enter the inner folder
INNER_FOLDER=$(ls)
[[ -v INNER_FOLDER ]] && cd "$INNER_FOLDER" || $(echo "Invalid directory structure on SD card"; exit 1);

# Securely copy photos to respective folders
for FILE in $(ls); do
	TAKEN_DATE=$(exiftool -p '$dateTimeOriginal' -d "%Y/%m/%d" "$FILE");
	YEAR=$(echo $TAKEN_DATE | cut -d "/" -f1);
	MONTH=$(echo $TAKEN_DATE | cut -d "/" -f2);
	DAY=$(echo $TAKEN_DATE | cut -d "/" -f3);
	FULL_TARGET_PATH="$TARGET_PATH/$YEAR/$MONTH/$DAY"
	echo "Copying $FILE to $FULL_TARGET_PATH"
		if [ ${FILE: -4} == ".JPG" ]; then
			mkdir -p "$FULL_TARGET_PATH/JPG" && 
			rsync -ahqu --progress $FILE "$FULL_TARGET_PATH/JPG"||
			echo "Error copying $FILE to $FULL_TARGET_PATH/JPG";
		else
			mkdir -p "$FULL_TARGET_PATH" && 
			rsync -ahqu --progress $FILE "$FULL_TARGET_PATH"||
			echo "Error copying $FILE to $FULL_TARGET_PATH";
		fi
	done;

# All done, inform user
echo "Copying done"
