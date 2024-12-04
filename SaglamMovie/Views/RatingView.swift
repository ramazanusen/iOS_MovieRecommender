import SwiftUI

struct RatingView: View {
    let maximumRating: Int
    @Binding var currentRating: Double
    let starSize: CGFloat
    
    init(maximumRating: Int = 5, currentRating: Binding<Double>, starSize: CGFloat = 30) {
        self.maximumRating = maximumRating
        self._currentRating = currentRating
        self.starSize = starSize
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maximumRating, id: \.self) { number in
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: starSize, height: starSize)
                    .foregroundColor(number <= Int(currentRating.rounded()) ? .yellow : .gray.opacity(0.3))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            if currentRating == Double(number) {
                                currentRating = 0  // Allow removing rating by tapping again
                            } else {
                                currentRating = Double(number)
                            }
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let starWidth = starSize + 8 // Include spacing
                                let position = value.location.x
                                let newRating = position / starWidth
                                currentRating = min(max(Double(Int(newRating) + 1), 0), Double(maximumRating))
                            }
                    )
            }
        }
    }
} 