# Shell Photo downloader  :shipit:

Shell script to download RAW and/or JPG photos from DSLR's card. Photos are copied, not moved. User can unmount the card
upon copying from within the script.

## Prerequisites
`rsync`
`exiftools`

it should be in standard repositories of every major system

## Usage
set variables at the beginning of the script

`CAMERA_MODEL` determines symlink name of the SD card, e.g. "Nikon D7200"

`TARGET_PATH` determines root folder where to copy photos

## Directory structure
this script copies photos to folder structure as follows:

    TARGET_PATH/Year/Month/Day/NAME.ext
    
or 

    TARGET_PATH/Year/Month/Day/JPG/NAME.jp[e]g
    
Date used is date of photo's capture read from exif.
 
