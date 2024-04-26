//
//  MeteorActivityConfiguration.swift
//  MeteorWidget
//
//  Created by 장기화 on 2023/08/11.
//

#if canImport(ActivityKit)
import SwiftUI
import WidgetKit
import ActivityKit

fileprivate let logo = "meteor_logo"

struct MeteorAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var liveText: String
        var liveColor: Int
        var hideContentOnLockScreen: Bool
    }
    
    // Fixed non-changing properties about your activity go here!
//    var value: String
}

struct MeteorActivityConfiguration: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MeteorAttributes.self) { context in
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
            let liveText = context.state.liveText
            let date = Date()
            let twelveHours: TimeInterval = 12 * 60 * 60
            let workoutDateRange = date...date + twelveHours
            
            return DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    setLeadingLayout(context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 8) {
                        Spacer()
                        
                        Text(Date(timeIntervalSinceNow: twelveHours), style: .relative)
                            .font(.system(size: 12, weight: .medium))
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.trailing)
                        
                        ProgressView(timerInterval: workoutDateRange) {
                        } currentValueLabel: { }
                        .progressViewStyle(.circular)
                        .frame(width: 30, height: 30)
                        .tint(.white)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if liveText.isEmpty {
                        Image(systemName: "arrow.left.arrow.right")
                        
                    } else {
                        Text(context.state.liveText)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.35)
                    }
                }
            } compactLeading: {
                Image(logo)
                    .grayscale(liveText.isEmpty ? 1 : 0)
            } compactTrailing: {
                ProgressView(timerInterval: workoutDateRange) {
                } currentValueLabel: { 
//                    Image(systemName: "arrow.left.arrow.right")
//                        .foregroundStyle(.secondary)
                }
                .progressViewStyle(.circular)
                .tint(.white)
            } minimal: {
                Image(logo)
                    .grayscale(liveText.isEmpty ? 1 : 0)
            }
        }
    }
}

struct LockScreenView: View {
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    let context: ActivityViewContext<MeteorAttributes>
    
    var body: some View {
        if context.state.hideContentOnLockScreen {
            if isLuminanceReduced {
                setLayout(context, needHide: true)
            } else {
                setLayout(context, needHide: false)
            }
        } else {
            setLayout(context, needHide: false)
        }
    }
}

@ViewBuilder fileprivate func setLayout(_ context: ActivityViewContext<MeteorAttributes>, needHide: Bool) -> some View {
    let liveText = context.state.liveText
    
    VStack(spacing: 3) {
        setLeadingLayout(context)
            .padding(.leading)
        
        if !liveText.isEmpty {
            Text(liveText)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.42)
                .padding([.leading, .trailing])
                .blur(radius: needHide ? 8 : 0)
        }
    }
    .padding([.top, .bottom])
}

@ViewBuilder fileprivate func setLeadingLayout(_ context: ActivityViewContext<MeteorAttributes>) -> some View {
    let liveText = context.state.liveText
    
    HStack(alignment: .center, spacing: 8) {
        ZStack {
            Circle()
                .fill(liveText.isEmpty ? .clear : .white)
                .frame(width: 28, height: 28, alignment: .center)
            Image(logo)
                .resizable()
                .frame(width: 20, height: 20)
                .grayscale(liveText.isEmpty ? 1 : 0)
        }
        
        Text("Meteor")
            .foregroundColor(.white)
            .fontWeight(.medium)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .opacity(liveText.isEmpty ? 0.5 : 1)
        
        Spacer()
    }
}

//struct MeteorWidgetLiveActivity_Previews: PreviewProvider {
//    static let attributes = MeteorAttributes()
//    static let contentState = MeteorAttributes.ContentState(liveText: "555", liveColor: 0, hideContentOnLockScreen: true, triggerDate: Date())
//    
//    static var previews: some View {
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
//            .previewDisplayName("Island Compact")
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
//            .previewDisplayName("Island Expanded")
//        attributes
//            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
//            .previewDisplayName("Minimal")
//        attributes
//            .previewContext(contentState, viewKind: .content)
//            .previewDisplayName("Notification")
//    }
//}
#endif
