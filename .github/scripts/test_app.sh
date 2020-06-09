#!/bin/bash

set -eo pipefail

xcodebuild -project WorkoutTimer.xcodeproj \
            -scheme QuickTimer \
            -destination platform=iOS\ Simulator,OS=13.5,name=iPhone\ 11 \
            clean test | xcpretty
