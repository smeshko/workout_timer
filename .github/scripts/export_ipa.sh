#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/QuickWorkouts.xcarchive \
            -exportOptionsPlist QuickWorkout/Product/exportOptions.plist \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
