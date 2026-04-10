> **Status:** DRAFT
> **Artefact ID:** `2026-04-10-todo-app-PD`
> **Product:** Todo App
> **Version documented:** v1.0.0
> **Author:** Baxter (AI) — **Verified by:** (Product Owner / Tech Lead to confirm)
> **Date:** 2026-04-10

---

## 1. Product Overview

Todo App is a multi-user task management application that allows authenticated users to create, track, and organise to-do items. Users can assign priorities, due dates, and tags to tasks, and delegate tasks to other users via the `assigned_to` field. An admin role provides visibility across all users' tasks. The application is built on a React frontend and a Node.js/Express REST API backed by MongoDB.

---

## 2. App Flow

```
User registers or logs in → receives JWT token
         │
         ▼
  Authenticated session (Bearer token on every request)
         │
    ┌────┴─────────────────────────────────┐
    │                                      │
    ▼                                      ▼
 Todos module                         Tags module
 Create / list / filter / update      Create / list / update / delete
 Complete / archive / delete          Scoped to owning user
    │
    ▼ (admin only)
 Admin: view all todos across all users
```

---

## 3. Modules

### 3.1 Authentication

**What it does:** Handles user registration, login, logout, and profile management. Issues and validates JWT tokens used to authenticate every subsequent API request.

**Who has access:** All roles (unauthenticated for register and login only).

**Key capabilities:**

- Register a new account with name, email, and password
- Log in and receive a 7-day JWT token
- Retrieve the authenticated user's profile (`GET /api/auth/me`)
- Update profile fields: `name`, `avatar_url`
- Change password (requires current password verification)
- Log out (client discards token; no server-side token revocation)

**API routes:**

| Method | Route | Description |
|--------|-------|-------------|
| POST | `/api/auth/register` | Create a new user account |
| POST | `/api/auth/login` | Authenticate and receive a JWT token |
| POST | `/api/auth/logout` | Signal logout (stateless — client discards token) |
| GET | `/api/auth/me` | Get the current user's profile |
| PATCH | `/api/auth/me` | Update `name` or `avatar_url` |
| PATCH | `/api/auth/me/password` | Change password |

---

### 3.2 Todos

**What it does:** Core task management module. Users create, filter, update, complete, archive, and delete their own todo items. Admins can view all todos across all users.

**Who has access:** All authenticated roles for own todos. Admin only for the cross-user list.

**Key capabilities:**

- Create a todo with `title`, `description`, `priority`, `due_date`, `tags`, and `assigned_to`
- List own todos with filters: `status`, `priority`, `tag`, `due_before`, `due_after`
- Paginate results via `page` and `limit` query parameters (default: 20 per page)
- Update any writable field on a todo via `PATCH`
- Mark a todo as completed (sets `status` to `completed` and records `completed_at`)
- Archive a todo (sets `status` to `archived`)
- Delete a todo permanently
- Admin: retrieve all todos across all users

**API routes:**

| Method | Route | Access | Description |
|--------|-------|--------|-------------|
| GET | `/api/todos` | All roles | List own todos (supports filters + pagination) |
| GET | `/api/todos/:id` | All roles | Get a single todo by ID |
| POST | `/api/todos` | All roles | Create a new todo |
| PATCH | `/api/todos/:id` | All roles | Partial update (title, description, status, priority, due_date, tags, assigned_to) |
| DELETE | `/api/todos/:id` | All roles | Permanently delete a todo |
| POST | `/api/todos/:id/complete` | All roles | Mark todo as completed |
| POST | `/api/todos/:id/archive` | All roles | Archive a todo |
| GET | `/api/todos/admin/all` | Admin only | List all todos across all users |

---

### 3.3 Tags

**What it does:** Allows users to create and manage colour-coded labels that can be applied to todos for organisation and filtering. Tags are scoped to the owning user — they are not shared between users.

**Who has access:** All authenticated roles (own tags only).

**Key capabilities:**

- Create a tag with a `name` and optional `colour` (hex, default `#6366f1`)
- List all own tags sorted alphabetically by name
- Update a tag's `name` or `colour`
- Delete a tag
- Apply tags to todos via the `tags` array field on the Todo model

