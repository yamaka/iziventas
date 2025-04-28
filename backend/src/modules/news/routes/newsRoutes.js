import express from 'express';

import NewsController from '../controllers/newsController.js';

import { authMiddleware } from '../../../middleware/authMiddleware.js';

const router = express.Router();

// Rutas protegidas por autenticación
router.use(authMiddleware);

// Create a news post
router.post('', NewsController.createNews);

// Get all news posts
router.get('', NewsController.getAllNews);
// Get a news post by ID
router.get('/:id', NewsController.getNewsById);

// Update a news post
router.put('/:id', NewsController.updateNews);

// Delete a news post
router.delete('/:id', NewsController.deleteNews);

export default router;