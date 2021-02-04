function docker_devPush() {
   local dev_registry

   dev_registry=$1

   docker login -u $2 -p $3
   docker tag ${imageName}:${new_tag} ${1}/${imageName}:${new_tag}
   docker push ${1}/${imageName}:${new_tag}
}

function decode_secrets() {

   registry_decoded=$(echo "$1" | openssl enc -d -base64)
   user_decoded=$(echo "$2" | openssl enc -d -base64)
   password_decoded=$(echo "$3" | openssl enc -d -base64)
}


function common_functions() {
    local imageName prod_registry

    if [ "$is_prerelease" = "true" ]; then
    prerelease="true"; 
    else
    prerelease="false"; 
    fi


    # API request to create a Release
    curl -s -X POST $GITHUB_API_URL/repos/$GITHUB_REPOSITORY/releases \
    -H "Authorization: token $GITHUB_TOKEN" \
    -d @- << EOF
    {
       "tag_name": "$new_version",
       "target_commitish": "${GITHUB_REF##*/}",
       "name": "$new_version",
       "body": "$body",
       "draft": false,
       "prerelease": $is_prerelease
    }    
EOF
    
    imageName="test"
    
    docker build -t ${imageName}:${new_tag} .

    if [[ "${GITHUB_REF##*/}" == "master" ]]; then 
    decode_secrets ${REGISTRY} ${USER} ${PASSWORD}
    docker_devPush ${registry_decoded}  ${user_decoded}  ${password_decoded}
    else
    docker_prodPush
    echo "######################## This is a develop branch #########################" 
    fi
    
}

