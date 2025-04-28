# News Management Application

This project consists of a **backend** built with Node.js and a **frontend** built with Angular. The backend is containerized using Docker, and the frontend can be run locally.

---

## Prerequisites

Before starting, ensure you have the following installed on your machine:

- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: [Install Docker Compose](https://docs.docker.com/compose/install/)
- **Node.js**: [Install Node.js](https://nodejs.org/) (for running the Angular frontend)
- **Angular CLI**: Install globally using:
  ```bash
  npm install -g @angular/cli
  ```

---

## Backend Setup (Node.js with Docker)

### Step 1: Build the Docker Image
Navigate to the backend directory and build the Docker image:

```bash
cd backend
docker-compose build
```

### Step 2: Start the Containers
Start the backend and database containers using Docker Compose:

```bash
docker-compose up -d
```

This will:
- Start the **MySQL database** on port `3306`.
- Start the **backend API** on port `8082`.

### Step 3: Verify the Backend
Check if the backend is running by visiting: [http://localhost:8082](http://localhost:8082).

You should see a welcome message like:
```json
{
  "message": "Welcome to the News Management API",
  "version": "1.0.0"
}
```

### Step 4: Seed the Database (Optional)
If you need to populate the database with initial data (e.g., categories), run the seeder:

```bash
docker exec -it news-api node src/seeders/categorySeeder.js
```

---

## Frontend Setup (Angular)

### Step 1: Install Dependencies
Navigate to the frontend directory and install the required dependencies:

```bash
cd news
npm install
```

### Step 2: Start the Angular Development Server
Run the Angular application locally:

```bash
npm start
```

This will start the frontend on [http://localhost:4200](http://localhost:4200).

---

## Full Project Workflow

1. **Start the Backend**:
   ```bash
   cd backend
   docker-compose up -d
   ```

2. **Start the Frontend**:
   ```bash
   cd news
   npm start
   ```

3. Access the application:
   - **Frontend**: [http://localhost:4200](http://localhost:4200)
   - **Backend API**: [http://localhost:8082](http://localhost:8082)

---

## Troubleshooting

### Check Docker Logs
If you encounter issues with the backend, check the Docker logs:

```bash
docker-compose logs -f
```

### Restart Containers
If needed, restart the backend containers:

```bash
docker-compose down
docker-compose up -d
```

### Common Errors
- **Port Conflicts**: Ensure ports `8082` (backend) and `4200` (frontend) are not in use by other applications.
- **Database Connection Issues**: Verify the database container is running and accessible.

---

## Environment Variables

The backend uses environment variables for configuration. These are defined in the `.env` file in the `backend` directory:

```properties
# Database Configuration
DB_HOST=db
DB_USER=usuario_db
DB_PASS=contraseña_segura
DB_NAME=inventory_sales_db
DB_ROOT_PASSWORD=contraseña_root

# Server Configuration
PORT=8082
NODE_ENV=development

# Authentication
JWT_SECRET=izi_ventas_secret
JWT_EXPIRATION=1h
```

---

## Project Structure

### Backend
- **Language**: Node.js
- **Framework**: Express.js
- **Database**: MySQL
- **Containerization**: Docker

### Frontend
- **Language**: TypeScript
- **Framework**: Angular
- **Styling**: Angular Material

---

## License

This project is licensed under the MIT License.



