//
//  MeteorWidgetLiveActivity.swift
//  MeteorWidget
//
//  Created by 장기화 on 2023/08/11.
//

import SwiftUI
import WidgetKit
import ActivityKit

fileprivate let logo = "meteor_logo"

struct MeteorWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var liveText: String
        var liveColor: Int
        var hideContentOnLockScreen: Bool
        var triggerDate: Date
    }
    
    // Fixed non-changing properties about your activity go here!
    var value: String
}

struct MeteorWidgetLiveActivity: Widget {
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
            let date = context.state.triggerDate
            let twelveHours: TimeInterval = 12 * 60 * 60
            let workoutDateRange = date...date.addingTimeInterval(twelveHours)
            
            return DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    setLeadingLayout()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 8) {
                        Spacer()
                        
                        Text(Date(timeIntervalSinceNow: date.timeIntervalSince1970 + twelveHours) - date.timeIntervalSince1970, style: .relative)
                            .font(.system(size: 12, weight: .medium))
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.trailing)
                        
                        ProgressView(timerInterval: workoutDateRange) {
                        } currentValueLabel: {
                        }
                        .progressViewStyle(.circular)
                        .frame(width: 30, height: 30)
                        .tint(.white)
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
                ProgressView(timerInterval: workoutDateRange) {
                } currentValueLabel: {
                }
                .progressViewStyle(.circular)
                .tint(.white)
            } minimal: {
                Image(logo)
            }
        }
    }
}

struct LockScreenView: View {
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    let context: ActivityViewContext<MeteorWidgetAttributes>
    
    var body: some View {
        if context.state.hideContentOnLockScreen {
            if isLuminanceReduced {
                setLayout(context, hideContent: true)
            } else {
                setLayout(context, hideContent: false)
            }
        } else {
            setLayout(context, hideContent: false)
        }
    }
}

@ViewBuilder fileprivate func setLayout(_ context: ActivityViewContext<MeteorWidgetAttributes>, hideContent: Bool) -> some View {
    VStack {
        setLeadingLayout()
            .padding(.leading)
        
        Text(context.state.liveText)
            .font(.system(size: 32, weight: .semibold))
            .foregroundColor(.white)
            .minimumScaleFactor(0.42)
            .padding([.leading, .trailing])
            .blur(radius: hideContent ? 8 : 0)
    }
    .padding([.top, .bottom])
}

@ViewBuilder fileprivate func setLeadingLayout() -> some View {
    HStack(alignment: .center, spacing: 8) {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 30, height: 30, alignment: .center)
            Image(logo)
                .resizable()
                .frame(width: 22, height: 22)
        }
        
        Text("Meteor")
            .foregroundColor(.white)
            .fontWeight(.medium)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
        
        Spacer()
    }
}

struct MeteorWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = MeteorWidgetAttributes(value: "Me")
    static let contentState = MeteorWidgetAttributes.ContentState(liveText: "555", liveColor: 0, hideContentOnLockScreen: true, triggerDate: Date())
    
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
