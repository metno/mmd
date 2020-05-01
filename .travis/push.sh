#!/bin/sh

setup_git() {
    git config --global user.email $GIT_EMAIL
    git config --global user.name $GIT_NAME
}

commit_files() {
    # We work directly on master. Builds go to the doc-folder.
    git add doc/mmd-specification.html
    git add doc/mmd-specification.pdf
    #git commit -m "Auto-generated from ${TRAVIS_REPO_SLUG}@${TRAVIS_COMMIT}"
    git commit --message "Travis build: ${TRAVIS_BUILD_NUMBER}"
    echo hei
}

upload_files(){
    # OBS: this is a security risk - '/dev/null 2>&1' prevents leaking the token to the Travis logs...
    git push https://${GH_TOKEN}@github.com/mortenwh/mmd.git > /dev/null 2>&1
}

setup_git
commit_files
upload_files
