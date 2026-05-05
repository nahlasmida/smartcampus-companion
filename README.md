# SmartCampus Companion

A mobile app for university campus life — schedules, announcements, events, and interactive maps, all in one place.

---

## Features

| Area | Highlights |
|------|-----------|
| **Auth** | JWT login, biometric unlock (Face ID / Fingerprint), encrypted token storage |
| **Home** | Today's schedule, upcoming events & announcements, offline banner |
| **Announcements** | Pinned posts, category tags, pull-to-refresh |
| **Events** | Filter by upcoming, reminders, per-event notes, photo attachments |
| **Timetable** | Weekly day tabs, color-coded courses, PDF/JSON export |
| **Map** | OpenStreetMap (no API key), live GPS, color-coded building markers, search |
| **Settings** | Dark/light theme, notification prefs, profile management |

---

## Architecture

```
Flutter (Riverpod + Dio)
        │
  FastAPI Backend
  (JWT · CRUD · PDF export)
        │
  MongoDB 7.0
  (users · announcements · events · timetable)
```

---

## Tech Stack

**Frontend (Flutter)**

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `dio` | HTTP client |
| `flutter_secure_storage` | Encrypted token storage |
| `local_auth` | Biometric authentication |
| `flutter_map` + `latlong2` | OpenStreetMap |
| `geolocator` | GPS tracking |
| `flutter_local_notifications` | Reminders |
| `connectivity_plus` | Network status |

**Backend (Python)**

| Package | Purpose |
|---------|---------|
| `fastapi` | Web framework |
| `beanie` + `motor` | MongoDB ODM |
| `python-jose` | JWT |
| `passlib[bcrypt]` | Password hashing |
| `reportlab` | PDF generation |

---

## API Reference

<details>
<summary><strong>Authentication</strong></summary>

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | Login & get JWT |
| GET | `/auth/me` | Current user profile |
| POST | `/auth/logout` | Invalidate session |

</details>

<details>
<summary><strong>Announcements / Events / Timetable</strong></summary>

Standard CRUD on `/announcements/`, `/events/`, `/timetable/` — GET (list & single), POST/PUT/DELETE (admin only).

Extra timetable endpoints: `GET /timetable/day/{day}`, `GET /timetable/current`, `GET /timetable/export/json`, `GET /timetable/export/pdf`.

Extra events endpoint: `GET /events/upcoming`.

</details>

---

## Project Structure

```
smartcampus-companion/
├── frontend/               # Flutter app
│   └── lib/
│       ├── core/           # Constants, routes, themes, utils
│       ├── data/           # Models, remote API, local storage
│       ├── domain/         # Entities & repository interfaces
│       ├── presentation/   # Screens, widgets, Riverpod providers
│       └── services/       # Notifications, biometrics
│
├── backend/                # FastAPI
│   └── app/
│       ├── core/           # Config, DB, security
│       ├── models/         # Beanie ODM models
│       ├── schemas/        # Pydantic schemas
│       ├── routers/        # Route handlers
│       └── services/       # Business logic
│
├── docker-compose.yml
└── README.md
```

---

## Getting Started

**Prerequisites:** Flutter 3.16+, Python 3.11+, Docker Desktop

```bash
# 1. Start MongoDB
docker-compose up -d mongo

# 2. Backend
cd backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python seed.py && python seed_events.py && python seed_timetable.py
uvicorn main:app --reload --port 8000

# 3. Frontend
cd frontend
flutter pub get
flutter run
```

