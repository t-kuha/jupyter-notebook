@echo off
setlocal

:: 
:: Script to download and preprocess ImageNet Challenge 2012
:: training and validation data set.
::
:: The final output of this script are sharded TFRecord files containing
:: serialized Example protocol buffers. See build_imagenet_data.py for
:: details of how the Example protocol buffers contain the ImageNet data.
::
:: usage:
::  preprocess_imagenet.cmd [data-dir] [work-dir]

:: Create the output and temporary directories.
set DATA_DIR=%1

set SCRATCH_DIR=%DATA_DIR%\raw-data\
set WORK_DIR=%2

set LABELS_FILE=%WORK_DIR%\data\imagenet_lsvrc_2015_synsets.txt

:: Note the locations of the train and validation data.
set TRAIN_DIRECTORY=%SCRATCH_DIR%train\
set VALIDATION_DIRECTORY=%SCRATCH_DIR%validation\

:: Preprocess the validation data by moving the images into the appropriate
:: sub-directory based on the label (synset) of the image.
echo "Organizing the validation data into sub-directories."
set PREPROCESS_VAL_SCRIPT=%WORK_DIR%\data\preprocess_imagenet_validation_data.py
set VAL_LABELS_FILE=%WORK_DIR%\data\imagenet_2012_validation_synset_labels.txt

python %PREPROCESS_VAL_SCRIPT% %VALIDATION_DIRECTORY% %VAL_LABELS_FILE%

:: Convert the XML files for bounding box annotations into a single CSV.
echo "Extracting bounding box information from XML."
set BOUNDING_BOX_SCRIPT=%WORK_DIR%\data\process_bounding_boxes.py
set BOUNDING_BOX_FILE=%SCRATCH_DIR%\imagenet_2012_bounding_boxes.csv
set BOUNDING_BOX_DIR=%SCRATCH_DIR%bounding_boxes\

python %BOUNDING_BOX_SCRIPT% %BOUNDING_BOX_DIR% %LABELS_FILE% | sort > %BOUNDING_BOX_FILE%
echo "Finished downloading and preprocessing the ImageNet data."

:: Build the TFRecords version of the ImageNet data.
set BUILD_SCRIPT=%WORK_DIR%\data\build_imagenet_data.py
set OUTPUT_DIRECTORY=%DATA_DIR%\tfrecord
set IMAGENET_METADATA_FILE=%WORK_DIR%\data\imagenet_metadata.txt

python %BUILD_SCRIPT% ^
  --train_directory=%TRAIN_DIRECTORY% ^
  --validation_directory=%VALIDATION_DIRECTORY% ^
  --output_directory=%OUTPUT_DIRECTORY% ^
  --imagenet_metadata_file=%IMAGENET_METADATA_FILE% ^
  --labels_file=%LABELS_FILE% ^
  --bounding_box_file=%BOUNDING_BOX_FILE%
