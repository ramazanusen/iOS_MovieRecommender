import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Simplified background
            Color("LaunchScreenBackground")
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 25) {
                // App Icon - with proper memory handling
                Group {
                    if let appIconImage = UIImage(named: "AppIcon") {
                        Image(uiImage: appIconImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .cornerRadius(30)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Text content
                VStack(spacing: 12) {
                    Text("WHERE")
                        .font(.system(size: 42, weight: .bold))
                    
                    Text("2 WATCH")
                        .font(.system(size: 38, weight: .light))
                        .offset(y: -10)
                    
                    Text("Find your movie platform")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 5)
                }
                .foregroundColor(.white)
            }
            .padding()
            .opacity(isAnimating ? 1 : 0)
        }
        .onAppear {
            // Delayed animation to prevent immediate memory pressure
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 0.5)) {
                    isAnimating = true
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
} 
