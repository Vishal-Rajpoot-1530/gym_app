# gym_app

The app requires the separate `gym-services-api` backend to be running on port
3001. Web and desktop builds use `http://localhost:3001/api/v1` by default;
Android emulators use `http://10.0.2.2:3001/api/v1`.

For a physical device or another backend host, configure the API root at
launch/build time:

```shell
flutter run --dart-define=GYM_API_BASE_URL=http://YOUR_HOST:3001/api/v1
```

Log in using an existing active gym administrator account provisioned on the
backend.

In debug builds, **Try Demo User** signs in to a seeded development account.
From `gym-services-api`, prepare it with `npm run demo:seed` after applying the
database migrations. Demo credentials are `demo@gymtest.com` /
`GymDemo123!`. The seed command refuses to run in production; do not use the
demo account for a production deployment.

Use HTTPS for deployed environments.

## Web

The Gym web app uses port `5501`:

```powershell
flutter run -d web-server --web-port 5501
```

Open `http://localhost:5501`. In VS Code, select **Gym Web (5501)** in Run and
Debug. The backend's `CORS_ORIGIN` must include the exact web app origin,
including its port. If VS Code uses a forwarded port, allow that origin too.
