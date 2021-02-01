#!/bin/bash

set -e 

source ./scripts/common_functions.sh

function create_release() {
    local current_tag new_tag body new_version 

    current_tag=$(git tag --list --merged HEAD --sort=-committerdate | grep -E '^v?[0-9]+.[0-9]+.[0-9]+$' | head -n1 | sed 's/^v//')

    # Get the recent commit
    new_tag=$(cat CHANGELOG.md | awk  -v tag='"$current_tag"' '/Unreleased/ {p=1;next}; /'"$current_tag"'/ {p=0} p' | grep -E "^## " | sed 's/.*\[\([^]]*\)\].*/\1/g')


    body=$(cat CHANGELOG.md | sed -n '/'"$new_tag"'/,/'"$current_tag"'/ {/'"$new_tag"'/!{/'"$current_tag"'/!p;};}' | awk '$1=$1' ORS='\\n' )
    new_version="v$new_tag"
    is_prerelease=echo true


    common_functions

}


function check_changelog() {
    changelog_commit=$(git log v$current_tag..HEAD --oneline CHANGELOG.md)
    if [[ -z "$changelog_commit" ]]; then
    echo "CHANGELOG.md is not updated"
    else
    create_release
    fi
}

# function dockerImage_BuildandPush() {
#     local imageName prod_registry
    
#     imageName="test"
#     prod_registry="anusha972" 
    
#     docker build -t ${imageName}:${new_tag} .

#     if [[ "${GITHUB_REF##*/}" == "master" ]]; then
#     #pushing to PROD acr
#     docker login -u ${USER} -p ${PASSWORD}
#     docker tag ${imageName}:${new_tag} ${prod_registry}/${imageName}:${new_tag}
#     docker push ${prod_registry}/${imageName}:${new_tag}
#     else
#     echo "######################## This is a develop branch #########################"
#     fi
    
# }

function main() {
  create_release

}

main

