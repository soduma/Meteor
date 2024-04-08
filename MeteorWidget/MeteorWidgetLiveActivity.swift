//
//  MeteorWidgetLiveActivity.swift
//  MeteorWidget
//
//  Created by 장기화 on 2023/08/11.
//

import ActivityKit
import WidgetKit
import SwiftUI

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
                        
//                        if Int(twelveHours) % 2 == 0 {
//                            Text(Date(timeIntervalSinceNow: date.timeIntervalSince1970 + twelveHours) - date.timeIntervalSince1970, style: .relative)
//                            .font(.system(size: 12))
//                            .minimumScaleFactor(0.7)
//                            .multilineTextAlignment(.trailing)
//                            .foregroundStyle(.red)
//                        } else {
//                            Text(Date(timeIntervalSinceNow: date.timeIntervalSince1970 + twelveHours) - date.timeIntervalSince1970, style: .relative)
//                            .font(.system(size: 12))
//                            .minimumScaleFactor(0.7)
//                            .multilineTextAlignment(.trailing)
//                            .foregroundStyle(.white)
//                        }
                        Text(Date(timeIntervalSinceNow: date.timeIntervalSince1970 + twelveHours) - date.timeIntervalSince1970, style: .relative)
                            .font(.system(size: 12, weight: .medium))
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.trailing)
//                        .foregroundStyle(Int(twelveHours) % 2 == 1 ? .red : .white)
                        
                        ProgressView(timerInterval: workoutDateRange) {
//                            VStack {
//                                Spacer()
//                                Text(NSLocalizedString("Remain time", comment: ""))
//                                    .minimumScaleFactor(0.7)
//                            }
                        } currentValueLabel: {
//                            Spacer()
//                            Text(Date(timeIntervalSinceNow: Date().timeIntervalSince1970 + 12*60*60) - Date().timeIntervalSince1970, style: .relative)
//                            Spacer()
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
//                ProgressView(value: 12, total: 12) {
//                    Text("hi")
//                } currentValueLabel: {
//                    Text("12")
//                }
//                let workoutDateRange = Date()...Date().addingTimeInterval(1*60)
//                let hour = workout
//
//                let start = Date()
//                let end = start.addingTimeInterval(1*60)
//
                ProgressView(timerInterval: workoutDateRange) {
//                    Text("On")
                } currentValueLabel: {
//                    Text("On")
//                        .fontWeight(.bold)
//                        .foregroundColor(.red)
                }
                .progressViewStyle(.circular)
//                .tint(workoutDateRange.contains(Date().addingTimeInterval(5)) ? Color.red : Color.green)
                .tint(.white)
                
//                Text("On")
//                    .fontWeight(.bold)
//                    .foregroundColor(.red)
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
                setLayout(hideContent: true, context: context)
            } else {
                setLayout(hideContent: false, context: context)
            }
        } else {
            setLayout(hideContent: false, context: context)
        }
    }
}

@ViewBuilder fileprivate func setLayout(hideContent: Bool, context: ActivityViewContext<MeteorWidgetAttributes>) -> some View {
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
    .padding(.top)
    .padding(.bottom)
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
