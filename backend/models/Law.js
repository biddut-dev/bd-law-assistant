const mongoose = require('mongoose');

const lawSchema = new mongoose.Schema({
  law_name_en: { type: String },
  chapter_no_en: { type: String },
  chapter_name_en: { type: String },
  section_no_en: { type: String },
  section_name_en: { type: String },
  content: { type: String },
  // Additional fields for the Acts dataset
  act_title: { type: String },
  act_no: { type: String },
  act_year: { type: String },
  source: { type: String, required: true }, // 'penal_code' or 'legal_act'
  metadata: { type: mongoose.Schema.Types.Mixed }
});

// Create text index for search
lawSchema.index({ 
  law_name_en: 'text',
  section_name_en: 'text',
  content: 'text',
  act_title: 'text'
});

module.exports = mongoose.model('Law', lawSchema);
