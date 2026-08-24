# LifeSync Games

Repository for the LifeSync Games (LSG) platform. LSG unifies several
game-related services behind a single sign-on: users authenticate once and move between
the showcase, the informational site and their multidimensional player profile.

This repository holds no application code of its own. Each service lives in its own
repository and is referenced here as a git submodule.

Deployed at [https://vitrina.diinf.usach.cl](https://vitrina.diinf.usach.cl)

## Architecture

All traffic enters through a single nginx reverse proxy, which terminates TLS and routes
by path prefix. Every service validates the JWTs issued by Auth Service using a shared
secret; Auth Service is the only component that issues them.

```
                        nginx reverse proxy
                     (TLS, routing, CORS, CSP)
                                |
   +-------------+--------------+--------------+---------------+
   |             |              |              |               |
 /home/      /vitrina/    /vitrina/api/v1/  /auth/api/v1/    /cloud/
   |             |              |              |               |
Difusion   Vitrina Front   Vitrina API    Auth Service    Cloud Module
(Vue 3)      (Vue 3)     (NestJS+Mongo)  (NestJS+Mongo)  (Vue 3 + 4 APIs)
                               |              |               |
                               +---- JWT -----+----- JWT -----+
```

Service-to-service calls that are not user-initiated authenticate with an API key sent in
the `x-api-key` header.

## Services

| Path in this repo           | Service                                                                         | Stack           | Route                    | Port |
| --------------------------- | ------------------------------------------------------------------------------- | --------------- | ------------------------ | ---- |
| `services/auth`             | [Auth Service](https://github.com/BlendedGames-bGames/lsg-auth-nest)            | NestJS, MongoDB | `/auth/api/v1/`          | 3000 |
| `services/vitrina-api`      | [Vitrina API](https://github.com/BlendedGames-bGames/lsg-vitrina-api)           | NestJS, MongoDB | `/vitrina/api/v1/`       | 3020 |
| `services/vitrina-frontend` | [Vitrina Frontend](https://github.com/BlendedGames-bGames/lsg-vitrina-frontend) | Vue 3, Vite     | `/vitrina/`              | 3007 |
| `services/difusion`         | [Difusion](https://github.com/BlendedGames-bGames/lsg-difusion)                 | Vue 3, Vite     | `/home/`                 | 3030 |
| `services/cloud/website`    | Cloud Profile Frontend                                                          | Vue 3, Vite     | `/cloud/`                | 8081 |
| `services/cloud/api-get`    | bGames GET Service (S01)                                                        | Node.js, MySQL  | `/cloud/api/get/`        | 3001 |
| `services/cloud/api-post`   | bGames POST Service (S02)                                                       | Node.js, MySQL  | `/cloud/api/post/`       | 3002 |
| `services/cloud/attributes` | bGames Standard Attributes (S10)                                                | Node.js, MySQL  | `/cloud/api/attributes/` | 3009 |
| `services/cloud/user-mgmt`  | bGames User Management (S11)                                                    | Node.js, MySQL  | `/cloud/api/users/`      | 3010 |

Ports are the ones each service listens on inside its container. The host ports used by a
given deployment are set in that deployment's compose file.

Auth Service, Vitrina API, Vitrina Frontend and Difusion each have their own repository.
The five Cloud Module services share a single repository,
[lsg-cloud-mod](https://github.com/BlendedGames-bGames/lsg-cloud-mod), with one branch per service
rather than one repository per service.

## Getting the code

```bash
git clone --recurse-submodules https://github.com/BlendedGames-bGames/LSG-Web.git
```

If you already cloned without the flag:

```bash
git submodule update --init --recursive
```

Each submodule is pinned to a specific commit, so a fresh clone always reproduces the same
state. To pull the latest commit of every service instead:

```bash
git submodule update --remote
```

That moves the pins in your working tree. Commit the result if you want the new set of
versions to become the recorded one.

Each service directory has its own README covering how to run it, its environment
variables and its tests.

## Deployment

`deploy/diinf/` has the Ansible playbook used to provision and configure a host: Docker,
nginx as reverse proxy (rate limiting, gzip, security headers including CSP), SSL via
Let's Encrypt, and the Cloud Module's MySQL bootstrap.

### What to fill in before deploying

1. `cp deploy/diinf/.env.example deploy/diinf/.env` and fill in the secrets.
   .
   - `MONGODB_URI`: connection string for the Mongo cluster shared by Auth and Vitrina API.
   - `JWT_SECRET`, `ENCRYPTION_KEY`: generate fresh random values, not reused from dev.
   - `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY`: Firebase Admin
     SDK service account credentials (backend, used if `AUTH_PROVIDER=firebase`).
   - `GITLAB_CLIENT_ID`/`SECRET`, `GITHUB_CLIENT_ID`/`SECRET`: OAuth apps registered with a
     callback URL matching `BASE_URL`.
   - `RESEND_API_KEY`: for moderation email notifications.
   - `VITE_FIREBASE_*`: Firebase client config, baked into the Vitrina Frontend build.
   - `CLOUD_MYSQL_ROOT_PASSWORD`: root password for the Cloud Module's MySQL container.
   - `BASE_URL`, `CORS_ORIGINS`, `ALLOWED_REDIRECT_ORIGINS`: set to the real domain.
2. In `deploy/diinf/ansible/playbooks/deploy_diinf.yml`, update `server_name` to the real
   domain and `admin_email` for the Let's Encrypt certificate. Every other variable
   (ports, routing prefixes, image tags) is documented inline and only needs to change if
   the topology itself changes.

### Running it

```bash
cd deploy/diinf
sudo ANSIBLE_ROLES_PATH=ansible/roles ansible-playbook \
  ansible/playbooks/deploy_diinf.yml -i ansible/inventory/hosts.ini
```

Roles are tagged, so `--tags nginx` reconfigures only the reverse proxy without touching
Docker, the firewall or certificates.
