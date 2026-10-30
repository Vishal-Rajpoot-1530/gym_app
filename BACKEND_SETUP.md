# Power Cave — NestJS + Prisma + MySQL Setup

## 1. MySQL
Create an empty database:
```sql
CREATE DATABASE power_cave CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## 2. Backend
```bash
cd backend
npm install
copy .env.example .env   # Windows
# cp .env.example .env  # macOS/Linux
```
Edit `.env` and set your MySQL password, a strong JWT secret, and a strong
`SUPER_ADMIN_KEY`. The API requires that key in the `x-super-admin-key` header
when creating accounts; the mobile app has no signup screen. Provision an
online account by calling `POST /api/v1/auth/register` with `name`, `email`,
and `password`. Keep the key in the super-admin tool only; never include it in
the Flutter app. For example:
```http
POST /api/v1/auth/register
Content-Type: application/json
x-super-admin-key: <SUPER_ADMIN_KEY>

{"name":"Gym Account","email":"owner@example.com","password":"<password>"}
```
Then:
```bash
npx prisma generate
npx prisma migrate dev --name init
npm run start:dev
```
Gym API base: `http://localhost:3001/api/v1`

## 3. Flutter
The default Gym API URL targets the backend on port 3001 from an Android emulator
(`10.0.2.2` maps to the host computer). You can also set it explicitly:
```bash
flutter run --dart-define=GYM_API_BASE_URL=http://10.0.2.2:3001/api/v1
```
For physical Android devices over USB, use adb reverse so the device points to your computer:
```bash
adb reverse tcp:3001 tcp:3001
flutter run --dart-define=GYM_API_BASE_URL=http://127.0.0.1:3001/api/v1
```
For Wi‑Fi/device-server access, replace `127.0.0.1` with your PC's LAN IP, example: `http://192.168.1.25:3001/api/v1`.

Important: `127.0.0.1` points to the phone itself, not the backend server running on your laptop/desktop.

## Production
Use HTTPS and a production `DATABASE_URL`. Run `npx prisma migrate deploy`, `npm run build`, then `node dist/main.js` (or PM2). Keep `.env` out of Git. Back up MySQL and the `backend/uploads/` directory.

## Data safety
Gym business data is stored in MySQL. The app has no local SQLite store or demo
login. SharedPreferences stores session metadata and the API JWT. Member images
live in `backend/uploads/`; their paths are stored in MySQL.
