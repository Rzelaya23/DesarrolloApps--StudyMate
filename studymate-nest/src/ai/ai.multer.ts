import { diskStorage } from 'multer';
import { extname } from 'path';

export const aiUploadsMulter = {
  storage: diskStorage({
    destination: 'uploads/ai',
    filename: (_, file, cb) => {
      const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
      const ext = extname(file.originalname || '');
      cb(null, unique + ext);
    },
  }),
  limits: {
    files: Number(process.env.AI_MAX_ATTACHMENTS || 5),
    fileSize: Number(process.env.AI_MAX_FILE_SIZE_MB || 15) * 1024 * 1024,
  },
};
