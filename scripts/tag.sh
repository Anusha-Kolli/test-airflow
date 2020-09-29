#!/bin/bash
current_commit=$(git rev-parse HEAD)

remote=$(git config --get remote.origin.url)
repo=$(basename $remote .git)
body=$(cat CHANGELOG.md | sed -n '/'"$NEW_TAG"'/,/'"$CURRENT_TAG"'/ {/'"$NEW_TAG"'/!{/'"$CURRENT_TAG"'/!p;};}')

new_version="v$NEW_TAG"

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
