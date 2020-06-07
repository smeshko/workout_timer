#!/bin/bash

set -eo pipefail

xcodebuild -project WorkoutTimer.xcodeproj \
            -scheme WorkoutTimer \
            -sdk iphoneos \
            -configuration Release \
            -archivePath $PWD/build/WorkoutTimer.xcarchive \
            clean archive | xcpretty
