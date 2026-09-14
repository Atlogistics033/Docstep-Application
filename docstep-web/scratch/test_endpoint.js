const http = require('http');

http.get('http://localhost:3000/api/public/courses/recommend?specialty=General%20Practice', (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    console.log(`Status Code: ${res.statusCode}`);
    try {
      const json = JSON.parse(data);
      console.log('Response courses:');
      json.courses.forEach(c => {
        console.log(`- Title: "${c.title}", Instructor: "${c.instructor}"`);
      });
    } catch (e) {
      console.log('Raw response:', data);
    }
    process.exit(0);
  });
}).on('error', (err) => {
  console.error('Error fetching from local server:', err);
  process.exit(1);
});
