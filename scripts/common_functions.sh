function dockerImage_BuildandPush() {
    local imageName prod_registry
    
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

