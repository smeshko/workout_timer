#!/bin/bash

set -eo pipefail

xcodebuild -project QuickWorkouts.xcodeproj \
            -scheme QuickWorkouts \
            -sdk iphoneos \
            -configuration Release \
            -archivePath $PWD/build/QuickWorkouts.xcarchive \
            clean archive | xcpretty
