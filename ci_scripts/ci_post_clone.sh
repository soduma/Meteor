#!/bin/sh

#  ci_post_clone.sh
#  Meteor
#
#  Created by 장기화 on 2023/09/03.
#

# 1. GOOGLE_SERVICE_INFO_PLIST 환경변수가 존재하는지 확인
if [ -n "$IDLIST_PLIST" ]; then
    echo "IDLIST_PLIST 환경변수가 발견되었습니다."
    
    # 환경변수 값을 IDList.plist 파일에 저장
    echo "$IDLIST_PLIST" > "$Meteor"/IDList.plist
    echo "IDList.plist 파일을 프로젝트 디렉토리 내에 생성하였습니다."
else
    echo "IDList.plist 환경변수가 존재하지 않습니다. 스크립트를 종료합니다."
fi

exit 0

# Update brew and install SwiftLint and Danger-swift
#brew update
# Install CocoaPods using Homebrew.
brew install cocoapods

# Install dependencies you manage with CocoaPods.
pod update
