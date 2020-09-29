#!/bin/bash

new_tag=$1
current_tag=$2

current_commit=$(git rev-parse HEAD)

remote=$(git config --get remote.origin.url)
repo=$(basename $remote .git)
body=$(sed -n '/'"$new_tag"'/,/'"$current_tag"'/ {/'"$new_tag"'/!{/'"$current_tag"'/!p;};}' CHANGELOG.md)

new_version="v$new_tag"

curl -s -X POST https://api.github.com/repos/Anusha-Kolli/$repo/releases \
-H "Authorization: token $GITHUB_TOKEN" \
-d @- << EOF
{
    "tag_name": "$new_version",
    "target_commitish": "master",
    "name": "$new_version",
    "body": "$body",
    "draft": false,
    "prerelease": false
}    
EOF
