#!/bin/bash

set -eo pipefail

xcodebuild -project WorkoutTimer.xcodeproj \
            -scheme WorkoutTimer \
            -sdk iphoneos \
            -configuration AppStoreDistribution \
            -archivePath $PWD/build/WorkoutTimer.xcarchive \
            clean archive | xcpretty
