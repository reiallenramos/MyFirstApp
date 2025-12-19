import SwiftUI

// Data model for daily entries
struct DailyEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var podcasts: [String]
    var books: [String]
    var learnings: [String]
    var isArchived: Bool
    
    init(id: UUID = UUID(), date: Date, podcasts: [String], books: [String], learnings: [String], isArchived: Bool = false) {
        self.id = id
        self.date = date
        self.podcasts = podcasts
        self.books = books
        self.learnings = learnings
        self.isArchived = isArchived
    }
    
    var formattedText: String {
        var formatted = ""
        
        for podcast in podcasts {
            if !formatted.isEmpty { formatted += "\n" }
            formatted += "🎧 \(podcast)"
        }
        
        for book in books {
            if !formatted.isEmpty { formatted += "\n" }
            formatted += "📚 \(book)"
        }
        
        for learning in learnings {
            if !formatted.isEmpty { formatted += "\n" }
            formatted += "✨ \(learning)"
        }
        
        return formatted
    }
}

struct ContentView: View {
    @State private var podcastInput = ""
    @State private var podcasts: [String] = []
    @State private var bookInput = ""
    @State private var books: [String] = []
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
                
                HStack {
                    TextField("What podcast did you listen to?", text: $podcastInput)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            addPodcast()
                        }
                    
                    Button(action: addPodcast) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                List {
                    ForEach(podcasts, id: \.self) { podcast in
                        Text(podcast)
                    }
                    .onDelete(perform: deletePodcast)
                }
                .listStyle(.plain)
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
                
                HStack {
                    TextField("What are you reading?", text: $bookInput)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            addBook()
                        }
                    
                    Button(action: addBook) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                List {
                    ForEach(books, id: \.self) { book in
                        Text(book)
                    }
                    .onDelete(perform: deleteBook)
                }
                .listStyle(.plain)
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
                        .onSubmit {
                            addLearning()
                        }
                    
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
                                
                                if !entry.podcasts.isEmpty {
                                    ForEach(entry.podcasts, id: \.self) { podcast in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("🎧")
                                            Text(podcast)
                                        }
                                        .font(.subheadline)
                                    }
                                } else {
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("🎧")
                                        Text("No podcasts")
                                            .foregroundColor(.gray)
                                    }
                                    .font(.subheadline)
                                }
                                
                                if !entry.books.isEmpty {
                                    ForEach(entry.books, id: \.self) { book in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("📚")
                                            Text(book)
                                        }
                                        .font(.subheadline)
                                    }
                                } else {
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("📚")
                                        Text("No books")
                                            .foregroundColor(.gray)
                                    }
                                    .font(.subheadline)
                                }
                                
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
    }
    
    func addPodcast() {
        let trimmed = podcastInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        podcasts.append(trimmed)
        podcastInput = ""
    }
    
    func deletePodcast(at offsets: IndexSet) {
        podcasts.remove(atOffsets: offsets)
    }
    
    func addBook() {
        let trimmed = bookInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        books.append(trimmed)
        bookInput = ""
        saveBooks()
    }
    
    func deleteBook(at offsets: IndexSet) {
        books.remove(atOffsets: offsets)
        saveBooks()
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
            history[existingIndex].podcasts = podcasts
            history[existingIndex].books = books
            history[existingIndex].learnings = learnings
        } else {
            // Create new entry
            let newEntry = DailyEntry(
                date: today,
                podcasts: podcasts,
                books: books,
                learnings: learnings
            )
            history.append(newEntry)
        }
        
        saveHistory()
        
        // Copy to clipboard
        var formatted = ""
        
        for podcast in podcasts {
            if !formatted.isEmpty { formatted += "\n" }
            formatted += "🎧 \(podcast)"
        }
        
        for book in books {
            if !formatted.isEmpty { formatted += "\n" }
            formatted += "📚 \(book)"
        }
        
        for learning in learnings {
            if !formatted.isEmpty { formatted += "\n" }
            formatted += "✨ \(learning)"
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
        podcasts = []
        learnings = []
        // Keep books as-is
        UserDefaults.standard.set(Date(), forKey: "lastSaveDate")
    }
    
    func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "history")
        }
    }
    
    func loadData() {
        // Load books
        if let data = UserDefaults.standard.data(forKey: "savedBooks"),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            books = decoded
        }
        
        // Load history
        if let data = UserDefaults.standard.data(forKey: "history"),
           let decoded = try? JSONDecoder().decode([DailyEntry].self, from: data) {
            history = decoded
        }
    }
    
    func saveBooks() {
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: "savedBooks")
        }
    }
    
    func saveBookText() {
        // This function is no longer needed but keeping for compatibility
    }
}

#Preview {
    ContentView()
}
