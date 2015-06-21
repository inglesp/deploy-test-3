#!/bin/bash

set -e

if [[ $TRAVIS = "true" ]]; then
	if [[ $TRAVIS_BRANCH != "master" || $TRAVIS_PULL_REQUEST != "false" ]]; then
		# Bail out if Travis is building a branch or is building a Pull Request.
		echo "Not deploying!"
		exit 0
	fi

	# Set up credentials for pushing to GitHub.  $GH_TOKEN is configured via Travis web UI.
	git config --global credential.helper "store --file=$TRAVIS_BUILD_DIR/git-credentials"
	echo "https://inglesp:$GH_TOKEN@github.com" > $TRAVIS_BUILD_DIR/git-credentials

	# Set up config for committing.
	git config --global user.name "Travis"
	git config --global user.email "no-reply@pyconuk.org"
fi

echo "Deploying!"

# Remove output directory and replace it with the current tip of the gh-pages branch.
rm -rf output
git clone https://github.com/inglesp/deploy-test-3 --branch gh-pages --single-branch output

# Update the output directory with recent changes.
wok

# Add and commit any changes.
cd output
git add .
git commit -m "[skip ci]  Auto-commit.  Built latest changes."

# Push to GitHub.
git push https://inglesp@github.com/inglesp/deploy-test-3 gh-pages

# Clean up.
rm -rf .git
