import SwiftUI

// Simple persistent notch content - just a small square
struct NotchContentView: View {
    @State private var isListening = false
    
    var body: some View {
        HStack(spacing: 8) {
            // Simple icon
            Image(systemName: isListening ? "waveform" : "mic.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isListening ? .red : .blue)
                .frame(width: 16, height: 16)
            
            // Simple text
            Text(isListening ? "Listening" : "EDITH")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isListening.toggle()
            }
        }
    }
}

// Main content view (not used in notch, but keeping for potential future use)
struct ContentView: View {
    var body: some View {
        VStack {
            Text("EDITH is running in the notch")
                .font(.title2)
                .padding()
            
            Text("Look for the small square in your notch area")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 300, height: 200)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            
            NotchContentView()
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}