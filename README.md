# gym_app

The gym app connects to `gym-services-api` using the API root
`http://192.168.1.43:3001/api/v1` by default for the development phone on the
current Wi-Fi network. Change this address if the computer's LAN IP changes.
Log in using an existing active gym administrator account provisioned on the
backend.

In debug builds, **Try Demo User** signs in to a seeded development account.
From `gym-services-api`, prepare it with `npm run demo:seed` after applying the
database migrations. Demo credentials are `demo@gymtest.com` /
`GymDemo123!`. The seed command refuses to run in production; do not use the
demo account for a production deployment.

For other environments, provide the API root at run/build time:

```powershell
flutter run --dart-define=GYM_API_BASE_URL=http://YOUR_HOST:3001/api/v1
```

For an Android emulator, use `http://10.0.2.2:3001/api/v1`; for desktop/web on
the API host, use `http://localhost:3001/api/v1`. For a physical device, use
the host computer's LAN IP and ensure the API is listening on the LAN interface.
Use HTTPS for deployed environments.

## Web

The Gym web app uses port `5501`:

```powershell
flutter run -d web-server --web-port 5501
```

Open `http://localhost:5501`. In VS Code, select **Gym Web (5501)** in Run and
Debug. For Flutter Web API requests, allow `http://localhost:5501` in the Gym
backend's `CORS_ORIGIN`.
