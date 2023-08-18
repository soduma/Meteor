//
//  MeteorWidgetBundle.swift
//  MeteorWidget
//
//  Created by 장기화 on 2023/08/11.
//

import WidgetKit
import SwiftUI

@main
struct MeteorWidgetBundle: WidgetBundle {
    var body: some Widget {
        MeteorWidget()
        MeteorWidgetLiveActivity()
    }
}
