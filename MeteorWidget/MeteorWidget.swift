//
//  MeteorWidget.swift
//  MeteorWidget
//
//  Created by 장기화 on 2023/08/11.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imageData = UserDefaults(suiteName: "group.com.soduma.Meteor")?.data(forKey: "widgetDataKey")
}

struct MeteorWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        let myImage = entry.imageData!
        
        // MARK: - 정식버전 올리면 수정
#if compiler(>=5.9) // Xcode 15
        if #available(iOSApplicationExtension 17.0, *) {
            ZStack {
                Image(uiImage: UIImage(data: myImage)!)
                    .resizable()
                    .scaledToFill()
            }.containerBackground(.clear, for: .widget)
        }
        else {
            Image(uiImage: UIImage(data: myImage)!)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
#else
        Image(uiImage: UIImage(data: myImage)!)
            .resizable()
            .aspectRatio(contentMode: .fill)
#endif
    }
}

struct MeteorWidget: Widget {
    let kind: String = "MeteorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MeteorWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Meteor Widget")
        .description("Inspire emotions into your day.")
//        .contentMarginsDisabled()
//        .containerBackgroundRemovable(false)
    }
}

struct MeteorWidget_Previews: PreviewProvider {
    static var previews: some View {
        MeteorWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
