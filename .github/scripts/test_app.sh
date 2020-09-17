#!/bin/bash

set -eo pipefail

xcodebuild -project WorkoutTimer.xcodeproj \
            -scheme WorkoutTimer \
            -destination platform=iOS\ Simulator,OS=14.0,name=iPhone\ 11 \
            clean test | xcpretty
