# Postly iOS - Complete Documentation

## 1. Complete Technical Documentation

### 1.1 Architecture Overview
The iOS app follows a layered SwiftUI architecture:

- `App` layer:
  - `postly_iosApp.swift`: app entry point.
  - `ContentView.swift`: main container and high-level navigation (home/posts/search/profile/create/edit).
- `View` layer:
  - UI screens in `Views/*` (Welcome, Auth, Posts, PostDetail, Profile, SearchResults).
  - Reusable UI in `Components/*` (navbar, side menu, post card).
- `ViewModel` layer:
  - `PostsViewModel.swift`: pagination/loading/error state for posts feed.
- `Service` layer:
  - `AuthService`, `PostService`, `CommentService`, `PexelsService`.
  - Handles business operations and delegates HTTP to `APIClient`.
- `Networking` layer:
  - `APIClient.swift`: generic request/response, auth header injection, date decoding.
  - `Endpoints.swift`: centralized endpoint paths.
- `State/Session` layer:
  - `SessionManager`: logged-in user state and session lifecycle.
  - `AuthManager`: token persistence (`UserDefaults`).
- `Models` layer:
  - `Post`, `Comment`, `User`, `AuthResponse`, pagination models, etc.

### 1.2 Core Component Interactions
1. UI triggers action (example: login, fetch posts, create comment).
2. View or ViewModel calls a Service method.
3. Service builds payload/endpoint and calls `APIClient.request(...)`.
4. `APIClient`:
   - builds URL from `BASE_URL + endpoint.path`
   - injects `Authorization: Bearer <token>` for protected calls
   - decodes JSON to model types
5. View/ViewModel updates observable state (`@State`, `@Published`) and UI re-renders.

### 1.3 API Integrations

#### 1.3.1 Backend API (Flask)
Base URL configured in `Postly-Info.plist` key: `BASE_URL`.

Authentication:
- `POST /api/auth/login`
  - body: `{ token }` (Google token)
  - response: `{ accessToken, user }`
- `POST /api/auth/register`
  - body: `{ name, email, password }`
  - response: `{ accessToken, user }`
- `POST /api/auth/login/email`
  - body: `{ email, password }`
  - response: `{ accessToken, user }`
- `GET /api/auth/check` (JWT required)
  - response: authenticated user object

Posts:
- `GET /api/posts?page=<int>&limit=<int>&status=<published|draft>`
  - response: `{ posts: [...], pagination: { total, page, limit, totalPages } }`
- `GET /api/posts/<id>`
  - response: post object (also increments `views`)
- `GET /api/posts/slug/<slug>`
  - response: post object by slug (also increments `views`)
- `POST /api/posts` (JWT required)
  - body: `{ title, content, status?, coverImage? }`
  - response: created post
- `PUT /api/posts/<id>` (JWT required)
  - body: any of `{ title, content, status, coverImage }`
  - response: updated post
- `DELETE /api/posts/<id>` (JWT required)
  - response: success message

Likes:
- `POST /api/posts/<post_id>/like` (JWT required)
  - response: `{ message }`
- `DELETE /api/posts/<post_id>/like` (JWT required)
  - response: `{ message }`
- `GET /api/posts/<post_id>/like` (JWT required)
  - response: `{ liked: boolean }`

Comments:
- `GET /api/posts/<post_id>/comments`
  - response: `[comment, ...]`
- `POST /api/posts/<post_id>/comments` (JWT required)
  - body: `{ content }`
  - response: created comment
- `DELETE /api/posts/<post_id>/comments/<comment_id>` (JWT required)
  - response: success message

Search:
- `GET /api/posts/search?q=<text>`
  - response: `[post, ...]`

User Posts:
- `GET /api/users/<user_id>/posts?page=<int>&limit=<int>&status=<published|draft>`
- `GET /api/users/me/posts?page=<int>&limit=<int>&status=<optional>` (JWT required)
  - both return paginated `{ posts, pagination }`

