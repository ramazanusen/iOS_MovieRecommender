import SwiftUI

struct GenreCardView: View {
    let genre: Genre
    let gradient: [Color]
    
    var body: some View {
        VStack {
            Text(genre.name)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: gradient),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
                .shadow(color: gradient[0].opacity(0.3),
                        radius: 8, x: 0, y: 4)
        }
    }
}
