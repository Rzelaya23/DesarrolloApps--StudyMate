import { Injectable } from '@nestjs/common';
import OpenAI from 'openai';

@Injectable()
export class AiService {
  private client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

  async answer(message: string, fileNames: string[]): Promise<string> {
    try {
      // Modo demo (por si estás sin créditos en OpenAI)
      if (process.env.AI_MOCK === 'true') {
        return 'Modo demo activo. Tu mensaje fue recibido y se procesará cuando la IA esté habilitada.';
      }

      const hint = fileNames.length ? `Archivos adjuntos: ${fileNames.join(', ')}.` : '';
      const content = [message, hint].filter(Boolean).join('\n\n');

      const res = await this.client.chat.completions.create({
        model: process.env.AI_MODEL || 'gpt-4o-mini',
        messages: [
          { role: 'system', content: 'Eres un asistente para organizar estudios, horarios y materias.' },
          { role: 'user', content }
        ],
        temperature: 0.3,
        max_tokens: 600,
      });

      const text = res.choices?.[0]?.message?.content?.trim() || '';
      return text || '(sin respuesta del servidor)';
    } catch (err: any) {
      if (err?.status === 429 || err?.code === 'insufficient_quota') {
        return 'No puedo responder ahora mismo porque el proveedor de IA alcanzó el límite de uso. Inténtalo más tarde o contacta al admin para recargar créditos.';
      }
      return 'Ocurrió un error al generar la respuesta. Intenta de nuevo en unos minutos.';
    }
  }
}
