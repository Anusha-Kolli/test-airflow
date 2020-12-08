#!/bin/bash

export current_tag=$(git tag --list --merged HEAD --sort=-committerdate | grep -E '^v?[0-9]+.[0-9]+.[0-9]+$' | head -n1 | sed 's/^v//')

export new_tag=$(cat CHANGELOG.md | awk  -v tag='"$current_tag"' '/Unreleased/ {p=1;next}; /'"$current_tag"'/ {p=0} p' | grep -E "^## " | sed 's/.*\[\([^]]*\)\].*/\1/g')

export imageName="test/testImage"
export registry="anusha972/test" 

function create_release() {
    local current_commit remote repo body new_version

    current_commit=$(git rev-parse HEAD)
    remote=$(git config --get remote.origin.url)
    repo=$(basename $remote .git)
    export body=$(cat CHANGELOG.md | sed -n '/'"$new_tag"'/,/'"$current_tag"'/ {/'"$new_tag"'/!{/'"$current_tag"'/!p;};}' | awk '$1=$1' ORS='\\n' )
    new_version="v$new_tag"

    echo "new_version"

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

anusha972/test:tagname

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
  check_changelog
}

main


