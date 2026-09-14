const https = require('https');



const prompt = `Pass the list of our specific Primary Specialties (General Practice, Gynecology, Pediatrics, Psychiatry, Dermatology, Internal Medicine, Cardiology, Other) and dynamically return a clean JSON array containing at least 4 realistic medical courses for each specialty.
Each course object generated must include:
- title: string
- specialty: string (must be one of the provided list: General Practice, Gynecology, Pediatrics, Psychiatry, Dermatology, Internal Medicine, Cardiology, Other)
- instructor: string (e.g., "Dr. Mohammad Taha")
- duration: string (e.g., "15h" or "15 hours")
- lecturesCount: number

Return the output as a valid JSON array directly. Do not wrap it in markdown formatting like \`\`\`json.`;

const data = JSON.stringify({
  contents: [{
    parts: [{
      text: prompt
    }]
  }],
  generationConfig: {
    responseMimeType: "application/json"
  }
});

const options = {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  }
};

const req = https.request(url, options, (res) => {
  let responseData = '';
  res.on('data', (chunk) => {
    responseData += chunk;
  });
  res.on('end', () => {
    console.log('Status Code:', res.statusCode);
    try {
      const parsed = JSON.parse(responseData);
      const text = parsed.candidates[0].content.parts[0].text;
      console.log('Generated Text:', text);
      const courses = JSON.parse(text);
      console.log('Successfully parsed courses, count:', courses.length);
      console.log('First course:', courses[0]);
    } catch(err) {
      console.log('Parsing failed. Error:', err);
      console.log('Response:', responseData);
    }
  });
});

req.on('error', (e) => {
  console.error('Request Error:', e);
});

req.write(data);
req.end();
