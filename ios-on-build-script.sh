# Set BROWSERSTACK_USERNAME & BROWSERSTACK_ACCESS_KEY variables before running this script

SCHEME_NAME="iOSSDKe2e"
CONFIGURATION="Release"
DESTINATION="generic/platform=iOS"
DIRECTORY=$(cd `dirname $0` && pwd)
ROOT_DIR="$(pwd)/build"
RELEASE_DIR="${ROOT_DIR}/${CONFIGURATION}-iphoneos"
PAYLOAD_DIR="${ROOT_DIR}/Payload"
APP_DIR="${RELEASE_DIR}/${SCHEME_NAME}.app"
IPA_DIR="${ROOT_DIR}/${SCHEME_NAME}.ipa"

CUSTOM_ID=objective-c-test-app

rm -rf $RELEASE_DIR
pod install --repo-update
xcodebuild -workspace iOSSDKe2e.xcworkspace -scheme iOSSDKe2e -configuration $CONFIGURATION -destination $DESTINATION CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO SYMROOT=$(pwd)/build clean build

rm -rf $PAYLOAD_DIR
mkdir -p $PAYLOAD_DIR

# # # Copy .app file from the build directory to the Payload directory
cp -R $APP_DIR $PAYLOAD_DIR

cd $ROOT_DIR
zip -r -X ${SCHEME_NAME}.ipa "Payload"
cd $DIRECTORY

rm -rf $RELEASE_DIR
rm -rf $PAYLOAD_DIR

echo "${IPA_DIR}"

curl -u "${BROWSERSTACK_USERNAME}:${BROWSERSTACK_ACCESS_KEY}" -X POST https://api-cloud.browserstack.com/app-automate/upload -F file=@"${IPA_DIR}" -F 'data={"custom_id":"'"${CUSTOM_ID}"'"}'