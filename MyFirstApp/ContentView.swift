import SwiftUI

// Data model for daily entries
struct DailyEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var podcast: String
    var book: String
    var learnings: [String]
    var isArchived: Bool
    
    init(id: UUID = UUID(), date: Date, podcast: String, book: String, learnings: [String], isArchived: Bool = false) {
        self.id = id
        self.date = date
        self.podcast = podcast
        self.book = book
        self.learnings = learnings
        self.isArchived = isArchived
    }
    
    var formattedText: String {
        var formatted = """
        🎧 \(podcast)
        📚 \(book)
        """
        
        for learning in learnings {
            formatted += "\n✨ \(learning)"
        }
        
        return formatted
    }
}

struct ContentView: View {
    @State private var audioText = ""
    @State private var bookText = ""
    @State private var learningInput = ""
    @State private var learnings: [String] = []
    @State private var showCopiedAlert = false
    @State private var showNewDayAlert = false
    @State private var history: [DailyEntry] = []
    @State private var showArchived = false
    
    var filteredHistory: [DailyEntry] {
        if showArchived {
            return history
        } else {
            return history.filter { !$0.isArchived }
        }
    }
    
    var body: some View {
        TabView {
            // Tab 1: Headphones
            VStack {
                Text("Podcast")
                    .font(.largeTitle)
                    .padding()
                
                TextField("What podcast did you listen to?", text: $audioText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Spacer()
            }
            .tabItem {
                Image(systemName: "headphones")
                Text("Podcast")
            }
            
            // Tab 2: Book
            VStack {
                Text("Reading")
                    .font(.largeTitle)
                    .padding()
                
                TextField("What are you reading?", text: $bookText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Spacer()
            }
            .tabItem {
                Image(systemName: "book")
                Text("Reading")
            }
            
            // Tab 3: Learning
            VStack {
                Text("Learning")
                    .font(.largeTitle)
                    .padding()
                
                HStack {
                    TextField("What did you learn today?", text: $learningInput)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: addLearning) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                List {
                    ForEach(learnings, id: \.self) { learning in
                        Text(learning)
                    }
                    .onDelete(perform: deleteLearning)
                }
                .listStyle(.plain)
            }
            .tabItem {
                Image(systemName: "sparkle")
                Text("Learning")
            }
            
            // Tab 4: History
            VStack {
                HStack {
                    Text("History")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Toggle("Archived", isOn: $showArchived)
                        .labelsHidden()
                }
                .padding()
                
                if filteredHistory.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(showArchived ? "No archived entries" : "No history yet")
                            .foregroundColor(.gray)
                        Text("Tap the blue button to save your daily entries")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredHistory.sorted(by: { $0.date > $1.date })) { entry in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(entry.date, style: .date)
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    
                                    if entry.isArchived {
                                        Text("(Archived)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                                
                                HStack(alignment: .top, spacing: 8) {
                                    Text("🎧")
                                    Text(entry.podcast.isEmpty ? "No podcast" : entry.podcast)
                                        .foregroundColor(entry.podcast.isEmpty ? .gray : .primary)
                                }
                                .font(.subheadline)
                                
                                HStack(alignment: .top, spacing: 8) {
                                    Text("📚")
                                    Text(entry.book.isEmpty ? "No book" : entry.book)
                                        .foregroundColor(entry.book.isEmpty ? .gray : .primary)
                                }
                                .font(.subheadline)
                                
                                if !entry.learnings.isEmpty {
                                    ForEach(entry.learnings, id: \.self) { learning in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("✨")
                                            Text(learning)
                                        }
                                        .font(.subheadline)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                copyEntryToClipboard(entry)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(entry.isArchived ? "Unarchive" : "Archive") {
                                    toggleArchive(entry)
                                }
                                .tint(entry.isArchived ? .green : .orange)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .tabItem {
                Image(systemName: "clock.arrow.circlepath")
                Text("History")
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: saveAndCopyToClipboard) {
                Image(systemName: "doc.on.clipboard.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(20)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 90)
        }
        .alert("Copied!", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your daily accountability has been copied to clipboard")
        }
        .alert("Start New Day?", isPresented: $showNewDayAlert) {
            Button("Start New Day") {
                startNewDay()
            }
            Button("Continue Yesterday", role: .cancel) { }
        } message: {
            Text("This will clear your podcast and learnings, but keep your book.")
        }
        .onAppear {
            loadData()
            checkForNewDay()
        }
        .onChange(of: bookText) { oldValue, newValue in
            saveBookText()
        }
    }
    
    func addLearning() {
        let trimmed = learningInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        learnings.append(trimmed)
        learningInput = ""
    }
    
    func deleteLearning(at offsets: IndexSet) {
        learnings.remove(atOffsets: offsets)
    }
    
    func saveAndCopyToClipboard() {
        // Create or update today's entry
        let today = Calendar.current.startOfDay(for: Date())
        
        if let existingIndex = history.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            // Update existing entry
            history[existingIndex].podcast = audioText
            history[existingIndex].book = bookText
            history[existingIndex].learnings = learnings
        } else {
            // Create new entry
            let newEntry = DailyEntry(
                date: today,
                podcast: audioText,
                book: bookText,
                learnings: learnings
            )
            history.append(newEntry)
        }
        
        saveHistory()
        
        // Copy to clipboard
        var formatted = """
        🎧 \(audioText)
        📚 \(bookText)
        """
        
        for learning in learnings {
            formatted += "\n✨ \(learning)"
        }
        
        UIPasteboard.general.string = formatted
        showCopiedAlert = true
    }
    
    func copyEntryToClipboard(_ entry: DailyEntry) {
        UIPasteboard.general.string = entry.formattedText
        showCopiedAlert = true
    }
    
    func toggleArchive(_ entry: DailyEntry) {
        if let index = history.firstIndex(where: { $0.id == entry.id }) {
            history[index].isArchived.toggle()
            saveHistory()
        }
    }
    
    func checkForNewDay() {
        guard let lastSaveDate = UserDefaults.standard.object(forKey: "lastSaveDate") as? Date else {
            // First time opening app
            UserDefaults.standard.set(Date(), forKey: "lastSaveDate")
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let lastSave = Calendar.current.startOfDay(for: lastSaveDate)
        
        if today > lastSave {
            // It's a new day!
            showNewDayAlert = true
        }
    }
    
    func startNewDay() {
        audioText = ""
        learnings = []
        // Keep bookText as-is
        UserDefaults.standard.set(Date(), forKey: "lastSaveDate")
    }
    
    func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "history")
        }
    }
    
    func loadData() {
        // Load book
        if let saved = UserDefaults.standard.string(forKey: "savedBook") {
            bookText = saved
        }
        
        // Load history
        if let data = UserDefaults.standard.data(forKey: "history"),
           let decoded = try? JSONDecoder().decode([DailyEntry].self, from: data) {
            history = decoded
        }
    }
    
    func saveBookText() {
        UserDefaults.standard.set(bookText, forKey: "savedBook")
    }
}

#Preview {
    ContentView()
}
