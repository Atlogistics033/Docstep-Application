const fs = require('fs');
const path = require('path');

function searchDir(dir) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    if (file === 'node_modules' || file === '.git' || file === '.gemini') {
      continue;
    }
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      searchDir(fullPath);
    } else if (stat.isFile()) {
      const content = fs.readFileSync(fullPath, 'utf8');
      if (content.toLowerCase().includes('taha') || content.toLowerCase().includes('mohammad')) {
        console.log(`Found match in: ${fullPath}`);
        // print matching lines
        const lines = content.split('\n');
        lines.forEach((line, idx) => {
          if (line.toLowerCase().includes('taha') || line.toLowerCase().includes('mohammad')) {
            console.log(`  Line ${idx + 1}: ${line.trim()}`);
          }
        });
      }
    }
  }
}

console.log('Searching for "Taha" or "Mohammad" in c:\\docstep...');
searchDir('c:\\docstep');
console.log('Search complete.');
