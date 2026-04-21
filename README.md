# Cinema Streaming Platform – Microservices Architecture

![Architecture](https://img.shields.io/badge/Architecture-Microservices-blue)
![Orchestration](https://img.shields.io/badge/Orchestration-Docker_Compose-2496ED?logo=docker)
![Gateway](https://img.shields.io/badge/API_Gateway-Nginx-009639?logo=nginx)
![Backend](https://img.shields.io/badge/Backend-Node.js_|_Express-339933?logo=nodedotjs)
![Database](https://img.shields.io/badge/Database-Firestore-FFCA28?logo=firebase)

A production-ready streaming platform demonstrating modern **Cloud Engineering** and **DevOps** principles. This project was successfully migrated from a monolithic architecture into a highly scalable, containerized microservices ecosystem. 

It implements the **API Gateway pattern**, robust inter-container networking, strict boundary decoupling, and secure server-side JWT authentication.

---

##  Key DevOps & Engineering Achievements

*   **Microservices Decoupling**: Separated the monolithic React+Firebase application into distinct functional domains (Catalog vs. User Data). Removed direct database write access from the client, migrating all state mutations to a secure Node.js backend.
*   **Container Orchestration**: Utilized `docker-compose` to manage a multi-container environment with isolated bridged networks, environment variable injection, and optimized memory constraints to prevent OOM errors.
*   **API Gateway Implementation**: Engineered an Nginx reverse proxy to route traffic dynamically, enforce CORS headers, and unify multiple backend microservices under a single external port.
*   **Server-Side Security**: Transitioned from client-side database rules to Server-side Firebase Admin SDK integration. Implemented custom Express middleware to verify JWTs (JSON Web Tokens) on every protected route.

---

##  System Architecture

The application is composed of four primary containers connected via an internal Docker bridge network (`movie-network`).

```text
                  +----------------------------------+
                  |                                  |
                  |     Frontend Client (React)      |
                  |     http://localhost:5173        |
                  |                                  |
                  +-------+------------------+-------+
                          |                  |
                    (Read-Only)         (Mutations)
                 Firestore Stream        HTTP POST/DELETE
                          |                  |
                          |                  v
                          |     +-------------------------+
                          |     |                         |
                          |     |   API Gateway (Nginx)   |  <-- Port 8080
                          |     |                         |
                          |     +----+---------------+----+
                          |          |               |
                          |      /api/tmdb       /api/user
                          |          |               |
+--------------------+    |          v               v
|                    |    |   +--------------+ +--------------+
| Cloud Firestore DB |<---+   | Catalog SvC  | |   User SvC   |
|                    |<-------| (Node.js)    | |  (Node.js)   |
+--------------------+        +------+-------+ +-------+------+
                                     |                 |
                                     v                 v
                              +------------+   +----------------+
                              | TMDB API   |   | Firebase Admin |
                              +------------+   +----------------+
```

### Component Breakdown

1.  **Gateway Service (Nginx)**: The single entry point for all API traffic. It intercepts requests, attaches necessary cross-origin headers, and proxies requests to internal upstream servers (`catalog-service:5001` and `user-service:5002`) based on the URL path.
2.  **Catalog Service (Node.js/Express)**: A stateless proxy service that securely stores the TMDB API key and handles complex querying, filtering, and caching of external movie metadata.
3.  **User Service (Node.js/Express)**: A stateful microservice responsible for all user-specific data mutations (Registration, Favorites, Watch Progress). It authenticates requests via JWTs and securely interacts with Firestore using the `firebase-admin` SDK.
4.  **Frontend Service (React/Vite)**: A lightweight, pure-UI presentation layer. It utilizes `AuthContext` for real-time reads but delegates all data writes to the Gateway.

---

##  Security Model

*   **JWT Verification**: When a user logs in via Firebase Auth on the frontend, an ID token is generated. This token is passed in the `Authorization: Bearer <token>` header to the Gateway. The User Service validates this token cryptography using `admin.auth().verifyIdToken()` before processing any requests.
*   **Credential Isolation**: The `serviceAccountKey.json` is securely mounted directly into the `user-service` container, completely isolating database write credentials from the public internet and frontend codebase.
*   **CORS Enforcement**: The Nginx gateway explicitly defines allowed origins, methods, and headers, blocking unauthorized cross-origin requests.

---

##  Technologies Used

*   **Orchestration & Containers**: Docker, Docker Compose
*   **API Gateway**: Nginx
*   **Backend Microservices**: Node.js, Express.js
*   **Authentication**: Firebase Auth, JWT
*   **Database**: Google Cloud Firestore (NoSQL), Firebase Admin SDK
*   **Frontend**: React, Vite, CSS Modules
*   **External APIs**: TMDB (The Movie Database) API

---

##  Running the Cluster Locally

Prerequisites: Ensure you have [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/) installed on your machine.

**1. Clone the repository**
```bash
git clone https://github.com/PasiAbey/Cinema---Movie-Streaming-Platform.git
cd movie-streamer-microservices
```

**2. Configure Environment Variables**
Create a `.env` file in the root directory:
```env
VITE_API_URL=http://localhost:8080
VITE_FIREBASE_PROJECT_ID=your_project_id
TMDB_API_KEY=your_tmdb_api_key
PORT=5001
```

**3. Provide Firebase Admin Credentials**
Place your `serviceAccountKey.json` file inside the `services/user-service/` directory.

**4. Spin up the cluster**
Use Docker Compose to build the images and launch the isolated network. This single command will start the Gateway, Catalog Service, User Service, and the Frontend.
```bash
docker-compose up --build -d
```

**5. Access the Application**
Once the containers are running, you can access the platform at:
*   **Frontend**: `http://localhost:5173`
*   **API Gateway**: `http://localhost:8080`
