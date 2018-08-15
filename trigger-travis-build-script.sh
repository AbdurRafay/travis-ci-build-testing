#!/bin/sh

CUSTOM_ID=${1:-'objective-c-test-app'}		#\"objective-c-test-app\"
NUM_RUNS=$2

TRAVIS_AUTH_TOKEN=UWcEAckPxu9vRUFy7Ma0UQ	#\"UWcEAckPxu9vRUFy7Ma0UQ\"
SDK_REPO_OWNER=optimizely
SDK_REPO_NAME=objective-c-test-app

# json of env variables to trigger travis with.
body='{
	"request": {
		"branch":"master",
		"config": {
			"env": {
				"matrix": "CUSTOM_ID='${CUSTOM_ID}' NUM_RUNS='${NUM_RUNS}' WORKSPACE_DIR=\"iOSSDKe2e.xcworkspace\" SCHEME_NAME=\"iOSSDKe2e\" CONFIGURATION=\"Release\" DESTINATION=\"generic/platform=iOS\" DIRECTORY=$(cd `dirname $0` && pwd) ROOT_DIR=\"${DIRECTORY}/build\" RELEASE_DIR=\"${ROOT_DIR}/${CONFIGURATION}-iphoneos\" PAYLOAD_DIR=\"${ROOT_DIR}/Payload\" APP_DIR=\"${RELEASE_DIR}/${SCHEME_NAME}.app\" IPA_DIR=\"${ROOT_DIR}/${SCHEME_NAME}.ipa\""
			}
		}
	}
}'

# trigger travis script on latest master build.
curl -s -X POST \
 -H "Content-Type: application/json" \
 -H "Accept: application/json" \
 -H "Travis-API-Version: 3" \
 -H "Authorization: token ${TRAVIS_AUTH_TOKEN}" \
 -d "$body" \
 https://api.travis-ci.com/repo/${SDK_REPO_OWNER}%2F${SDK_REPO_NAME}/requests -o travis_request.json

# parse repository.id & request.id from json response
REPOSITORY_ID=$(jq -r '.repository.id' travis_request.json)
REQUEST_ID=$(jq -r '.request.id' travis_request.json)

echo "Repository ID: '${REPOSITORY_ID}'"
echo "Request ID: '${REQUEST_ID}'"

# check build status after every 30 seconds.
BUILD_STATE=""
while [ "$BUILD_STATE" != "errored" -a "$BUILD_STATE" != "passed" ]; do
	sleep 30;
	curl -H "Travis-API-Version: 3" -H "User-Agent: API Explorer" \
         -H "Authorization: token ${TRAVIS_AUTH_TOKEN}" \
         https://api.travis-ci.com/repo/$REPOSITORY_ID/request/$REQUEST_ID -o travis_response.json

    BUILD_STATE=$(jq -r '.builds[0].state' travis_response.json)
	echo $BUILD_STATE    
done

echo "Test app build completed with status '${BUILD_STATE}'"