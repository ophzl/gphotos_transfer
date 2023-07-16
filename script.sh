#!/bin/bash

DEST_DIR="Takeout"

# Merge all data in DEST_DIR
find ./ -type d -name "Takeout *" | while read dir; do 
    # Extract folder name
    SOURCE_DIR=$(basename "$dir")
    printf "\n=============== $takeout ===============\n"
    # Remove all folders from Google Photos' one
    mv "$SOURCE_DIR/Google Photos/*" "$SOURCE_DIR"
    rm -rf "$SOURCE_DIR/Google Photos/*"
    # Sync Takeout and Takout X folders
    rsync -av --ignore-existing "$SOURCE_DIR/" "$DEST_DIR/" 
    printf "\n=============== EXIT $takeout ===============\n" ;
done

printf "\n\n **== START TAKEOUT TREATMENT ==**\n\n"
# Get into Takeout to launch treatment and do the same as in the previous method
cd $DEST_DIR
mv ./Google\ Photos/* ./
rm -rf ./Google\ Photos

# Loop over folders to recover metadatas (/!\ NOT ALBUMS YET /!\)
find ./ -type d -name "Photos *" | while read final_dir; do 
    folder=$(basename "$final_dir")
    cd "$folder"
    printf "\n=============== $folder ===============\n"
    # Recover metadatas
    exiftool -d %s -tagsfromfile '%d/%F.json' '-GPSLatitude*<${GeoDataLatitude;$_ = undef if $_ eq "0.0"}' '-GPSLongitude*<${GeoDataLongitude;$_ = undef if $_ eq "0.0"}' '-Caption-Abstract<Description' '-Description<Description' '-XMP-xmp:Rating<${Favorited;$_=5 if $_=~/true/i}' '-AllDates<PhotoTakenTimeTimestamp' -execute '-FileCreateDate<ExifIFD:DateTimeOriginal' '-FileModifyDate<ExifIFD:DateTimeOriginal' -common_args -overwrite_original_in_place -ext jpg .
    printf "\n=============== EXIT $folder ===============\n"
    cd ..;
done 