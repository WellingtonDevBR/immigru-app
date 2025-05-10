const fs = require('fs');
const path = require('path');

const EXCLUDED = [
  '.git', '.idea', '.dart_tool', 'build', '.vscode',
  '.gitignore', '.metadata', 'pubspec.lock', 'pubspec.yaml',
  'README.md', 'analysis_options.yaml'
];

function generateTree(dir, prefix = '') {
  const lines = [];
  const files = fs.readdirSync(dir).filter(f => !EXCLUDED.includes(f));
  files.sort((a, b) => a.localeCompare(b, 'en'));

  files.forEach((file, index) => {
    const fullPath = path.join(dir, file);
    const isLast = index === files.length - 1;
    const isDir = fs.statSync(fullPath).isDirectory();

    const connector = isLast ? '└── ' : '├── ';
    lines.push(prefix + connector + file);

    if (isDir) {
      const nextPrefix = prefix + (isLast ? '    ' : '│   ');
      lines.push(...generateTree(fullPath, nextPrefix));
    }
  });

  return lines;
}

// Main logic
const startDir = path.join(__dirname, 'lib');
const outputFilePath = path.join(__dirname, '.windsurf', 'rules', '003-folder-structure.md');

if (fs.existsSync(startDir)) {
  const structure = ['lib/', ...generateTree(startDir)].join('\n');

  // Ensure the .windsurf directory exists
  const outputDir = path.dirname(outputFilePath);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // Write to file
  fs.writeFileSync(outputFilePath, structure, 'utf-8');
  console.log(`✅ Folder structure written to ${outputFilePath}`);
} else {
  console.error('❌ "lib" directory not found. Run this from the root of a Flutter project.');
}
