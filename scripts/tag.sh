#!/bin/bash

set -e 

# Get the recent commit
new_tag=$(git log --pretty=format:'%h' -n 1)

export imageName="test/testImage"
export registry="anusha972/test" 

function create_release() {
    local new_version


    new_version="develop-$new_tag-beta"

    # API request to create a Release
    curl -s -X POST $GITHUB_API_URL/repos/$GITHUB_REPOSITORY/releases \
    -H "Authorization: token $GITHUB_TOKEN" \
    -d @- << EOF
    {
       "tag_name": "$new_version",
       "target_commitish": "master",
       "name": "$new_version",
       "body": "This is a release",
       "draft": false,
       "prerelease": false
    }    
EOF
}


function dockerImage_BuildandPush() {
    docker build -t ${imageName}:${new_tag}
    docker login ${registry} -u ${user} -p ${password}
    docker tag ${imageName}:${new_tag} ${registry}/${imageName}:${new_tag}
    docker push ${registry}/${imageName}:${new_tag}
    # docker login ${dev_registry} -u ${user} -p ${password}
    # docker tag ${imageName}:${new_tag} ${dev_registry}/${imageName}:${new_tag}
    # docker push ${dev_registry}/${imageName}:${new_tag}

}


function check_changelog() {
    changelog_commit=$(git log v$current_tag..HEAD --oneline CHANGELOG.md)
    if [[ -z "$changelog_commit" ]]; then
    echo "CHANGELOG.md is not updated"
    else
    create_release
    dockerImage_BuildandPush
    fi
}

function main() {
  create_release
}

main