#### 1.3.2 Pexels API
Used in create/edit post flows for suggested cover images.
- Config key: `PEXELS_API_KEY` in `Postly-Info.plist`
- Request: `GET https://api.pexels.com/v1/search?query=<q>&per_page=6`
- Header: `Authorization: <PEXELS_API_KEY>`

### 1.4 Key Algorithms / Logic
- Session bootstrap:
  - On app launch, if token exists, app calls `/api/auth/check` and restores user.
- Pagination:
  - `PostsViewModel` tracks `page` and `totalPages`; calls `loadMore()` on scroll.
- Slug and read-time (backend):
  - slug normalization and uniqueness handling when creating/updating posts.
  - reading time based on ~200 words/minute.
- Like state:
  - app checks `GET /like` when loading post detail and toggles with POST/DELETE.
- Comment permissions:
  - delete button shown only if current user is comment author or post author.
- Search:
  - query from navbar -> `SearchResultsView` -> `/api/posts/search?q=...`.

## 2. Developer Setup Guide

### 2.1 Prerequisites
- macOS with Xcode installed.
- iOS SDK compatible with project deployment target.
- Running backend API (Flask + MongoDB).
- Optional: Pexels API key for image suggestions.

### 2.2 Clone and Open
1. Clone repository.
2. Open `postly-ios` in Xcode.

### 2.3 Configure Environment
Update `Postly-Info.plist`:
- `BASE_URL` (e.g. `http://localhost:8080/api/`)
- `PEXELS_API_KEY` (optional, but required for image suggestions)

If testing on physical device, ensure `BASE_URL` points to a reachable host (not plain localhost).

### 2.4 Run
1. Choose simulator/device.
2. Build and run from Xcode.
3. Verify backend is up and reachable before testing auth/posts/comments/search.

### 2.5 Recommended Validation Checklist
- Register + Login + Logout.
- Feed pagination.
- Create post with and without cover image.
- Edit post and remove cover image.
- Post detail: like/unlike, add/delete comment.
- Search from navbar and open a result.

## 3. User Guide (End Users)

### 3.1 Navigation Basics
- Use the top-right menu icon to open app sections.
- Use the search icon in the navbar to find posts by keyword.
- Tap any post card to open full details.

### 3.2 Key Features
- Account:
  - Register or log in from the auth sheet.
- Posts Feed:
  - Browse recent posts, open details, and continue scrolling to load more.
- Post Detail:
  - Read full content, like/unlike a post, review comments.
- Comments:
  - Signed-in users can post comments.
  - Comment authors and post authors can delete comments.
- Create/Edit Post:
  - Add title/content, optional status (published/draft), optional cover image.
  - Choose image suggestions from Pexels.
- Search:
  - Enter a term from navbar search field and submit to see matching posts.

### 3.3 Common Troubleshooting
- "Could not load data":
  - Check internet connection and try again.
- Login fails:
  - Verify email/password and backend availability.
- Empty feed/search unexpectedly:
  - Confirm posts exist with matching status/query.
- Images not loading:
  - Verify image URL availability and Pexels API key config.
- Actions blocked (edit/delete/like/comment):
  - Ensure you are signed in and have permissions.

## 4. Maintenance and Update Plan

### 4.1 Regular Maintenance Tasks
- Dependency health:
  - Review Xcode/Swift updates.
  - Check third-party API compatibility (Flask backend contracts, Pexels API behavior).
- Configuration hygiene:
  - Validate `BASE_URL` and auth settings across environments.
- Security checks:
  - Ensure JWT handling and token storage logic remains correct.

### 4.2 Monitoring and Quality
- Crash monitoring:
  - Track crashes and top stack traces regularly.
- User feedback loop:
  - Review reported UX issues and API failures.
- API error monitoring:
  - Watch 4xx/5xx trends for auth/posts/comments/search endpoints.

### 4.3 Planned Update Cadence
- Weekly:
  - triage crashes, failed requests, and high-priority bugs.
- Monthly:
  - dependency review and minor maintenance release.
- Quarterly:
  - architecture and performance review, plus UX refinements based on user feedback.
