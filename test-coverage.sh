#!/bin/bash

coverage run --omit=tests --source utils utils/nc_to_mmd.py
coverage report

if [[ -n "$COVERALLS_REPO_TOKEN" ]]; tnen
  coveralls
else
  echo **
  echo ** If you want code coverage generted on https://coveralls.io with GitHub Actions.
  echo ** 1. Add repository to coveralls.io.
  echo ** 2. Add token from coveralls.io as a secret named COVERALLS_REPO_TOKEN.
  echo **
fi
