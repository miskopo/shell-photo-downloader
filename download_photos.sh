#!/bin/bash

# Check for requirements
[[ -z $(command -v rsync) ]] && { echo "rsync required" >&2; exit 1; }
[[ -z $(command -v rsync) ]] && { echo "exiftool required" >&2; exit 1; }

usage(){
    echo "Usage: download_photos [-i INPUT FOLDER] [-c CAMERA MODEL] [-o TARGET_PATH]"
}

while [ "$1" != "" ]; do
    case $1 in
        -c | --camera )         shift
                                CAMERA_MODEL=$1
                                ;;
        -o | --output )         shift
                                TARGET_PATH=$1
                                ;;
        -i | --input  )         shift
                                INPUT_FOLDER=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

# if not provided, use default camera manufacturer
[[ -z "$CAMERA_MODEL" ]] && CAMERA_MODEL="NIKON D7200"; # SD card formatted in camera is usually named like this
# iif not provided, use default  target base directory
[[ -z "$TARGET_PATH"  ]] && TARGET_PATH="/home/$USER/Pictures/Nikon";

# Color definitions
RED='\033[0;31m';
NC='\033[0m'; # No Color

if [[ -z "$INPUT_FOLDER" ]]; then
    # Check if SD card is in computer
    if [[ -d "/run/media/$USER/$CAMERA_MODEL" ]]; then
        SD_PATH="/run/media/$USER/$CAMERA_MODEL/DCIM";
        echo "SD card detected at $SD_PATH";
    else
        echo "No SD card from $CAMERA_MODEL detected.";
        exit 1;
    fi
else
    SD_PATH="$INPUT_FOLDER";
fi

# Enter the photo folder
[[ -d "$SD_PATH" ]] && cd "$SD_PATH" || $(echo "Invalid directory structure on SD card"; exit 1);

# Enter the inner folder
#INNER_FOLDER=$(ls)
#[[ -v INNER_FOLDER ]] && cd "$INNER_FOLDER" || $(echo "Invalid directory structure on SD card"; exit 1);


# Init error count
ERROR_COUNT=0;

# Securely copy photos to respective folders
for FILE in $(ls); do
    TAKEN_DATE=$(exiftool -p '$dateTimeOriginal' -d "%Y/%m/%d" "$FILE");

    YEAR=$(echo ${TAKEN_DATE} | cut -d "/" -f1);
    MONTH=$(echo ${TAKEN_DATE} | cut -d "/" -f2);
    DAY=$(echo ${TAKEN_DATE} | cut -d "/" -f3);

    FULL_TARGET_PATH="$TARGET_PATH/$YEAR/$MONTH/$DAY";

    echo "Copying $FILE to $FULL_TARGET_PATH"
        if [[ ${FILE: -4} == ".JPG" ]]; then
            mkdir -p "$FULL_TARGET_PATH/JPG" &&
            rsync -ahqu --progress ${FILE} "$FULL_TARGET_PATH/JPG" ||
            { echo "Error copying $FILE to $FULL_TARGET_PATH/JPG";
            ((++ERROR_COUNT));    }
        else
            mkdir -p "$FULL_TARGET_PATH" &&
            rsync -ahqu --progress ${FILE} "$FULL_TARGET_PATH" ||
            { echo "${RED}Error copying $FILE to $FULL_TARGET_PATH${NC}";
            ((++ERROR_COUNT)); }
        fi
done;

# All done, inform user
echo "Copying done, ${ERROR_COUNT} errors occurred.";

# Give option to unmount card
if [[ -z "$INPUT_FOLDER" ]]; then
    echo "Would you like to unmount the SD card now? ";
    read -p '([y]/n)' USER_RESPONSE;

    if [[ ${USER_RESPONSE} = '\n' || ${USER_RESPONSE} = 'y' ]]; then
        umount "/run/media/$USER/$CAMERA_MODEL";
        echo "You can detach the SD card now";
    else
        exit 0;
    fi
fi
