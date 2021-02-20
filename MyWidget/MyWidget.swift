//
//  MyWidget.swift
//  MyWidget
//
//  Created by Arie Peretz on 19/02/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import WidgetKit
import SwiftUI
import Combine

@main
struct MyWidget: Widget {
    private let kind: String = "MyWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MyProvider()) { entry in
            MyWidgetView(entry: entry)
        }
        .configurationDisplayName("Walla Weather")
        .description("Showing the current location weather.")
    }
}

struct MyProvider: TimelineProvider {
    typealias Entry = MyEntry
    private var token: AnyCancellable?
    
    func placeholder(in context: Context) -> MyEntry {
        MyEntry(date: Date(), model: DetailsModel(cityName: "Placeholder", forecasts: []))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MyEntry) -> Void) {
        let entry = MyEntry(date: Date(), model: DetailsModel(cityName: "Dummy entry", forecasts: []))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MyEntry>) -> Void) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!

        APIClient.shared.fetchCurrentWeather(cityIdentifiers: [CityIdentifier.TelAviv]) { (result) in
            switch result {
            case .success(let responseModel):
                let successEntry = MyEntry(date: currentDate, model: DetailsModel(cityName: responseModel.list.first?.name ?? "", forecasts: [DetailsModel.Forecast.init(date: "", temperature: "\(responseModel.list.first?.main?.temp ?? 0.0)℃")]))
                let timeline = Timeline(entries: [successEntry], policy: .after(refreshDate))
                completion(timeline)
            case .failure(let error):
                let failEntry = MyEntry(date: currentDate, model: DetailsModel(cityName: error.localizedDescription, forecasts: []))
                let timeline = Timeline(entries: [failEntry], policy: .after(refreshDate))
                completion(timeline)
            }
        }
    }
    
    
}

struct MyEntry: TimelineEntry {
    let date: Date
    let model: DetailsModel
    var relevance: TimelineEntryRelevance? {
        TimelineEntryRelevance(score: 10)
    }
}

struct PlaceholderView: View {
    var body: some View {
        Text("Loading...")
    }
}

struct MyWidgetView: View {
    let entry: MyEntry
    var body: some View {
        VStack {
            Text(entry.model.cityName)
            Text(entry.model.forecasts.first?.temperature ?? "")
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .top, endPoint: .bottom))

    }
}

struct MyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyWidgetView(entry: MyEntry(date: Date(), model: DetailsModel(cityName: "Demo City", forecasts: [DetailsModel.Forecast(date: "", temperature: "22℃")])))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
