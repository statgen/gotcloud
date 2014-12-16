#!/bin/bash

echo "Downloading and extracting GenomeStrip metadata"

source bin/set_metadata.sh

if [ $# -lt 1 ]
then
    echo "You must specify the metadata root directory"
    exit 1
fi
rootDir=$1

mkdir -p $rootDir
if [ ! -d $rootDir ]
then
    echo "The metadata root directory $rootDir does not eist"
    exit 1
fi
cd $rootDir

wget ftp://ftp.broadinstitute.org/pub/svtoolkit/metadata/${METADATA_ARCHIVE_NAME}
wget ftp://ftp.broadinstitute.org/pub/svtoolkit/metadata/${METADATA_ARCHIVE_NAME}.md5

echo "Computing md5sum for ${METADATA_ARCHIVE_NAME}..."
archiveMd5Sum=`md5sum ${METADATA_ARCHIVE_NAME} | cut -d ' ' -f 1,1`
expectedMd5Sum=`cat ${METADATA_ARCHIVE_NAME}.md5`

if [ "$archiveMd5Sum" != "$expectedMd5Sum" ]
then
    echo "Downloaded archive's md5sum is '$archiveMd5Sum' instead of the expected '$expectedMd5Sum'"
    exit 1
fi

tar -zxvf ${METADATA_ARCHIVE_NAME}
if [ $? -ne 0 ]
then
    echo "There was an error extracting the metadata archive"
    exit 1
else
    rm ${METADATA_ARCHIVE_NAME}
    rm ${METADATA_ARCHIVE_NAME}.md5
    echo "GenomeStrip metadata was successfully downloaded and extracted"
fi
