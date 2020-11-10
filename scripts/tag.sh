#!/bin/bash

set -e

# Get the recent commit
export new_tag=$(git log --pretty=format:'%h' -n 1)

function create_pre_release() {
    local new_version

    new_version="develop-$new_tag-beta"

    # API request to create a Release
    curl -s -X POST https://api.github.com/repos/$REPO_OWNER/$repo/releases \
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
}


function main() {
  create_pre_release
}

main
