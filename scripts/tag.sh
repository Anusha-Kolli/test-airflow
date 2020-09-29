#!/bin/bash

export current_tag=$(git tag --list --merged HEAD --sort=-committerdate | grep -E '^v?[0-9]+.[0-9]+.[0-9]+$' | head -n1 | sed 's/^v//')

export new_tag=$(cat CHANGELOG.md | awk  -v tag='"$current_tag"' '/Unreleased/ {p=1;next}; /'"$current_tag"'/ {p=0} p' | grep -E "^## " | sed 's/.*\[\([^]]*\)\].*/\1/g')

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

function check_changelog() {
    changelog_commit=$(git log v$current_tag..HEAD --oneline CHANGELOG.md)
    if [-z "$changelog_commit"]; then
    echo "CHANGELOG.md is not updated"
    else
    create_release
    fi
}

function main() {
  check_changelog

}

main


