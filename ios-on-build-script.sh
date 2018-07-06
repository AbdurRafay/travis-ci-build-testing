WORKSPACE_DIR=$1	 			#"testApp/iOSSDKe2e/iOSSDKe2e.xcworkspace"
SCHEME_NAME=$2 					#"iOSSDKe2e"
CONFIGURATION="Release"
DESTINATION="generic/platform=iOS"
DIRECTORY=$(cd `dirname $0` && pwd)
ROOT_DIR="${DIRECTORY}/build"
RELEASE_DIR="${ROOT_DIR}/${CONFIGURATION}-iphoneos"
PAYLOAD_DIR="${ROOT_DIR}/Payload"
APP_DIR="${RELEASE_DIR}/${SCHEME_NAME}.app"
IPA_DIR="${ROOT_DIR}/${SCHEME_NAME}.ipa"

rm -rf $RELEASE_DIR

xcodebuild -workspace $WORKSPACE_DIR -scheme $SCHEME_NAME -configuration $CONFIGURATION -destination $DESTINATION CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO SYMROOT=$ROOT_DIR clean build

rm -rf $PAYLOAD_DIR
mkdir -p $PAYLOAD_DIR

# # Copy .app file from the build directory to the Payload directory
cp -R $APP_DIR $PAYLOAD_DIR

cd $ROOT_DIR
zip -r -X ${SCHEME_NAME}.ipa "Payload"
cd $DIRECTORY

rm -rf $RELEASE_DIR
rm -rf $PAYLOAD_DIR

echo "${IPA_DIR}"