#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/QuickWorkouts.xcarchive \
            -exportOptionsPlist QuickWorkouts/Product/exportOptions.plist \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
