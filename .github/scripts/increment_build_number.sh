buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PROJECT_DIR}/${INFOPLIST_FILE}")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${PROJECT_DIR}/${INFOPLIST_FILE}"

COMMIT_MESSAGE="Bumped build from $OLD_BUILD to $NEW_BUILD [Version: $OLD_VERSION Build: $NEW_BUILD]"
echo $COMMIT_MESSAGE | pbcopy