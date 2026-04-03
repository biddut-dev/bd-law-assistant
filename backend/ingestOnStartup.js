const fs = require('fs');
const path = require('path');
const Law = require('./models/Law');

async function ingestData() {
  const count = await Law.countDocuments();
  if (count > 0) {
    console.log(`Database already has ${count} records. Skipping ingestion.`);
    return;
  }

  console.log('Starting ingestion from local JSON files...');

  const penalCodePath = path.join(__dirname, '../laws/penal-code.json');
  if (fs.existsSync(penalCodePath)) {
    const rawData = fs.readFileSync(penalCodePath, 'utf8');
    const records = JSON.parse(rawData);
    
    const laws = records.map(r => ({
      law_name_en: r.law_name_en,
      chapter_no_en: r.chapter_no_en,
      chapter_name_en: r.chapter_name_en,
      section_no_en: r.section_no_en,
      section_name_en: r.section_name_en,
      content: r.content,
      source: 'penal_code'
    }));

    await Law.insertMany(laws);
    console.log(`Ingested ${laws.length} records from Penal Code.`);
  }

  const legalActsPath = path.join(__dirname, '../laws/Contextualized_Bangladesh_Legal_Acts.json');
  if (fs.existsSync(legalActsPath)) {
    const rawData = fs.readFileSync(legalActsPath, 'utf8');
    const dataset = JSON.parse(rawData);

    // Limit to first 100 acts to save memory/time for initial demo, but we can do all if needed.
    // The dataset is 61MB so it shouldn't be a problem, but insertMany in chunks.
    let actsToIngest = [];
    
    for (const act of dataset.acts) {
      if (act.sections && Array.isArray(act.sections)) {
        act.sections.forEach((sec, idx) => {
          actsToIngest.push({
            law_name_en: act.act_title,
            act_title: act.act_title,
            act_no: act.act_no,
            act_year: act.act_year,
            section_no_en: (idx + 1).toString(), // Simplified, text might not have explicit numbers
            content: sec.section_content,
            source: 'legal_acts',
            metadata: {
              govt_context: act.government_context,
              legal_system: act.legal_system_context
            }
          });
        });
      }
    }

    // Insert in chunks of 500
    const chunkSize = 500;
    for (let i = 0; i < actsToIngest.length; i += chunkSize) {
      const chunk = actsToIngest.slice(i, i + chunkSize);
      await Law.insertMany(chunk);
    }
    console.log(`Ingested ${actsToIngest.length} section records from Legal Acts.`);
  }
}

module.exports = ingestData;
