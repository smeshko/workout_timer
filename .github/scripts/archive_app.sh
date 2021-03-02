#!/bin/bash

set -eo pipefail

xcodebuild -project Timer\ Wiz.xcodeproj \
            -scheme Timer\ Wiz \
            -sdk iphoneos \
            -configuration Release \
            -archivePath $PWD/build/QuickWorkouts.xcarchive \
            clean archive | xcpretty
