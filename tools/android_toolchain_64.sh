#!/bin/bash
#-------------------------------------------------------------------------------------------------------
# Copyright (C) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
#-------------------------------------------------------------------------------------------------------

if [ $# -eq 0 ]
then
  echo "usage: android_toolchain <ndk_path>"
  exit
fi

ANDROID_TARGET=android-21

export TOOLCHAIN=$PWD/android-toolchain-arm64
rm -rf $TOOLCHAIN
mkdir -p $TOOLCHAIN
$1/build/tools/make-standalone-toolchain.sh \
    --toolchain=aarch64-linux-android-4.9 \
    --arch=arm64 \
    --install-dir=$TOOLCHAIN \
    --platform=$ANDROID_TARGET --force

# use system python
rm $TOOLCHAIN/bin/python

# keep cmake from using system ranlib
cp android-toolchain-arm64/bin/aarch64-linux-android-ranlib android-toolchain-arm64/bin/ranlib
