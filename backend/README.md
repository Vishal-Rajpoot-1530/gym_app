# Power Cave API — NestJS + Prisma + MySQL

Backend stack: NestJS, Prisma ORM, MySQL, JWT, bcrypt, Multer.

## Start
1. Copy `.env.example` to `.env` and set `DATABASE_URL`, `JWT_SECRET`, and a strong `SUPER_ADMIN_KEY`.
2. `npm install`
3. `npx prisma generate`
4. `npx prisma migrate dev --name init` (local development)
5. `npm run start:dev`

Account creation is provisioned outside the mobile app. `POST /api/v1/auth/register`
requires the `x-super-admin-key` header and creates online accounts only. The
mobile app authenticates through the API and stores gym business data on the
server; it has no local SQLite store or demo login.

Flutter API contract remains `/api/v1`. Configure with:
- Android emulator (also the app's default): `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1`
- Physical device via USB: `adb reverse tcp:3000 tcp:3000` then `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1`
- Wi‑Fi/LAN: `flutter run --dart-define=API_BASE_URL=http://YOUR_HOST:3000/api/v1`

Do not use `127.0.0.1` on a real phone unless you have configured `adb reverse`.

For production use HTTPS, run `npx prisma migrate deploy`, build with `npm run build`, and start `node dist/main.js`.
