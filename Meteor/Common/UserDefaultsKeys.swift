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
    
//    class var lockScreenStateKey: String {
//        return "LockScreenState"
//    }
    
    class var liveContentHideStateKey: String {
        return "LiveContentHideState"
    }
    
    class var liveColorKey: String {
        return "LiveColor"
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
//    class var liveIdlingKey: String {
//        return "LiveIdling"
//    }
    
    /// 마지막으로 입력된 live의 메세지 (설정의 잠금화면 스위치를 변경할 때 사용)
    class var liveTextKey: String {
        return "LiveText"
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
    
    /// Firebase 확인용
    class var getNewImageTappedCountKey: String {
        return "GetNewImageTappedCount"
    }
    
    /// 리뷰한 버전
    class var lastVersionKey: String {
        return "LastVersion"
    }
    
// MARK: - LIVE ACTIVITY
    
    class var alwaysOnLiveStateKey: String {
        return "AlwaysOnLiveState"
    }
    
    /// alert deviceToken
    class var apnsDeviceTokenKey: String {
        return "ApnsDeviceToken"
    }
    
    /// liveactivity deviceToken
    class var liveDeviceTokenKey: String {
        return "LiveDeviceToken"
    }
    
    /// jwt valid 확인용
    class var requestedDateKey: String {
        return "RequestedDate"
    }
    
    /// jwt, authentication
    class var JWTokenKey: String {
        return "JWToken"
    }
    
    class var minimizeDynamicIslandStateKey: String {
        return "MinimizeDynamicIslandState"
    }
    
    class var liveBackgroundUpdateStateKey: String {
        return "LiveBackgroundUpdateState"
    }
}
