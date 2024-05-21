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
        var isContentHide: Bool
        var isMinimize: Bool
        var isAlwaysOnLive: Bool
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
            case 2:
                LockScreenView(context: context)
                    .activityBackgroundTint(.clear)
            default:
                LockScreenView(context: context)
                    .activityBackgroundTint(.purple)
            }
        } dynamicIsland: { context in
            let state = context.state
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
                DynamicIslandExpandedRegion(.center) {
                    if state.liveText.isEmpty {
                        VStack {
                            Spacer(minLength: 4)
                            
                            ZStack {
                                Rectangle()
                                    .frame(width: 128, height: 34)
                                    .foregroundStyle(.black)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.gray, lineWidth: 1.5)
                                    )
                                Image(systemName: "arrow.left.arrow.right")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.white)
                            }
                        }
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if state.liveText.isEmpty {
                        VStack {
                            Spacer(minLength: 8)
                            
                            Text("Swiping Dynamic Island from side to side can hide it or make it reappear.")
                                .font(.system(size: 12, weight: .medium))
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        Text(context.state.liveText)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.35)
                    }
                }
            } compactLeading: {
                if !state.isAlwaysOnLive || !state.isMinimize {
                    Image(logo)
                        .grayscale(state.liveText.isEmpty ? 1 : 0)
                }
            } compactTrailing: {
                if !state.isAlwaysOnLive || !state.isMinimize {
                    ProgressView(timerInterval: workoutDateRange) {
                    } currentValueLabel: { }
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            } minimal: {
                if state.isAlwaysOnLive && state.isMinimize {
                    Image(systemName: "arrow.left.arrow.right")
                        .opacity(0.2)
                } else {
                    Image(logo)
                        .grayscale(state.liveText.isEmpty ? 1 : 0)
                }
            }
        }
    }
}

struct LockScreenView: View {
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    let context: ActivityViewContext<MeteorAttributes>
    
    var body: some View {
        if context.state.isContentHide {
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
                .minimumScaleFactor(0.39)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing])
                .blur(radius: needHide ? 8 : 0)
        }
    }
    .padding([.top, .bottom])
}

@ViewBuilder fileprivate func setLeadingLayout(_ context: ActivityViewContext<MeteorAttributes>) -> some View {
    let liveText = context.state.liveText
    
    HStack(alignment: .center, spacing: 8) {
        Image(logo)
            .resizable()
            .frame(width: 20, height: 20)
            .grayscale(liveText.isEmpty ? 1 : 0)
        
        Text("Meteor")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .kerning(-0.1)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .opacity(liveText.isEmpty ? 0.5 : 0.9)
        
        Spacer()
    }
}
#endif
