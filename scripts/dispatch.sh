function create_dispatch() {

  curl -s -X POST $GITHUB_API_URL/repos/Anusha-Kolli/test-dispatch/actions/workflows/$GITHUB_RUNNNER_ID/dispatches \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -d @- << EOF
    {
       "ref":"develop",
       "event_type": "build_application"
    }    
EOF
    
}