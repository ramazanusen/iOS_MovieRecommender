# iOS MovieRecommender

An elegant iOS application that allows users to discover and bookmark movies using the TMDb API. 🎥

## Features

- 🌟 **Browse Popular Movies**: View a curated list of trending and popular movies.
- 🔍 **Search Functionality**: Find specific movies by title.
- 📖 **Movie Details**: View detailed information about movies, including release dates, ratings, and overviews.
- 🎬 **Recommendations**: Get personalized movie recommendations based on your selections.
- 📌 **Bookmark Movies**: Save your favorite movies for later viewing.

## Screenshots

### Home Screen
![Simulator Screenshot - iPhone 16 Pro - 2024-11-22 at 04 51 44](https://github.com/user-attachments/assets/5cb06bbd-a1a9-4049-b6d7-4680b039eee5)


### Movie Details Screen
![Simulator Screenshot - iPhone 16 Pro - 2024-11-22 at 04 51 57](https://github.com/user-attachments/assets/d94dc919-b26a-42d3-bb45-17f473312fa6)


### Bookmarks Screen
![Simulator Screenshot - iPhone 16 Pro - 2024-11-22 at 04 52 24](https://github.com/user-attachments/assets/8c2518e8-e30f-460b-b8ab-84f51942f37d)


## Tech Stack

- **Programming Language**: Swift
- **Frameworks**: SwiftUI, Combine
- **Networking**: URLSession
- **Local Storage**: UserDefaults
- **API**: TMDb API

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/ramazanusen/iOS_MovieRecommender.git
   cd iOS_MovieRecommender
2. Open the project in XCode:
    open iOS_MovieRecommender.xcodeproj

3.	Install dependencies if needed (e.g., CocoaPods or SPM).
   
4.	Build and run the app on a simulator or device.

## Configuration

Create a Config.plist file in the project and add the following keys with your TMDb API credentials:

<plist version="1.0">
<dict>
    <key>API_KEY</key>
    <string>Your_TMDB_API_Key</string>
    <key>API_TOKEN</key>
    <string>Your_TMDB_API_Token</string>
</dict>
</plist>

## API Reference

This app uses the TMDb API for fetching movie data. Learn more at TMDb API Documentation.

## Roadmap

	•	Add genre filters for browsing movies.
	•	Implement offline support using CoreData.
	•	Add custom animations for enhanced user experience.

## Contributing

Contributions are welcome! Feel free to fork the project, create a branch, and submit a pull request.

License

This project is licensed under the MIT License.

## Contact

Created by Ramazan Usen
