#!/bin/bash

set -eo pipefail

xcodebuild -project WorkoutTimer.xcodeproj \
            -scheme WorkoutTimer \
            -destination platform=iOS\ Simulator,OS=13.4.1,name=iPhone\ 11 \
            clean test | xcpretty
