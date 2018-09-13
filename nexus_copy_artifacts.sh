#!/bin/bash
#
#
#  Copy repository artifacts from Nexus 3 to another Nexus 3 instance
#  Run this on the source Nexus 3 machine and make sure the repository already exists on the target
#  Prerequisites: curl, jq, wget
#
#                      "If it looks stupid but it works, it ain't stupid."
#
#####################################################################################################
# Define opts
while getopts h:P:u:p:r:H:U:W: option
do
case "${option}"
in
h) HOST=${OPTARG};;
P) PORT=${OPTARG};;
u) USER=${OPTARG};;
p) PASSWORD=${OPTARG};;
r) REPO=${OPTARG};;
H) TARGET_HOST=${OPTARG};;
U) TARGET_HOST_USER=${OPTARG};;
W) TARGET_HOST_PASSWORD=${OPTARG};;
esac
done

# Get all assets for soecified repository and extract download URL
curl -X GET -u ${USER}:"${PASSWORD}" http://${HOST}:${PORT}/service/rest/beta/search/assets?repository=${REPO} | jq -r '.items| .[]| .downloadUrl' > temp_${REPO}
# Read download urls into array
declare -p urls
readarray -t urls < ./temp_${REPO}
# Create temp directory for storing the artifacts - be aware that you got enough free disk space! Of course you can also change the location here ;)
mkdir -p ./assets
# wget all artifacts from array
for i in "${urls[@]}"
do
 wget --cut-dirs=2 -nH -x -P ./assets ${i}
done
# Upload the artifacts to the target instance
cd assets/
find ./ -type f | sed "s|^\./||" | xargs -I '{}' curl -u "${TARGET_HOST_USER}:${TARGET_HOST_PASSWORD}" -X PUT -v -T {} https://${TARGET_HOST}/repository/${REPO}//{} ;
# Clean up temp directory
rm -rf ./*
exit 0
