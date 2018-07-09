# SDK_BRANCH=${1:-'master'}							#arafay/BotFiltering
# DIRECTORY=$(cd `dirname $0` && pwd)

# # echo "${DIRECTORY}"
# # cd $DIRECTORY

# # git reset --hard

# sed -i '' "s~\'master\'~'${SDK_BRANCH}'~g" 'Podfile'

# pod install

body='{
"request": {
"branch":"master"
}}'

curl -s -X POST \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   -H "Travis-API-Version: 3" \
   -H "Authorization: token UWcEAckPxu9vRUFy7Ma0UQ" \
   -d "$body" \
   https://api.travis-ci.com/repo/AbdurRafay%2Ftravis-ci-build-testing/requests
  