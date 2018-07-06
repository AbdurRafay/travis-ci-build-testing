SDK_BRANCH=${1:-'master'}							#arafay/BotFiltering
DIRECTORY=$(cd `dirname $0` && pwd)

# echo "${DIRECTORY}"
cd $DIRECTORY

git reset --hard

sed -i '' "s~\'master\'~'${SDK_BRANCH}'~g" 'Podfile'

pod install