**API routes:**

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/api/tags` | List all tags owned by the authenticated user |
| POST | `/api/tags` | Create a new tag |
| PATCH | `/api/tags/:id` | Update a tag's name or colour |
| DELETE | `/api/tags/:id` | Delete a tag |

---

## 4. User Roles

| Role | Who they are | What they can do |
|------|-------------|-----------------|
| `admin` | System administrator | Full access to all authenticated routes plus `GET /api/todos/admin/all` — can view every todo across all users |
| `member` | Standard user | Create, read, update, complete, archive, and delete their own todos; manage their own tags; update their own profile |
| `viewer` | Read-only user | Shares the same API access as `member` — no route-level restriction currently differentiates `viewer` from `member` (see Known Limitations §7) |

> Roles are assigned at registration and default to `member`. Role changes must be made directly in the database — there is no admin UI for role assignment.

---

## 5. Key Workflows

### 5.1 Register and log in

**Who does this:** New user (any role)

1. POST `/api/auth/register` with `name`, `email`, `password` → receives JWT token and user object
2. Store the JWT token in `localStorage` (key: `token`)
3. Include `Authorization: Bearer <token>` header on all subsequent requests
4. Token expires after 7 days — user must log in again to obtain a new token

### 5.2 Create and manage a todo

**Who does this:** Member or Admin

1. POST `/api/todos` with `title` (required), and optionally `description`, `priority`, `due_date`, `tags`, `assigned_to`
2. The todo is created with `status: pending` and `owner` set to the authenticated user
3. Update the todo at any time via PATCH `/api/todos/:id` — only the fields listed in the allowed set are accepted
4. Mark complete via POST `/api/todos/:id/complete` — sets `status: completed` and records `completed_at`
5. Archive via POST `/api/todos/:id/archive` — sets `status: archived`
6. Delete permanently via DELETE `/api/todos/:id`

### 5.3 Filter and browse todos

**Who does this:** Member or Admin

1. GET `/api/todos` with any combination of query parameters:
   - `status` — `pending` | `in_progress` | `completed` | `archived`
   - `priority` — `low` | `medium` | `high`
   - `tag` — Tag ObjectId
   - `due_before` — ISO date string
   - `due_after` — ISO date string
   - `page` — page number (default: 1)
   - `limit` — results per page (default: 20)
2. Results are sorted: due date ascending, then priority descending, then creation date descending
3. Each todo in the response includes populated `tags` (name, colour) and `assigned_to` (name, email)

### 5.4 Manage tags

**Who does this:** Member or Admin

1. POST `/api/tags` with `name` and optional `colour` to create a tag
2. Tag names must be unique per user (enforced by a compound index on `name` + `owner`)
3. Apply tags to a todo by including their ObjectIds in the `tags` array when creating or updating
4. Delete a tag via DELETE `/api/tags/:id` — note: deleting a tag does not automatically remove it from todos that reference it

### 5.5 Admin: view all todos

**Who does this:** Admin only

1. GET `/api/todos/admin/all` with a valid admin JWT token
2. Returns all todos across all users, populated with `owner` (name, email) and `tags` (name, colour)
3. Sorted by `createdAt` descending

---

## 6. Integrations

| System | What it does |
|--------|-------------|
| MongoDB | Primary data store for all User, Todo, and Tag records. Connected via `MONGODB_URI` environment variable |
| JWT (jsonwebtoken) | Issues and verifies stateless authentication tokens. Secret configured via `JWT_SECRET` environment variable |

---

## 7. Known Limitations

- **No viewer restriction:** The `viewer` role is defined in the User model enum but no API route restricts access based on the viewer role. A viewer can perform the same write operations as a member. Role-based read-only enforcement must be added if viewer restrictions are required.
- **No token revocation:** Logout is stateless — the server does not invalidate tokens. A stolen token remains valid until it expires (7 days). No refresh token mechanism exists.
- **Tag deletion does not cascade:** Deleting a tag does not remove it from todos that reference it. Those todos retain orphaned ObjectId references in their `tags` array.
- **No shared tags:** Tags are scoped to their owner. There is no concept of global or team-shared tags.
- **No role assignment UI:** Changing a user's role requires direct database access. There is no admin endpoint for role management.
- **No pagination on tags:** `GET /api/tags` returns all tags for the user without pagination. May become a performance concern for users with large numbers of tags.
- **Admin/all route ordering:** The route `GET /api/todos/admin/all` is defined after `GET /api/todos/:id` in the router. Express matches `:id` before `admin/all` unless explicitly ordered — verify route registration order in `backend/routes/todos.js` to confirm `admin/all` is reachable.

---

## 8. Data Model

### User
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | String | Yes | Trimmed |
| `email` | String | Yes | Unique, lowercase |
| `password_hash` | String | Yes | bcrypt hashed (12 rounds) on save |
| `role` | String | — | `admin` \| `member` \| `viewer` — default: `member` |
| `avatar_url` | String | No | — |
| `is_active` | Boolean | — | Default: `true`. Inactive users cannot log in |
| `last_login_at` | Date | No | Updated on each successful login |

### Todo
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `title` | String | Yes | Max 200 chars |
| `description` | String | No | Max 1000 chars |
| `status` | String | — | `pending` \| `in_progress` \| `completed` \| `archived` — default: `pending` |
| `priority` | String | — | `low` \| `medium` \| `high` — default: `medium` |
| `due_date` | Date | No | — |
| `tags` | ObjectId[] | No | References Tag |
| `owner` | ObjectId | Yes | References User — set automatically to authenticated user |
| `assigned_to` | ObjectId | No | References User |
| `completed_at` | Date | No | Set automatically when status changes to `completed` |

### Tag
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | String | Yes | Max 50 chars. Unique per owner |
| `colour` | String | — | Hex colour — default: `#6366f1` |
| `owner` | ObjectId | Yes | References User |

---

## 9. Linked Artefacts

| Type | Feature / Module | Path | Status |
|------|-----------------|------|--------|
| — | No linked artefacts yet — this is the baseline PD | — | — |
