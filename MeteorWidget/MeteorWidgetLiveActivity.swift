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
    }

    // Fixed non-changing properties about your activity go here!
    var value: String
}

@available(iOS 16.2, *)
struct MeteorWidgetLiveActivity: Widget {
    let logo = "meteor_logo"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MeteorWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            ZStack {
                Color.red.opacity(0.8)
                VStack {
                    HStack(alignment: .center, spacing: 8) {
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
                    }.padding(.leading)
                    if context.state.endlessText.count < 20 {
                        Text(context.state.endlessText)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                    } else {
                        Text(context.state.endlessText)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                    }
                }
                .padding(.top)
                .padding(.bottom)
            }
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    HStack(alignment: .center, spacing: 8) {
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
                    if context.state.endlessText.count < 20 {
                        Text(context.state.endlessText)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
                    } else {
                        Text(context.state.endlessText)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding([.leading, .trailing])
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

@available(iOS 16.2, *)
struct MeteorWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = MeteorWidgetAttributes(value: "Me")
    static let contentState = MeteorWidgetAttributes.ContentState(endlessText: "555")

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
