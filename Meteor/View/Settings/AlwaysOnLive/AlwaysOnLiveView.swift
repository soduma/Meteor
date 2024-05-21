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
    @AppStorage(UserDefaultsKeys.minimizeDynamicIslandStateKey)
    private var isMinimizeOn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.minimizeDynamicIslandStateKey)
    @AppStorage(UserDefaultsKeys.liveBackgroundUpdateStateKey)
    private var isBackgroundOn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey)
    
    private let liveManager = LiveActivityManager.shared
    
    var body: some View {
        List {
            Section {
            } footer: {
                Text("‘Always On Live’ will continue to display on the Lock Screen if available, even if there is no currently registered ‘Live’.")
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
                            liveManager.rebootActivity()
                        }
                    
                    Toggle("Restart Live in Background (β)", isOn: $isBackgroundOn)
                        .tint(.purple)
                        .disabled(!liveManager.isSupportVersion())
                        .onChange(of: isBackgroundOn) { oldValue, newValue in
                            liveManager.rebootActivity()
                        }
                } header: {
                    Text("Customize")
                } footer: {
                    Text("If the active Live terminates, it will start Live over the network. For example, if swipe to clear registered Live from the Lock Screen, a new Live will start.\n\nRestart Live in Background is currently in Beta.\nSupport iOS 17.2 and Later.")
                }
            }
            
            Section {
                Toggle("Always On Live", isOn: $isAlwaysOn)
                    .tint(.yellow)
                    .onChange(of: isAlwaysOn) { oldValue, newValue in
                        liveManager.rebootActivity()
                    }
            }
        }
        .listStyle(.insetGrouped)
        .contentMargins(.vertical, 19)
        .animation(.easeInOut, value: isAlwaysOn)
        .onAppear(perform: {
            liveManager.getPushToStartToken()
        })
    }
}

#Preview {
    AlwaysOnLiveView()
}
