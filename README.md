# Real-time Search Analytics

## Overview

This application provides a real-time search analytics platform, allowing users to search for queries and tracking analytics on what users are searching for. The analytics include the user's most recent searches, their top searches, and the top searches of all users.

## Features

- **Real-time Search Box:** Users can input search queries in real-time, and search suggestions are displayed instantly.
- **Search Analytics:** Analytics are displayed for the user's most recent searches, their top searches, and the top searches of all users.
- **IP Tracking:** Searches are tracked and associated with user IPs for personalized analytics.

## Setup

1. Install Ruby and Rails on your machine if not already installed.
2. Clone the repository: `git clone <repository-url>`
3. Install dependencies: `bundle install`
4. Set up the database: `rails db:migrate`
5. Start the Rails server: `rails server`
6. Access the application in your browser: `http://localhost:3000`

## Usage

- Open the application in your browser.
- Type search queries in the search box, and suggestions will be displayed.
- Analytics on most recent searches, top searches, and top searches of all users are presented on the page.

## Code Structure

- **Controllers:** `SearchesController` handles the main logic for search actions.
- **Models:** `SearchTerm` represents a search term and includes methods for analytics and search logging.
- **Views:** HTML and JavaScript files in the `app/views` directory handle the user interface.

## Enhancements

- For possible enhancements and improvements, refer to the suggestions in the code comments.
- Additional features, security improvements, and optimizations can be explored based on project requirements.

## Contributing

Feel free to contribute by opening issues or submitting pull requests. Your feedback and contributions are welcome!

## License

This project is licensed under the [MIT License](LICENSE).
