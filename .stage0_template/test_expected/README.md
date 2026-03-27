# Mentor Hub — Sample SPA

This repository contains a Vue 3 single-page application (SPA) for the sample service.

## Prerequisites
- Mentor Hub [Developers Edition](https://github.com/agile-learning-institute/mentorhub/blob/main/CONTRIBUTING.md)
- Developer [SPA Standard Prerequisites](https://github.com/agile-learning-institute/mentorhub/blob/main/DeveloperEdition/standards/spa_standards.md)

## Dependency: `spa_utils` (git install, not the npm registry)

`@agile-learning-institute/mentorhub_spa_utils` is declared in **`package.json`** as a **GitHub git dependency** (`github:agile-learning-institute/mentorhub_spa_utils#main`). `npm install` clones that repository and runs its `prepare` script to build **`dist/`**. There is **no** semver range like `^0.1.0`; bump the branch or tag in **`package.json`** when you want a new revision.

- **Public `spa_utils` repo:** local and CI installs work without credentials.
- **Private `spa_utils` repo:** use a credential git understands locally (`gh auth setup-git`, or a PAT). For **Docker / `npm run container`**, export **`GITHUB_TOKEN`** (or **`NODE_AUTH_TOKEN`** as a fallback) so the image build can clone the library.
- **GitHub Actions:** **`docker-push.yml`** passes **`secrets.GITHUB_TOKEN`** into the Docker build as **`GITHUB_TOKEN`**. The default job token can read **other private repos in the same org** only if your repository/org [allows Actions access to depend on private inner-source repos](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#allowing-access-to-components-in-a-private-repository); otherwise make **`mentorhub_spa_utils`** public or use a PAT secret. This avoids **GitHub Packages** “Manage Actions access”, which cannot be automated for npm.

Optional: **`mentorhub_spa_utils`** may still be published to **`npm.pkg.github.com`** during umbrella launch for teams that want registry semver later; the SPA template does not consume that package by default.

## `package-lock.json`

The generated repository does **not** ship with **`package-lock.json`**. After you clone or merge the template, run **`npm install`** once to create it (and commit it to the repo afterward). Until the lockfile exists, the Docker build uses **`npm install`**; once **`package-lock.json`** is present, builds use **`npm ci`** so image installs match your machine and CI.

## Quick Start

```sh
## Just run the service
npm run service 
```

## Developer Commands

```sh
## install dependencies
npm install 

## package code for deployment
npm run build 

## run dev server, assumes api is running - captures command line
npm run dev 

## run unit tests
npm run test

## run unit tests with coverage
npm run test:coverage

## run unit tests with UI
npm run test:ui

## run Cypress E2E tests
npm run cypress

## run Cypress E2E tests headlessly
npm run cypress:run

## de down and start db + api containers
npm run api 

## de down and start db + api + spa containers and open 
npm run service 

## open page in the browser
npm run open

## Build SPA docker container locally
npm run container 
```

## Architecture Overview

```
src/
  api/              # API client layer (types.ts, client.ts)
  components/       # App-specific UI components (admin components)
  pages/            # Route-level components (List, New, Edit/View pages)
  composables/      # App-specific composables (useAuth, useConfig, useRoles wrapper)
  stores/           # Pinia stores (UI state only)
  router/           # Vue Router configuration
  plugins/          # Vuetify plugin configuration
```

**Note**: This template uses `@agile-learning-institute/mentorhub_spa_utils` for reusable components, composables, and utilities. See the [spa_utils README](../spa_utils/README.md) for complete documentation on available components (`AutoSaveField`, `AutoSaveSelect`, `ListPageSearch`), composables (`useResourceList`, `useErrorHandler`, `useRoles`), and utilities (`formatDate`, `validationRules`).

## Domain Model

This template implements three domains:

### Control Domain
- **List Page** (`/controls`) - Searchable data table with query support
- **New Page** (`/controls/new`) - Form with required fields only
- **Edit Page** (`/controls/:id`) - Full form with save-on-blur for each field

### Create Domain
- **List Page** (`/creates`) - Data table listing all creates
- **New Page** (`/creates/new`) - Form with all properties
- **View Page** (`/creates/:id`) - Read-only detail view

### Consume Domain
- **List Page** (`/consumes`) - Searchable data table with query support
- **View Page** (`/consumes/:id`) - Read-only detail view

## Key Implementation Patterns

### Authentication
- JWT tokens stored in localStorage (`access_token`, `token_expires_at`)
- `useAuth()` composable manages authentication state
- Sign-in uses IdP / URL hash (`bootstrapDevAuthFromUrl`); there is no `/dev-login` proxy
- Router guards protect routes requiring authentication

### API Client
- Located in `src/api/client.ts`
- All API calls include JWT token from localStorage
- Error handling via `ApiError` class
- Type-safe with TypeScript interfaces in `src/api/types.ts`

### Data Fetching
- Uses TanStack Query (Vue Query) for server state management
- Query keys follow pattern: `['resource', id]` or `['resources']`
- Mutations invalidate related queries on success
- Use `useResourceList` composable from `spa_utils` for list pages with search support
- Example: `useQuery({ queryKey: ['control', id], queryFn: () => api.getControl(id) })`

### Reusable Components and Composables
This template uses components and composables from `@agile-learning-institute/mentorhub_spa_utils`:
- **Components**: `AutoSaveField`, `AutoSaveSelect`, `ListPageSearch`
- **Composables**: `useResourceList`, `useErrorHandler`, `useRoles`
- **Utilities**: `formatDate`, `validationRules`

See the [spa_utils README](../spa_utils/README.md) for complete documentation and usage examples.

### Component Architecture
- **Pages**: Own routing, data fetching, and mutations. Pass data + callbacks to components.
- **Components**: App-specific components (admin components). Reusable components come from `spa_utils`.
- **Composables**: App-specific logic (authentication, config). Reusable composables come from `spa_utils`.
- **Stores**: UI-only state (loading, error messages, etc.)

## Testing

### Unit Tests
- Uses Vitest for unit testing
- Test coverage target: 90%
- Tests cover: API client, composables, and components
- Run tests: `npm run test`
- Coverage report: `npm run test:coverage`

### E2E Tests
- Uses Cypress for end-to-end testing
- Tests cover main user flows: login, CRUD operations for each domain
- Run tests: `npm run cypress` (interactive) or `npm run cypress:run` (headless)

## Adding New Features

When adding a new resource or feature:

1. **Add API Types**: Extend `src/api/types.ts` with new interfaces
2. **Add API Methods**: Add methods to `src/api/client.ts`
3. **Create Pages**: Follow the appropriate pattern (List/New/Edit or List/New/View)
4. **Add Routes**: Register routes in `src/router/index.ts`
5. **Use spa_utils Components**: For edit pages with PATCH support, use `AutoSaveField`/`AutoSaveSelect` from `spa_utils`. For list pages, use `useResourceList` and `ListPageSearch`.
6. **Query Management**: Use Vue Query for data fetching with appropriate query keys
7. **Cache Invalidation**: Invalidate related queries in mutation `onSuccess` callbacks
8. **Error Handling**: Use `useErrorHandler` from `spa_utils` for consistent error handling
9. **Write Tests**: Add unit tests and E2E tests for new functionality (note: common components are tested in `spa_utils`)

## Technology Stack
- Vue 3 with Composition API
- TypeScript 5.9
- Vite 7.2
- Vuetify 3.11
- Vue Router 4
- Pinia 3
- TanStack Query (Vue Query) v5
- Vitest v3 (unit testing)
- Cypress v15.8 (E2E testing)

## Automation Support

All interactive elements in this SPA include `data-automation-id` attributes following the `{domain}-{page}-{element}` naming convention.

## CI (`.github/workflows/docker-push.yml`)

**GHCR** push and **`npm install`** from GitHub Packages both use the workflow’s automatic **`secrets.GITHUB_TOKEN`**. Ensure the **`mentorhub_spa_utils`** GitHub Package grants **Actions access** to this SPA repository (see **Dependency** above).

## Configuration
- Runtime configuration available at `/api/config` endpoint
- Use enumerator values from config, not hardcoded in OpenAPI spec
- Docker container uses `API_HOST` and `API_PORT` environment variables for API proxy configuration
- Container listens on port 80 internally; map host port to container port 80 (e.g., `8185:80` in docker-compose)