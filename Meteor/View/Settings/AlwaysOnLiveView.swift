//
//  AlwaysViewController.swift
//  Meteor
//
//  Created by 장기화 on 4/18/24.
//

import SwiftUI
import ActivityKit

struct AlwaysOnLiveView: View {
    @AppStorage(UserDefaultsKeys.alwaysOnLiveKey)
    private var isOn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveKey)
    
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
            
            Section {
                HStack {
                    Toggle("Always On Live (β)", isOn: $isOn)
                        .tint(.yellow)
                }
            }
        }
        .listStyle(.insetGrouped)
        .contentMargins(.vertical, 19)
    }
}
