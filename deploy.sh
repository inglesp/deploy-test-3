#!/bin/bash

set -e

echo TRAVIS_BRANCH: $TRAVIS_BRANCH
echo TRAVIS_PULL_REQUEST: $TRAVIS_PULL_REQUEST

if [[ $TRAVIS = "true" && $TRAVIS_BRANCH != "master" ]]; then
	# Bail out if Travis is not building master.  This happens when Travis
	# is building a Pull Request.
	echo "Not deploying!"
	exit 0
fi

echo "Deploying!"

# Remove output directory and replace it with the current tip of the gh-pages
# branch.
rm -rf output
git clone https://github.com/inglesp/deploy-test-3.org --branch gh-pages --single-branch output

# Update the output directory with recent changes.
make build

# Add and commit any changes.
pushd output
git add .
git commit -m "[skip ci]  Auto-commit.  Built latest changes"

if [[ $TRAVIS = "true" ]]; then
	# Set up credentials for pushing to GitHub.  $GH_TOKEN is configured
	# via Travis web UI.
	git config credential.helper "store --file=.git/credentials"
	echo "https://inglesp:$GH_TOKEN@github.com" > .git/credentials

	# Set up config for committing.
	git config user.name "Travis"
	git config user.email "no-reply@pyconuk.org"

	# Push to GitHub.
	git push https://inglesp@github.com/inglesp/deploy-test-3.org gh-pages
else
	# Push to GitHub.
	git push
fi

# Clean up.
rm -rf .git
popd
