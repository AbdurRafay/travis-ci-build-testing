#!/bin/sh

# SDK_BRANCH=${1:-'master'}							#arafay/BotFiltering
# DIRECTORY=$(cd `dirname $0` && pwd)

# # echo "${DIRECTORY}"
# # cd $DIRECTORY

# # git reset --hard

# sed -i '' "s~\'master\'~'${SDK_BRANCH}'~g" 'Podfile'

# pod install

body='{
	"request": {
		"branch":"master",
		"config": {
			"env": {
				"matrix": ["CUSTOM_ID=MyiOSApp SDK_BRANCH=master WORKSPACE_DIR=iOSSDKe2e.xcworkspace SCHEME_NAME=iOSSDKe2e CONFIGURATION=\"Release\" DESTINATION=\"generic/platform=iOS\" DIRECTORY=$(cd `dirname $0` && pwd) ROOT_DIR=\"${DIRECTORY}/build\" RELEASE_DIR=\"${ROOT_DIR}/${CONFIGURATION}-iphoneos\" PAYLOAD_DIR=\"${ROOT_DIR}/Payload\" APP_DIR=\"${RELEASE_DIR}/${SCHEME_NAME}.app\" IPA_DIR=\"${ROOT_DIR}/${SCHEME_NAME}.ipa\""]
			}
		}
	}}'

curl -s -X POST \
 -H "Content-Type: application/json" \
 -H "Accept: application/json" \
 -H "Travis-API-Version: 3" \
 -H "Authorization: token UWcEAckPxu9vRUFy7Ma0UQ" \
 -d "$body" \
 https://api.travis-ci.com/repo/AbdurRafay%2Ftravis-ci-build-testing/requests