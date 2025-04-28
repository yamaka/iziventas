import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import dotenv from "dotenv";

import { connectDatabase } from "./config/database.js";

import authRoutes from "./modules/auth/routes/authRoutes.js";

import newsRoutes from "./modules/news/routes/newsRoutes.js";

import { errorHandler } from "./middleware/errorHandler.js";

dotenv.config();

class App {
  constructor() {
    this.app = express();
    this.initializeMiddlewares();
    this.initializeRoutes();
    this.initializeErrorHandling();
  }

  initializeMiddlewares() {
    this.app.use(helmet());

    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: true }));

    this.app.use(
      cors({
        origin: process.env.CORS_ORIGIN || "*",
        methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
        allowedHeaders: ["Content-Type", "Authorization"],
      })
    );

    const limiter = rateLimit({
      windowMs: 15 * 60 * 1000,
      max: 100,
      message: "Too many requests, please try again later",
    });
    this.app.use(limiter);
  }

  initializeRoutes() {
    this.app.get("/", (req, res) => {
      res.json({
        message: "Welcome to the News Management API",
        version: "1.0.0",
      });
    });

    this.app.use("/api/auth", authRoutes);
    // this.app.use("/api/categories", authRoutes);
    this.app.use("/api/news", newsRoutes);

    this.app.use((req, res, next) => {
      res.status(404).json({
        message: "Route not found",
      });
    });
  }

  initializeErrorHandling() {
    this.app.use(errorHandler);
  }

  async start() {
    const PORT = process.env.PORT || 8082; // Default to 8082 if not set

    try {
      await connectDatabase();

      this.app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
        console.log(`Environment: ${process.env.NODE_ENV}`);
      });
    } catch (error) {
      console.error("Error starting the application:", error);
      process.exit(1);
    }
  }

  getApp() {
    return this.app;
  }
}

const app = new App();

export default app;

if (import.meta.url === `file://${process.argv[1]}`) {
  app.start();
}
