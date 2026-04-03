const express = require('express');
const router = express.Router();
const { GoogleGenAI } = require('@google/genai');
const Law = require('../models/Law');

// Initialize Gemini client (make sure GEMINI_API_KEY is in .env)
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
const model = 'gemini-2.5-flash';

// Helper to escape regex
function escapeRegex(text) {
  return text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
}

// GET /search-law?keyword=...&act=...&section=...
router.get('/search-law', async (req, res) => {
  try {
    const { keyword, act, section } = req.query;
    
    let query = {};
    if (keyword) {
      query.$text = { $search: keyword };
    }
    if (act) {
      // Allow partial case-insensitive match for act title/law name
      query.$or = [
        { law_name_en: { $regex: new RegExp(escapeRegex(act), 'i') } },
        { act_title: { $regex: new RegExp(escapeRegex(act), 'i') } }
      ];
    }
    if (section) {
      query.section_no_en = section;
    }

    const sortOpt = keyword ? { score: { $meta: "textScore" } } : { _id: 1 };
    
    const results = await Law.find(query)
                             .sort(sortOpt)
                             .limit(20);

    res.json(results);
  } catch (error) {
    console.error('Error in /search-law:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /ask-law
// Body: { question: "What happens if I steal?" }
router.post('/ask-law', async (req, res) => {
  try {
    const { question } = req.body;
    if (!question) {
      return res.status(400).json({ error: 'Question is required' });
    }

    // Step 1: simple semantic search via keywords, but text search is what we have right now.
    // Without embeddings, let's extract keywords or just use text search for the entire question directly.
    // Or simpler, ask AI to generate search queries first? No, for speed we just search directly,
    // or retrieve a lot of general content. To make it more robust, we will do a basic keyword match
    // since `$text` matches anything with any of the words.
    
    const results = await Law.find(
      { $text: { $search: question } },
      { score: { $meta: "textScore" } }
    ).sort({ score: { $meta: "textScore" } }).limit(5);

    let contextText = '';
    if (results.length > 0) {
      // Format top matches for the context
      contextText = results.map(r => `
Law/Act Name: ${r.law_name_en || r.act_title}
Section Number: ${r.section_no_en || 'N/A'}
Section Title: ${r.section_name_en || 'N/A'}
Content: ${r.content}
`).join('\n---\n');
    } else {
      // If text search doesn't match, maybe we can query without it? Let's assume text search works well enough
      contextText = "No exact sections found based on keyword matching.";
    }

    // Step 2: Use AI to answer
    const prompt = `You are a Bangladesh legal assistant.
Answer ONLY based on the provided law context. If unsure or no relevant context is provided, say: "No exact law found".
Format your answer clearly, for example:
- Law Name: ...
- Section Number: ...
- Explanation: ...
- Punishment: ...

Context:
${contextText}

User Question: ${question}
`;

    const response = await ai.models.generateContent({
        model: model,
        contents: prompt
    });

    res.json({ answer: response.text, contextUsed: results });

  } catch (error) {
    console.error('Error in /ask-law:', error);
    if (error.status === 429) {
      return res.json({ answer: 'API Rate limit exceeded. Please check your Gemini API key quota or try again in a few moments.', contextUsed: [] });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
