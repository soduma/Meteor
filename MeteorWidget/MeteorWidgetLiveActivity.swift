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
        var endlessText: String
        var lockscreen: Bool
    }

    // Fixed non-changing properties about your activity go here!
    var value: String
}

struct MeteorWidgetLiveActivity: Widget {
    let logo = "meteor_logo"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MeteorWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            LockScreenView(context: context)
                .activityBackgroundTint(.red)
//                .activitySystemActionForegroundColor(.black)
            
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
                    switch context.state.endlessText.count {
                    case ...15:
                        Text(context.state.endlessText)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
//                            .padding([.leading, .trailing])
                        
                    case 16...30:
                        Text(context.state.endlessText)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
//                            .padding([.leading, .trailing])
                        
                    default:
                        Text(context.state.endlessText)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
//                            .padding([.leading, .trailing])
                    }
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
        if context.state.lockscreen {
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
//        ZStack {
//            Color.red.opacity(0.8)
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
                
                switch context.state.endlessText.count {
                case ...15:
                    if showContent {
                        Text(context.state.endlessText)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                    } else {
                        Text(context.state.endlessText)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                            .blur(radius: 8)
                    }
                    
                case 16...30:
                    if showContent {
                        Text(context.state.endlessText)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                    } else {
                        Text(context.state.endlessText)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                            .blur(radius: 8)
                    }
                    
                default:
                    if showContent {
                        Text(context.state.endlessText)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                    } else {
                        Text(context.state.endlessText)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                            .blur(radius: 8)
                    }
                }
            }
            .padding(.top)
            .padding(.bottom)
//        }
    }
}

struct MeteorWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = MeteorWidgetAttributes(value: "Me")
    static let contentState = MeteorWidgetAttributes.ContentState(endlessText: "555", lockscreen: true)
    
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
