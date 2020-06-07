#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/WorkoutTimer.xcarchive \
            -exportOptionsPlist WorkoutTimer/WorkoutTimer/exportOptions.plist \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
