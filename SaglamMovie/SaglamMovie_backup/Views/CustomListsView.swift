import SwiftUI

struct CustomListsView: View {
    @Binding var selectedTab: ContentView.Tab
    @State private var customLists: [CustomList] = []
    @State private var isAddingNewList = false
    @State private var newListName = ""
    @State private var newListDescription = ""
    
    var body: some View {
        NavigationView {
            Group {
                if customLists.isEmpty {
                    emptyStateView
                } else {
                    listContent
                }
            }
            .navigationTitle("My Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedTab = .movies
                    }) {
                        Image(systemName: "house.fill")
                            .foregroundColor(.blue)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isAddingNewList = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $isAddingNewList) {
                createListSheet
            }
            .onAppear(perform: loadLists)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Custom Lists")
                .font(.title2)
            Text("Create your own movie collections")
                .foregroundColor(.secondary)
            Button(action: {
                isAddingNewList = true
            }) {
                Label("Create New List", systemImage: "plus")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
    
    private var listContent: some View {
        List {
            ForEach(customLists) { list in
                NavigationLink(destination: CustomListDetailView(list: list)) {
                    CustomListRow(list: list)
                }
            }
            .onDelete(perform: deleteLists)
        }
    }
    
    private var createListSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("List Details")) {
                    TextField("List Name", text: $newListName)
                    TextField("Description (Optional)", text: $newListDescription)
                }
            }
            .navigationTitle("New List")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isAddingNewList = false
                },
                trailing: Button("Create") {
                    createNewList()
                }
                .disabled(newListName.isEmpty)
            )
        }
    }
    
    private func loadLists() {
        customLists = UserDataManager.shared.getCustomLists()
    }
    
    private func createNewList() {
        let newList = UserDataManager.shared.createList(
            name: newListName,
            description: newListDescription.isEmpty ? nil : newListDescription
        )
        customLists.append(newList)
        newListName = ""
        newListDescription = ""
        isAddingNewList = false
    }
    
    private func deleteLists(at offsets: IndexSet) {
        // TODO: Implement delete functionality in UserDataManager
        customLists.remove(atOffsets: offsets)
    }
}

struct CustomListRow: View {
    let list: CustomList
    @State private var movieCount: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(list.name)
                .font(.headline)
            
            if let description = list.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("\(list.movieIds.count) movies")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
} 