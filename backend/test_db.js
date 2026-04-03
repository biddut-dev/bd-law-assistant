const mongoose = require('mongoose');

async function testConnection() {
  const uri1 = 'mongodb+srv://biddut24215511_db_user:%28%40AbuFahad%23%29@bdlaw.ffbbomt.mongodb.net/test?retryWrites=true&w=majority&appName=bdlaw';
  const uri2 = 'mongodb+srv://biddut24215511_db_user:%40AbuFahad%23@bdlaw.ffbbomt.mongodb.net/test?retryWrites=true&w=majority&appName=bdlaw';

  try {
    console.log("Trying password with parentheses...");
    await mongoose.connect(uri1, { serverSelectionTimeoutMS: 5000 });
    console.log("SUCCESS with parentheses!");
    process.exit(0);
  } catch (e) {
    console.log("Failed with parentheses. Error: " + e.message);
  }

  try {
    console.log("\nTrying password without parentheses...");
    await mongoose.connect(uri2, { serverSelectionTimeoutMS: 5000 });
    console.log("SUCCESS without parentheses!");
    process.exit(0);
  } catch (e) {
    console.log("Failed without parentheses. Error: " + e.message);
    process.exit(1);
  }
}

testConnection();
