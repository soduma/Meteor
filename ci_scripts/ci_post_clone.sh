#!/bin/sh

#  ci_post_clone.sh
#  Meteor
#
#  Created by 장기화 on 2023/09/03.
#

echo "Stage: ci_post_clone is activated .... "

# for future reference
# https://developer.apple.com/documentation/xcode/environment-variable-reference

cd ../Meteor/Foundation

plutil -replace AUTHKEY_P8 -string $AUTHKEY_P8 $CI_WORKSPACE/$Meteor/Info.plist
plutil -replace TEAM_ID -string $TEAM_ID $CI_WORKSPACE/$Meteor/Info.plist
plutil -replace KEY_ID -string $KEY_ID $CI_WORKSPACE/$Meteor/Info.plist

plutil -p "$CI_WORKSPACE"/"$Meteor"/Info.plist

echo "Stage: ci_post_clone is DONE .... "

# Update brew and install SwiftLint and Danger-swift
#brew update
# Install CocoaPods using Homebrew.
brew install cocoapods

# Install dependencies you manage with CocoaPods.
pod install
