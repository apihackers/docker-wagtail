#!/usr/bin/env bash

# Create a self signed certificate
base_branch() {
    # Get the base branch against which a PR has been made
    # Extracted from https://discuss.circleci.com/t/how-to-get-the-pull-request-upstream-branch/5496/3
    # Until https://discuss.circleci.com/t/expose-the-title-and-upstream-branch-of-a-pull-request-build-as-an-env/5475/1
    # is implemented

    # Set a default in case we run into rate limit restrictions
    BASE_BRANCH="master"
    if [[ $CIRCLE_PR_NUMBER ]]; then
      BASE_BRANCH=$(curl -fsSL https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/$CIRCLE_PR_NUMBER | jq -r '.base.ref')
    elif [[ $CIRCLE_TAG ]]; then
      BASE_BRANCH='master'
    elif [[ $CIRCLE_BRANCH ]]; then
      BASE_BRANCH=$CIRCLE_BRANCH
    fi
    echo $BASE_BRANCH
}

# Upload dist whell to github release matching current tag
gh_release() {
    path=$(set -- dist/*.whl; echo "$1")
    filename=$(basename $path)
    RELEASE_URL="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/releases/tags/$CIRCLE_TAG"
    RELEASE_DATA=$(curl -fsSL $RELEASE_URL)
    RELEASE_PAGE_URL=$(jq -r '.html_url' <<< $RELEASE_DATA)
    UPLOAD_URL=$(jq -r '.upload_url' <<< $RELEASE_DATA)
    UPLOAD_URL="$(sed 's/{.*}/?name=/' <<< $UPLOAD_URL)$filename"
    curl --request POST \
    --data-binary @$path \
    --header "Authorization: token $GITHUB_OAUTH_TOKEN" \
    --header "Content-Type: application/zip" \
    $UPLOAD_URL
    echo "Wheel upload to release $RELEASE_PAGE_URL"
}
