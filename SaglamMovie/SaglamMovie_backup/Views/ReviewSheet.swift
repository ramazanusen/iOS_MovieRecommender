import SwiftUI

struct ReviewSheet: View {
    let movie: Movie
    @Binding var rating: Double
    @Binding var review: String
    @Binding var isPresented: Bool
    @Binding var existingRating: UserRating?
    @State private var temporaryRating: Double
    @State private var temporaryReview: String
    
    init(movie: Movie, 
         rating: Binding<Double>, 
         review: Binding<String>, 
         isPresented: Binding<Bool>,
         existingRating: Binding<UserRating?>) {
        self.movie = movie
        self._rating = rating
        self._review = review
        self._isPresented = isPresented
        self._existingRating = existingRating
        self._temporaryRating = State(initialValue: rating.wrappedValue)
        self._temporaryReview = State(initialValue: review.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rating")) {
                    VStack(alignment: .center) {
                        RatingView(currentRating: $temporaryRating)
                            .padding(.vertical)
                        Text(String(format: "%.1f stars", temporaryRating))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Section(header: Text("Review")) {
                    TextEditor(text: $temporaryReview)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Rate & Review")
            .navigationBarItems(
                leading: Button("Cancel") {
                    temporaryRating = rating
                    temporaryReview = review
                    isPresented = false
                },
                trailing: Button("Save") {
                    saveReview()
                    isPresented = false
                }
            )
            .onAppear {
                temporaryRating = rating
                temporaryReview = review
            }
        }
    }
    
    private func saveReview() {
        // Update the binding values
        rating = temporaryRating
        review = temporaryReview
        
        // Save to UserDefaults
        UserDataManager.shared.addRating(temporaryRating, 
                                       review: temporaryReview.isEmpty ? nil : temporaryReview, 
                                       for: movie.id)
        
        // Update existing rating immediately
        existingRating = UserRating(id: UUID(),
                                  movieId: movie.id,
                                  rating: temporaryRating,
                                  review: temporaryReview.isEmpty ? nil : temporaryReview,
                                  date: Date())
    }
} 