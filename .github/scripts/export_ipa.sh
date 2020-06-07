#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/WorkoutTimer.xcarchive \
            -exportOptionsPlist WorkoutTimer/Product/exportOptions.plist \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
