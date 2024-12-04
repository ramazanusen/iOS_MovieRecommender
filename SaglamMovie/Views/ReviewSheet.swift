import SwiftUI

struct ReviewSheet: View {
    let movie: Movie
    @Binding var rating: Double
    @Binding var review: String
    @Binding var isPresented: Bool
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rating")) {
                    RatingView(currentRating: $rating)
                }
                
                Section(header: Text("Your Review")) {
                    TextEditor(text: $review)
                        .frame(height: 150)
                }
            }
            .navigationTitle("Review")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    saveReview()
                    onSave()
                    isPresented = false
                }
            )
        }
    }
    
    private func saveReview() {
        UserDataManager.shared.addRating(rating, review: review, for: movie.id)
    }
} 