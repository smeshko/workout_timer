#!/bin/bash

set -eo pipefail

xcodebuild -project Timer\ Wiz.xcodeproj \
            -scheme Timer\ Wiz \
            -destination platform=iOS\ Simulator,OS=14.0,name=iPhone\ 11 \
            clean test | xcpretty
