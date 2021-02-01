function common_functions() {
    local imageName prod_registry


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
       "prerelease": "$is_prerelease"
    }    
EOF
    
    imageName="test"
    prod_registry="anusha972" 
    
    docker build -t ${imageName}:${new_tag} .

    if [[ "${GITHUB_REF##*/}" == "master" ]]; then

    #pushing to PROD acr
    docker login -u ${USER} -p ${PASSWORD}
    docker tag ${imageName}:${new_tag} ${prod_registry}/${imageName}:${new_tag}
    docker push ${prod_registry}/${imageName}:${new_tag}

    else

    echo "######################## This is a develop branch #########################"
    
    fi
    
}

