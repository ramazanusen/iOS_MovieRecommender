# Movie Recommender iOS App

A sophisticated iOS application built with SwiftUI that helps users discover movies, create custom lists, and find streaming availability using the TMDB API.

## Features

### Movie Discovery
- Browse trending and popular movies
- Search functionality with real-time results
- Filter movies by genres
- View detailed movie information including:
  - Synopsis
  - Release date
  - Streaming availability
  - Poster images

### User Features
- Create and manage custom movie lists
- Track watch history
- Rate and review movies
- Bookmark favorite movies

### Technical Features
- SwiftUI-based modern UI
- TMDB API integration
- Efficient network layer with caching
- Persistent storage for user data
- Responsive design supporting various iOS devices

## Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- TMDB API Key

## Setup
1. Clone the repository

2. Configure API Access
   - Copy `Config.template.plist` to `Config.plist`
   - Add your TMDB API credentials:
     - Get your API key from [TMDB API](https://www.themoviedb.org/documentation/api)
     - Add your API key and token to `Config.plist`

3. Open `SaglamMovie.xcodeproj` in Xcode

4. Build and run the project

## Architecture
- **SwiftUI** for the UI layer
- **MVVM** architecture
- **UserDefaults** for local data persistence
- **URLSession** for networking

## Screenshots
(Add your app screenshots here)

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments
- [TMDB](https://www.themoviedb.org/) for providing the movie data API
- [JustWatch](https://www.justwatch.com/) for streaming availability data
