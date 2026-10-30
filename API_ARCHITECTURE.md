# Power Cave API Architecture

## Flutter
- `lib/api/api_config.dart` - base URL and timeout
- `lib/api/api_endpoints.dart` - centralized endpoint definitions
- `lib/api/api_exception.dart` - normalized API/network errors
- `lib/api/api_client.dart` - HTTP/JWT/multipart/logging layer
- `lib/db/app_db.dart` - API-backed business-data access

All gym business data is accessed through the API and stored on the server.
The app has no local SQLite store or demo login. Account creation requires the
`x-super-admin-key` header, configured using `SUPER_ADMIN_KEY` in the backend
environment; only online accounts are supported. Never ship this key in the
mobile app.

The app's `GYM_API_BASE_URL` setting always resolves to the Gym service on port
`3001`; it does not use the Physio backend configuration.

### Request logs
Run Flutter with `flutter run`. Every request prints:
`[API] --> GET http://.../api/v1/members`
`[API] <-- GET /members [200] 42ms`

## NestJS
- Feature modules: `auth`, `members`, `finance`, `settings`, `checkins`
- `prisma` - MySQL access
- `common/request-logger.middleware.ts` - incoming API logs

Run `npm run start:dev`; each hit prints method, URL, HTTP status and duration.

## Empty member behavior
`GET /api/v1/members` returning `[]` renders the existing Members empty state: `No members yet...`. It never injects demo members.
