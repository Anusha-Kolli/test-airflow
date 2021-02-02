function docker_devPush() {
   local dev_registry

   dev_registry=$1

   docker login -u $2 -p $3
   docker tag ${imageName}:${new_tag} ${1}/${imageName}:${new_tag}
   docker push ${1}/${imageName}:${new_tag}
}

function docker_prodPush() {
   local prod_registry

   prod_registry="anusha972"

   docker login -u ${USER} -p ${PASSWORD}
   docker tag ${imageName}:${new_tag} ${prod_registry}/${imageName}:${new_tag}
   docker push ${prod_registry}/${imageName}:${new_tag}
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
    registry_decoded=$(echo "$REGISTRY" | openssl enc -d -base64)
    
    docker build -t ${imageName}:${new_tag} .

    if [[ "${GITHUB_REF##*/}" == "master" ]]; then 
    docker_devPush ${registry_decoded}  ${USER}  ${PASSWORD}
    else
    docker_prodPush
    echo "######################## This is a develop branch #########################" 
    fi
    
}

