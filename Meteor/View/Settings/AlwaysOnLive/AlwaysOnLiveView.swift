//
//  AlwaysViewController.swift
//  Meteor
//
//  Created by 장기화 on 4/18/24.
//

import SwiftUI
import ActivityKit

struct AlwaysOnLiveView: View {
    @AppStorage(UserDefaultsKeys.alwaysOnLiveStateKey)
    private var isAlwaysOn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey)
    @AppStorage(UserDefaultsKeys.liveBackgroundUpdateStateKey)
    private var isBackgroundOn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey)
    private let liveManager = LiveActivityManager.shared
    
    var body: some View {
        List {
            Section {
            } footer: {
                Text("'화면 상시표시'는 잠금 화면을 어둡게 하면서 최소한의 전력으로 시간, 위젯 및 알림과 같은 정보를 계속 표시합니다.")
            }
            
            Section {
            } footer: {
                Text("rame = (20 293.667; 350 350); clipsToBounds = YES; autoresize = W; layer = <CALayer: 0x12488d930>> and trailing of <UIVisualEffectV")
            }
            
            if isAlwaysOn {
                Section {
                    Toggle("Background Update (β)", isOn: $isBackgroundOn)
                        .tint(.orange)
                        .onChange(of: isBackgroundOn) { oldValue, newValue in
                            print(isBackgroundOn)
                            liveManager.rebootActivity()
                        }
                } header: {
                    Text("Customize")
                } footer: {
                    Text("beta")
                }
            }
            
            Section {
                Toggle("Always On Live", isOn: $isAlwaysOn)
                    .tint(.yellow)
                    .onChange(of: isAlwaysOn) { oldValue, newValue in
                        liveManager.rebootActivity()
//                        if newValue {
//                            if liveManager.isActivityAlive() == false {
//                                liveManager.startAlwaysActivity()
//                            }
////                            liveManager.betaStart()
//                        }
                        
//                        if newValue == false {
//                            Task {
//                                await liveManager.endAlwaysActivity()
//                            }
////                            liveManager.betaStop()
//                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
        .contentMargins(.vertical, 19)
        .animation(.easeInOut, value: isAlwaysOn)
        .onAppear(perform: {
            Task {
                await liveManager.getPushToStartToken()
                //            print("🐶 token gettt")
            }
        })
    }
}

#Preview {
    AlwaysOnLiveView()
}
