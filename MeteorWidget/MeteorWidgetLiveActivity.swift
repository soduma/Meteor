//
//  MeteorWidgetLiveActivity.swift
//  MeteorWidget
//
//  Created by 장기화 on 2023/08/11.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MeteorWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var liveText: String
        var liveColor: Int
        var hideContentOnLockScreen: Bool
    }
    
    // Fixed non-changing properties about your activity go here!
    var value: String
}

struct MeteorWidgetLiveActivity: Widget {
    let logo = "meteor_logo"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MeteorWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            switch context.state.liveColor {
            case 0:
                LockScreenView(context: context)
                    .activityBackgroundTint(.red)
            case 1:
                LockScreenView(context: context)
                    .activityBackgroundTint(.black)
            default:
                LockScreenView(context: context)
                    .activityBackgroundTint(.clear)
            }
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    HStack(alignment: .center, spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32, alignment: .center)
                            Image(logo)
                        }
                        Text("Meteor")
                            .fontWeight(.black)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.liveText)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.42)
                }
            } compactLeading: {
                Image(logo)
            } compactTrailing: {
                Text("On")
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            } minimal: {
                Image(logo)
            }
        }
    }
}

struct LockScreenView: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    let logo = "meteor_logo"
    
    let context: ActivityViewContext<MeteorWidgetAttributes>
    
    var body: some View {
        if context.state.hideContentOnLockScreen {
            if isLuminanceReduced {
                setLayout(showContent: false)
            } else {
                setLayout(showContent: true)
            }
        } else {
            setLayout(showContent: true)
        }
    }
    
    @ViewBuilder func setLayout(showContent: Bool) -> some View {
        VStack {
            HStack(alignment: .center, spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32, alignment: .leading)
                    Image(logo)
                }
                Text("Meteor")
                    .fontWeight(.black)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.leading)
            
            if showContent {
                Text(context.state.liveText)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.42)
                    .padding([.leading, .trailing])
            } else {
                Text(context.state.liveText)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.42)
                    .padding([.leading, .trailing])
                    .blur(radius: 8)
            }
        }
        .padding(.top)
        .padding(.bottom)
    }
}

struct MeteorWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = MeteorWidgetAttributes(value: "Me")
    static let contentState = MeteorWidgetAttributes.ContentState(liveText: "555", liveColor: 0, hideContentOnLockScreen: true)
    
    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
