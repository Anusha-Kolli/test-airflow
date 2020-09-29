#!/bin/bash

current_tag=$(git tag --list --merged HEAD --sort=-committerdate | grep -E '^v?[0-9]+.[0-9]+.[0-9]+$' | head -n1)

current_commit=$(git rev-parse HEAD)

new_tag="$(awk  -v tag='"$current_tag"' '/Unreleased/ {p=1;next}; /'"$current_tag"'/ {p=0} p' CHANGELOG.md | grep -E "^## " | awk -F '[\\[\\]]' '{print $2}')"

remote=$(git config --get remote.origin.url)
repo=$(basename $remote .git)
body="$(sed -n '/'"$new_tag"'/,/'"$current_tag"'/ {/'"$new_tag"'/!{/'"$current_tag"'/!p;};}' CHANGELOG.md)"


curl -s -X POST https://api.github.com/repos/Anusha-Kolli/$repo/releases \
-H "Authorization: token $GITHUB_TOKEN" \
-d @- << EOF
{
    "tag_name": "$new_tag",
    "target_commitish": "master",
    "name": "$new_tag",
    "body": "$($body)",
    "draft": false,
    "prerelease": false
}    
EOF

