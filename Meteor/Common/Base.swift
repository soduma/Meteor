//
//  Base.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/05.
//

import Foundation

// MARK: - for UserDefaults Key
let initialLaunchKey = "InitialLaunch"
let lightStateKey = "LightState"
let darkStateKey = "DarkState"
let hapticStateKey = "VibrateState"
let lockScreenStateKey = "LockScreenState"

let singleIndexKey = "SingleIndex" // single의 identifier 분리용
let endlessIdlingKey = "EndlessIdling" // endless 활성화 확인
let endlessDurationKey = "EndlessDuration"
let endlessTriggeredDateKey = "EndlessTriggeredDate"
let liveIdlingKey = "LiveIdling" // live 활성화 확인
let liveTextKey = "LiveText" // 마지막으로 입력된 live의 메세지 (설정의 잠금화면 스위치를 변경할 때 사용)
let meteorSentCountKey = "meteorSentCount" // 앱 리뷰 화면 표현용
//let savedAdIndexKey = "SavedAdIndex"

let widgetDataKey = "WidgetDataKey" // 위젯용 이미지 데이터
let systemAppReviewCountKey = "SystemAppReviewCount"
let customAppReviewCountKey = "CustomAppReviewCount"
let getNewImageTappedCountKey = "GetNewImageTappedCount" // 앱 리뷰 화면 표현용
let lastVersionKey = "LastVersion" // 앱 리뷰 화면 표현용

// MARK: - for FirebaseDatabase Key
//let adIndex = "adIndex"
let shortText = "shortText"
let longText = "longText"
let unsplash = "a_unsplash"
