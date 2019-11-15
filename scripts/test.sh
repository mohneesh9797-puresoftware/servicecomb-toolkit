#!/usr/bin/env bash
## ---------------------------------------------------------------------------
## Licensed to the Apache Software Foundation (ASF) under one or more
## contributor license agreements.  See the NOTICE file distributed with
## this work for additional information regarding copyright ownership.
## The ASF licenses this file to You under the Apache License, Version 2.0
## (the "License"); you may not use this file except in compliance with
## the License.  You may obtain a copy of the License at
##
##      http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ---------------------------------------------------------------------------
#bin/sh

##Check if the commit is tagged commit or not
TAGGEDCOMMIT=$(git tag -l --contains HEAD)
if [ "$TAGGEDCOMMIT" == "" ]; then
    TAGGEDCOMMIT=false
else
    TAGGEDCOMMIT=true
fi
echo "TAGGEDCOMMIT=$TAGGEDCOMMIT"

if [ "$TAGGEDCOMMIT" == "true" ]; then
	echo "Skipping the installation as it is tagged commit"
else
	mvn apache-rat:check
	if [ $? != 0 ]; then
		echo "${red}Rat check failed.${reset}"
		exit 1
	fi
	
	echo "Running the unit tests and integration tests here!"
  echo "TRAVIS_PULL_REQUEST=$TRAVIS_PULL_REQUEST"
  if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    echo "Not a pull request build, running build with sonar"
    mvn clean install -Pjacoco coveralls:report sonar:sonar -Dsonar.projectKey=servicecomb-toolkit
  else
    echo "Pull request build or local build"
    mvn clean install -Pjacoco coveralls:report
  fi;
	
  if [ $? == 0 ]; then
    echo "${green}Installation Success..${reset}"
  else
    echo "${red}Installation or Test Cases failed, please check the above logs for more details.${reset}"
    exit 1
  fi
fi