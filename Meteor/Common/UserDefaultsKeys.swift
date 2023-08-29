//
//  UserDefaultsKeys.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/29.
//

class UserDefaultsKeys {
    class var initialLaunchKey: String {
        return "InitialLaunch"
    }
    
    class var lightStateKey: String {
        return "LightState"
    }
    
    class var darkStateKey: String {
        return "DarkState"
    }
    
    class var hapticStateKey: String {
        return "HapticState"
    }
    
    class var lockScreenStateKey: String {
        return "LockScreenState"
    }
    
    /// single의 identifier 분리용
    class var singleIndexKey: String {
        return "SingleIndex"
    }
    
    /// endless 활성화 확인
    class var endlessIdlingKey: String {
        return "EndlessIdling"
    }
    
    /// 앱 재시작시 endless timer용
    class var endlessDurationKey: String {
        return "EndlessDuration"
    }
    
    /// 앱 재시작시 endless timer용
    class var endlessTriggeredDateKey: String {
        return "EndlessTriggeredDate"
    }
    
    /// live 활성화 확인
    class var liveIdlingKey: String {
        return "LiveIdling"
    }
    
    /// 마지막으로 입력된 live의 메세지 (설정의 잠금화면 스위치를 변경할 때 사용)
    class var liveTextKey: String {
        return "LiveText"
    }
    
    /// 앱 리뷰 화면 표현용
    class var meteorSentCountKey: String {
        return "meteorSentCount"
    }
    
    /// 위젯용 이미지 데이터
    class var widgetDataKey: String {
        return "WidgetDataKey"
    }
    
    class var systemAppReviewCountKey: String {
        return "SystemAppReviewCount"
    }
    
    class var customAppReviewCountKey: String {
        return "CustomAppReviewCount"
    }
    
    /// 앱 리뷰 화면 표현용
    class var getNewImageTappedCountKey: String {
        return "GetNewImageTappedCount"
    }
    
    /// 앱 리뷰 화면 표현용
    class var lastVersionKey: String {
        return "LastVersion"
    }
}
