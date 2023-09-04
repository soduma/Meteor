#!/bin/sh

#  ci_post_clone.sh
#  Meteor
#
#  Created by 장기화 on 2023/09/03.
#  

# Update brew and install SwiftLint and Danger-swift
#brew update
# Install CocoaPods using Homebrew.
brew install cocoapods

# Install dependencies you manage with CocoaPods.
pod install
