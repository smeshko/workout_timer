#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/Timer\ Wiz.xcarchive \
            -exportOptionsPlist Timer\ Wiz/Product/exportOptions.plist \
            -exportPath $PWD/build \
            -allowProvisioningUpdates \
            -exportArchive | xcpretty
