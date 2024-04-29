//
//  AlwaysViewController.swift
//  Meteor
//
//  Created by 장기화 on 4/18/24.
//

import SwiftUI
import ActivityKit

struct AlwaysOnLiveView: View {
    @AppStorage(UserDefaultsKeys.minimizeDynamicIslandStateKey)
    private var isMinimizeOn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.minimizeDynamicIslandStateKey)
    @AppStorage(UserDefaultsKeys.alwaysOnLiveStateKey)
    private var isAlwaysOn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey)
    @AppStorage(UserDefaultsKeys.liveBackgroundUpdateStateKey)
    private var isBackgroundOn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey)
    
    private let liveManager = LiveActivityManager.shared
    
    var body: some View {
        List {
            Section {
            } footer: {
                Text("‘Always On Live’ will continue to display only if it is available, even if there is no currently registered ‘Live’.")
            }
            
            Section {
            } footer: {
                Text("If 12 hours have passed since the last activity of the Meteor, it may no longer be displayed.")
            }
            
            if isAlwaysOn {
                Section {
                    Toggle("Minimize Dynamic Island", isOn: $isMinimizeOn)
                        .tint(.yellow)
                        .onChange(of: isMinimizeOn) { oldValue, newValue in
                            //
                        }
                    Toggle("Background Update (β)", isOn: $isBackgroundOn)
                        .tint(.orange)
                        .onChange(of: isBackgroundOn) { oldValue, newValue in
                            print(isBackgroundOn)
                            liveManager.rebootActivity()
                        }
                } header: {
                    Text("Customize")
                } footer: {
                    Text("Background Update is currently in beta.")
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
//                await liveManager.getPushToStartToken()
                //            print("🐶 token gettt")
            }
        })
    }
}

#Preview {
    AlwaysOnLiveView()
}
