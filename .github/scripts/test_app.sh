#!/bin/bash

set -eo pipefail

xcodebuild -project QuickWorkouts.xcodeproj \
            -scheme QuickWorkouts \
            -destination platform=iOS\ Simulator,OS=14.0,name=iPhone\ 11 \
            clean test | xcpretty
