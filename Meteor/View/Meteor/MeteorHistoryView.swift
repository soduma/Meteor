//
//  MeteorHistoryView.swift
//  Meteor
//
//  Created by 장기화 on 3/28/24.
//

import SwiftUI
import SwiftData

struct MeteorHistoryView: View {
    var historyText: ((String) -> Void)?
    
    var modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: History.self, migrationPlan: HistoryMigrationPlan.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some View {
        NavigationStack {
            MeteorHistoryListView(historyText: historyText)
                .modelContainer(modelContainer)
        }
    }
}

struct MeteorHistoryListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query(sort: \History.timestamp, order: .reverse) private var historyList: [History]
    
    var historyText: ((String) -> Void)?
    
    var body: some View {
        List {
            ForEach(historyList.self, id: \.id) { history in
                MeteorHistoryCellView(history: history)
                    .frame(minHeight: 60, maxHeight: .greatestFiniteMagnitude)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .leading) {
                        Button {
                            historyText?(history.content)
                        } label: {
                            Image(systemName: "swift")
                        }
                    }
            }
            .onDelete(perform: { indexSet in
                makeVibration(type: .rigid)
                deleteHistory(indexSet)
                
                if historyList.count == 1 {
                    dismiss()
                }
            })
        }
        .navigationTitle("History")
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        do {
                            try modelContext.delete(model: History.self)
                            makeVibration(type: .warning)
                        } catch {
                            print(error.localizedDescription)
                        }
                        dismiss()
                        
                    } label: {
                        Label("Delete All", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .bold()
                        .foregroundStyle(.yellow)
                }
            }
        }
    }
    
    private func deleteHistory(_ indexSet: IndexSet) {
        for i in indexSet {
            let history = historyList[i]
            modelContext.delete(history)
        }
    }
}

struct MeteorHistoryCellView: View {
    var history: History
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(history.content)
                        .font(.system(size: 20))
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 25.0)
                .fill(.yellow).opacity(0.2))
            .contentShape(Rectangle()) // gesture 영역
            .onTapGesture {
                UIPasteboard.general.string = history.content
                makeVibration(type: .success)
                ToastManager.makeToast(toast: &ToastManager.toast, title: history.content, imageName: "doc.on.doc")
            }
            
            Spacer()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: History.self, migrationPlan: HistoryMigrationPlan.self, configurations: config)
    
    for i in 1..<10 {
        let history = History(content: "반갑습니다 abc ABC", timestamp: TimeInterval(i))
        modelContainer.mainContext.insert(history)
    }
    return MeteorHistoryView(modelContainer: modelContainer)
}
