# TeamFlow Frontend

Angular-based frontend for the TeamFlow project management platform.

**Stack**: Angular 21 + TypeScript 5.9 + Material Design

---

## Quick Start

### Prerequisites

- Node.js 20+ (`node --version`)
- npm (`npm --version`)
- Git

### Setup (5 minutes)

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Configure environment**:
   
   Create `src/environments/environment.development.ts`:
   ```typescript
   export const environment = {
     environment: 'development',
     apiUrl: 'https://twq76p7zj4.execute-api.us-east-1.amazonaws.com/dev'
   };
   ```
   
   Replace the `apiUrl` with your cloud API Gateway URL (from AWS deployment).

3. **Start dev server**:
   ```bash
   ng serve
   ```
   
   Open [http://localhost:4200](http://localhost:4200)

### Verify Setup

Open browser DevTools Console (F12). You should see:
```
✅ API Service initialized
📡 API Endpoint: https://...
```

Click "Get started" button. Console should show API response from cloud backend.

---

## Development

### Development server

To start a local development server, run:

```bash
ng serve
```

Once the server is running, open your browser and navigate to `http://localhost:4200/`. The application will automatically reload whenever you modify any of the source files.

### Code scaffolding

Angular CLI includes powerful code scaffolding tools. To generate a new component, run:

```bash
ng generate component component-name
```

For a complete list of available schematics (such as `components`, `directives`, or `pipes`), run:

```bash
ng generate --help
```

### Building

To build the project run:

```bash
ng build
```

This will compile your project and store the build artifacts in the `dist/` directory. By default, the production build optimizes your application for performance and speed.

### Running unit tests

To execute unit tests with the [Vitest](https://vitest.dev/) test runner, use the following command:

```bash
ng test
```

### Running end-to-end tests

For end-to-end (e2e) testing, run:

```bash
ng e2e
```

Angular CLI does not come with an end-to-end testing framework by default. You can choose one that suits your needs.

---

## Troubleshooting

### CORS Errors

If you see CORS errors in browser console:
- **Cause**: API Gateway not configured for CORS
- **Solution**: Check backend CDKTF stack for CORS configuration

### API URL Not Found (404)

If API calls return 404:
- Check `environment.development.ts` has correct API Gateway URL
- Verify URL format: `https://{api-id}.execute-api.us-east-1.amazonaws.com/dev`
- Confirm backend is deployed (`npm run deploy` in infrastructure folder)

### "Cannot GET /api/home"

If you get this error:
- Backend endpoint might not be deployed
- Check AWS Lambda function exists: `teamflow-get-home-dev`
- Check API Gateway route: `/api/home`

### Port Already in Use

If port 4200 is busy:
```bash
# Kill process on port 4200
lsof -ti:4200 | xargs kill -9

# Or use different port
ng serve --port 4201
```

---

## Additional Resources

For more information on using the Angular CLI, including detailed command references, visit the [Angular CLI Overview and Command Reference](https://angular.dev/tools/cli) page.
