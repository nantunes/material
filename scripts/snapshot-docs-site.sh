#!/bin/bash

ARG_DEFS=(
  "--version=(.*)"
)

function run {
  cd ../

  echo "-- Building docs site release..."
  rm -rf dist
  gulp docs --release

  echo "-- Cloning code.material.angularjs.org..."
  rm -rf code.material.angularjs.org
  git clone https://angular:$GH_TOKEN@github.com/angular/code.material.angularjs.org.git --depth=1

  echo "-- Remove previous snapshot..."
  rm -rf code.material.angularjs.org/HEAD

  echo "-- Copying docs site to snapshot..."
  cp -Rf dist/docs code.material.angularjs.org/HEAD

  cd code.material.angularjs.org

  echo "-- Commiting snapshot..."
  git add -A
  git commit -m "snapshot: $VERSION"

  echo "-- Pushing snapshot..."
  git push -q origin master

  # See https://johnheroy.com/2014/10/17/continuous-firebase-deployment-with-travis.html
  echo "-- Deploying to firebase"
  # Only make tmp dir if running on travis-ci
  if [ -d /home/travis ]; then
    mkdir -p /home/travis/tmp
  fi
  sudo $(which npm) install -g firebase-tools
  echo -e "${FIREBASE_EMAIL}\n${FIREBASE_PASSWORD}" | firebase deploy

  cd ../

  echo "-- Cleanup..."
  rm -rf code.material.angularjs.org

  echo "-- Successfully pushed the snapshot to angular/code.material.angularjs.org!!"
}

source $(dirname $0)/utils.inc
