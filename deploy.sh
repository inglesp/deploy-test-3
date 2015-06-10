#!/bin/bash

if [[ $TRAVIS = "true" ]]; then
	if [[ $TRAVIS_BRANCH = "master" && $TRAVIS_PULL_REQUEST = "false" ]]; then
		echo "Deploying!"

		# Set up credentials for pushing to GitHub.  $GH_TOKEN is
		# configured via Travis web UI.
		git config credential.helper "store --file=.git/credentials"
		echo "https://inglesp:$GH_TOKEN@github.com" > .git/credentials
		git config user.name "Travis"
		git config user.email "travis@travis-ci.org"

		# Add, commit, and push any changes to the output directory
		# introduced by this change.  The output directory will have
		# been updated if required when pre-flight-checks.sh ran.  If
		# the output directory is already up to date then no new commit
		# will be made.
		echo "Last log:"
		git log -n 1 --parents

		echo "Checking out master"
		git checkout master

		echo "Last log:"
		git log -n 1 --parents

		echo "Committing"
		git commit -a -m "[skip ci] Travis auto-commit.  Built latest changes."

		echo "Last log"
		git log -n 1 --parents

		echo "Pushing"
		git push https://inglesp@github.com/inglesp/deploy-test-2 master

		# Push output directory to gh-pages branch on GitHub.
		git subtree push --prefix output https://inglesp@github.com/inglesp/deploy-test-2 gh-pages

		# Clean up.
		rm .git/credentials
	else
		echo "Not deploying!"
	fi
else
	git subtree push --prefix output origin gh-pages
fi
