#!/bin/bash

set -e

echo TRAVIS_BRANCH: $TRAVIS_BRANCH
echo TRAVIS_PULL_REQUEST: $TRAVIS_PULL_REQUEST
echo TRAVIS: $TRAVIS

if [[ $TRAVIS = "true" ]]; then
	if [[ $TRAVIS_BRANCH != "master" || $TRAVIS_PULL_REQUEST != "false" ]]; then
		# Bail out if Travis is building a branch or is building a Pull Request.
		echo "Not deploying!"
		exit 0
	fi

	echo "...A"
	# Set up credentials for pushing to GitHub.  $GH_TOKEN is configured via Travis web UI.
	git config credential.helper "store --file=.git/credentials"
	echo "...B"
	echo "https://inglesp:$GH_TOKEN@github.com" > .git/credentials

	# Set up config for committing.
	echo "...C"
	git config user.name "Travis"
	echo "...D"
	git config user.email "no-reply@pyconuk.org"
	echo "...E"
fi

echo "Deploying!"

# Remove output directory and replace it with the current tip of the gh-pages branch.
rm -rf output
echo "...F"
git clone https://github.com/inglesp/deploy-test-3 --branch gh-pages --single-branch output
echo "...G"

# Update the output directory with recent changes.
wok
echo "...H"

# Add and commit any changes.
pushd output
echo "...I"
git add .
echo "...J"
git commit -m "[skip ci]  Auto-commit.  Built latest changes"
echo "...K"

if [[ $TRAVIS = "true" ]]; then
	# Push to GitHub.
	git push https://inglesp@github.com/inglesp/deploy-test-3 gh-pages
	echo "...L"
else
	# Push to GitHub.
	git push
	echo "...M"
fi

# Clean up.
rm -rf .git
echo "...N"
popd
echo "...O"
