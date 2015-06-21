#!/bin/bash

set -e

if [[ $TRAVIS = "true" ]]; then
	if [[ $TRAVIS_BRANCH != "master" || $TRAVIS_PULL_REQUEST != "false" ]]; then
		# Bail out if Travis is building a branch or is building a Pull Request.
		echo "Not deploying!"
		exit 0
	fi
fi

echo "Deploying!"

# Remove output directory and replace it with the current tip of the gh-pages branch.
rm -rf output
git clone https://github.com/inglesp/deploy-test-3 --branch gh-pages --single-branch output

# Update the output directory with recent changes.
wok

cd output

if [[ $TRAVIS = "true" ]]; then
	# Set up credentials for pushing to GitHub.  $GH_TOKEN is configured via Travis web UI.
	git config credential.helper "store --file=.git/credentials"
	echo "https://inglesp:$GH_TOKEN@github.com" > .git/credentials

	# Set up config for committing.
	git config user.name "Travis"
	git config user.email "no-reply@pyconuk.org"
fi

# Add and commit any changes.
git add .
git commit -m "[skip ci]  Auto-commit.  Built latest changes."

if [[ $TRAVIS = "true" ]]; then
	# Push to GitHub.
	git push https://inglesp@github.com/inglesp/deploy-test-3 gh-pages
else
	# Push to GitHub.
	git push
fi

# Clean up.
rm -rf .git
cd ..
