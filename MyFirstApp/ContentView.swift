import SwiftUI

struct ContentView: View {
    @State private var count = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Counter App")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("\(count)")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            HStack(spacing: 20) {
                Button("Decrease") {
                    count -= 1
                }
                .buttonStyle(.bordered)
                .tint(.red)
                
                Button("Reset") {
                    count = 0
                }
                .buttonStyle(.bordered)
                
                Button("Increase") {
                    count += 1
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            .font(.title2)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
