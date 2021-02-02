function docker_LoginandPush() {

   #docker login tagging and pushing the image
   docker login ${registry} -u ${DEV_USER} -p ${DEV_PASSWORD}
   docker tag ${imageName}:${new_tag} ${registry}/${imageName}:${new_tag}
   docker push ${registry}/${imageName}:${new_tag}

}

function docker_devPush() {
   local registry USER PASSWORD

   registry="anusha972"
   DEV_USER="${USER}"
   DEV_PASSWORD="${PASSWORD}"

   docker_LoginandPush
}

function docker_prodPush() {
   local registry USER PASSWORD

   registry="anusha972"
   DEV_PASSWORD="${USER}"
   DEV_PASSWORD="${PASSWORD}"

   docker_LoginandPush
}


function common_functions() {
    local imageName 

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
    docker_prodPush
    else
    docker_devPush
    echo "######################## This is a develop branch #########################" 
    fi
    
}

