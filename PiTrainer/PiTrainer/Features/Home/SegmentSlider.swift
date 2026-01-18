import SwiftUI

struct SegmentSlider: View {
    @Binding var start: Int
    @Binding var end: Int
    let range: ClosedRange<Int>
    let step: Int = 10
    
    // Zen Tokens
    private let accentColor = Color(red: 0.0, green: 0.95, blue: 1.0) // Cyan Électrique
    private let trackColor = Color.white.opacity(0.1)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SEGMENT")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Group {
                    Text("\(start)")
                        .foregroundStyle(accentColor)
                    Text("-")
                        .foregroundStyle(.secondary)
                    Text("\(end)")
                        .foregroundStyle(accentColor)
                }
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.bold)
            }
            .padding(.horizontal, 4)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(trackColor)
                        .frame(height: 4)
                    
                    // Selected range track
                    Capsule()
                        .fill(accentColor)
                        .frame(width: CGFloat(end - start) / CGFloat(range.upperBound - range.lowerBound) * geometry.size.width, height: 4)
                        .offset(x: CGFloat(start - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound) * geometry.size.width)
                    
                    // Start Handle
                    HandleView()
                        .offset(x: position(for: start, in: geometry.size.width) - 14)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newVal = valueAt(position: value.location.x, width: geometry.size.width)
                                    if newVal < end {
                                        start = max(range.lowerBound, newVal)
                                    }
                                }
                        )
                        .accessibilityIdentifier("home.slider_start")
                    
                    // End Handle
                    HandleView()
                        .offset(x: position(for: end, in: geometry.size.width) - 14)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newVal = valueAt(position: value.location.x, width: geometry.size.width)
                                    if newVal > start {
                                        end = min(range.upperBound, newVal)
                                    }
                                }
                        )
                        .accessibilityIdentifier("home.slider_end")
                }
            }
            .frame(height: 28)
        }
        .padding(.vertical, 8)
    }
    
    private func position(for value: Int, in width: CGFloat) -> CGFloat {
        let ratio = CGFloat(value - range.lowerBound) / CGFloat(range.upperBound - range.lowerBound)
        return ratio * width
    }
    
    private func valueAt(position: CGFloat, width: CGFloat) -> Int {
        let ratio = position / width
        let rawVal = Int(ratio * CGFloat(range.upperBound - range.lowerBound)) + range.lowerBound
        // Snap to step
        let remainder = rawVal % step
        return remainder < step/2 ? rawVal - remainder : rawVal + (step - remainder)
    }
    
    struct HandleView: View {
        var body: some View {
            Circle()
                .fill(.white)
                .frame(width: 28, height: 28)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SegmentSlider(start: .constant(0), end: .constant(50), range: 0...1000)
            .padding()
    }
}
