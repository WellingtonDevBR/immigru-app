const fs = require('fs');
const path = require('path');

const EXCLUDED = [
  '.git', '.idea', '.dart_tool', 'build', '.vscode',
  '.gitignore', '.metadata', 'pubspec.lock', 'pubspec.yaml',
  'README.md', 'analysis_options.yaml'
];

const MAX_CHARACTERS = 6000;

function generateTree(dir, prefix = '', alwaysIncludeDirs = true) {
  const entries = [];
  const files = fs.readdirSync(dir).filter(f => !EXCLUDED.includes(f));
  files.sort((a, b) => a.localeCompare(b, 'en'));

  files.forEach((file, index) => {
    const fullPath = path.join(dir, file);
    const isLast = index === files.length - 1;
    const isDir = fs.statSync(fullPath).isDirectory();
    const connector = isLast ? '└── ' : '├── ';
    const line = prefix + connector + file;

    entries.push({ line, isDir });

    if (isDir) {
      const nextPrefix = prefix + (isLast ? '    ' : '│   ');
      const childEntries = generateTree(fullPath, nextPrefix, alwaysIncludeDirs);
      entries.push(...childEntries);
    }
  });

  return entries;
}

function splitIntoChunks(entries, maxChars) {
  const chunks = [];
  let currentChunk = ['lib/'];
  let currentLength = 'lib/\n'.length;

  for (const entry of entries) {
    if (entry.isDir || (currentLength + entry.line.length + 1 <= maxChars)) {
      currentChunk.push(entry.line);
      currentLength += entry.line.length + 1;
    } else {
      // Start new chunk, always include directory lines
      chunks.push(currentChunk);
      currentChunk = ['lib/'];

      // Re-add all previous directory lines from current chunk
      for (const e of entries) {
        if (e.isDir && !currentChunk.includes(e.line)) {
          currentChunk.push(e.line);
        }
      }

      currentChunk.push(entry.line);
      currentLength = currentChunk.join('\n').length + 1;
    }
  }

  if (currentChunk.length > 1) {
    chunks.push(currentChunk);
  }

  return chunks;
}

// Main logic
const startDir = path.join(__dirname, 'lib');
const outputBasePath = path.join(__dirname, '.windsurf', 'rules', '003-folder-structure');

if (fs.existsSync(startDir)) {
  const allEntries = generateTree(startDir);
  const chunks = splitIntoChunks(allEntries, MAX_CHARACTERS);

  // Ensure the output directory exists
  const outputDir = path.dirname(outputBasePath);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  chunks.forEach((chunk, idx) => {
    const filename = idx === 0
      ? `${outputBasePath}.md`
      : `${outputBasePath}-${idx + 1}.md`;
    fs.writeFileSync(filename, chunk.join('\n'), 'utf-8');
    
  });
} else {

}
