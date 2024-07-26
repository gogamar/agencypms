The **Agencypms** is a Ruby on Rails application designed to handle reservations efficiently and serve as an administrative tool with varying roles, such as Property Owner and Admin, to manage financial tasks, invoices, operational tasks, and agreements. The application integrates with an external API to streamline operations and provide comprehensive data management capabilities. **The API connection is two-way, allowing the app to both fetch and export data to a third-party API.** The application also handles webhook notifications and supports photo uploads for better user interaction.

## Features

- **User Authentication & Authorization**: Secure user login with role-based access control using Pundit.
- **Role Management**: Different roles for Property Owners and Admins with tailored access rights.
- **Reservation Management**: Create, update, and view reservations.
- **Financial Management**: Manage expenses, generate financial statements, and handle invoices.
- **Operational Tasks Organizer**: Track and manage daily operational tasks.
- **Yearly Agreements Preparation**: Prepare and manage agreements with property owners.
- **Rate Management**: Set and update property rates.
- **External API Integration**: Fetch and export data to a third-party API for enhanced integration.
- **Responsive Design**: Use Bootstrap for mobile-first, responsive UI.
- **Real-Time Updates**: Interactive frontend using Stimulus and JavaScript.
- **Photo Handling**: Upload, store, and manage images using Active Storage and Cloudinary.
- **Webhook Notifications**: Receive and handle webhook events for real-time data synchronization.

## Technologies Used

The following technologies are used in this project:

### Backend

- **Ruby on Rails (7.0.4)**: A web application framework for server-side development.
- **Pundit**: Authorization library for managing roles and permissions.
- **PostgreSQL**: Database for storing application data.
- **Redis**: In-memory data structure store used by Sidekiq.
- **Sidekiq**: Background job processing for handling asynchronous tasks.
- **Devise**: Authentication solution for Rails applications.
- **Active Storage**: Handles file uploads and storage.
- **Image Processing**: Used for transforming images with Active Storage.
- **Geocoder**: Provides geocoding capabilities for location-based features.

### Frontend

- **Bootstrap**: CSS framework for responsive and mobile-first design.
- **Stimulus**: JavaScript framework for building interactive applications.
- **Turbo Rails**: SPA-like page acceleration using Hotwire.
- **Font Awesome**: Icon toolkit for adding scalable vector icons.
- **Sassc Rails**: CSS preprocessor for Rails applications.
- **Simple Form**: Forms library for Rails applications.
- **Pagy**: Pagination library for handling large datasets.

### Utilities

- **Wicked PDF**: Generates PDF files from HTML templates using WebKit.
- **Wkhtmltopdf-binary**: Binary for generating PDFs on various platforms.
- **Caxlsx**: Generates Excel spreadsheets.
- **Dotenv Rails**: Loads environment variables from a `.env` file.
- **Nokogiri**: HTML, XML, SAX, and Reader parser.

### Deployment

- **Heroku**: Cloud platform for hosting the application.
- **Sidekiq-Cron**: Scheduler for periodic jobs in Sidekiq.
- **Letter Opener**: Preview email in the browser instead of sending it.

### Webhooks

- **Rack Middleware**: Handles incoming webhook requests for real-time updates and notifications.

### Security

- **Recaptcha**: Implements CAPTCHA for forms to prevent spam and abuse.

### Internationalization

- **Rails I18n**: Provides internationalization support for Rails applications.
- **Devise I18n**: Translation files for Devise views.

### SEO

- **Friendly ID**: Provides human-friendly URLs and slugs.
- **Route Translator**: Translates Rails routes to different languages.
