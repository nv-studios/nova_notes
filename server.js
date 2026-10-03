const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const DB_DIR = path.join(__dirname, 'Server_Notes_Archive');

// Build central server note databases if not present
if (!fs.existsSync(DB_DIR)) { fs.mkdirSync(DB_DIR); }

const server = http.createServer((req, res) => {
    // 1. RENDER DASHBOARD WEBSITE
    if (req.method === 'GET' && req.url === '/') {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Nova_Notes Server Dashboard</title>
                <style>
                    body { background: #1e1e24; color: #fff; font-family: sans-serif; text-align: center; padding-top: 50px; }
                    .card { background: #2a2a35; border: 2px solid #00ffff; display: inline-block; padding: 30px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,255,255,0.2); }
                    h1 { color: #00ffff; margin-bottom: 5px; }
                    code { background: #111; color: #00ffff; padding: 8px 12px; display: inline-block; margin-top: 15px; border-radius: 4px; font-size: 1.1em; border: 1px solid #333; }
                    p { color: #aaa; }
                </style>
            </head>
            <body>
                <div class="card">
                    <h1>Your Nova Notes Server is Active</h1>
                    <p>Decentralized cloud database communication framework online.</p>
                    <hr style="border: 1px solid #333;">
                    <p>To connect to this sync port terminal node, copy this target parameter string into your client app:</p>
                    <code>http://localhost:${PORT}</code>
                    <p style="font-size: 0.8em; margin-top: 20px; color: #555;">Made with ❤️ by Nova Studios.</p>
                </div>
            </body>
            </html>
        `);
        return;
    }

    // 2. BACKEND API: LIST ALL FILES
    if (req.method === 'GET' && req.url === '/api/notes') {
        fs.readdir(DB_DIR, (err, files) => {
            if (err) { res.writeHead(500); return res.end('Error reading storage.'); }
            const txtFiles = files.filter(f => f.endsWith('.txt')).map(f => f.replace('.txt', ''));
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(txtFiles));
        });
        return;
    }

    // 3. BACKEND API: READ INDIVIDUAL NOTE
    if (req.method === 'POST' && req.url === '/api/read') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            const data = JSON.parse(body);
            const safePath = path.join(DB_DIR, `${data.filename.replace(/[^a-zA-Z0-9_]/g, '')}.txt`);
            if (fs.existsSync(safePath)) {
                res.writeHead(200, { 'Content-Type': 'text/plain' });
                res.end(fs.readFileSync(safePath, 'utf8'));
            } else {
                res.writeHead(404); res.end('File not found');
            }
        });
        return;
    }

    // 4. BACKEND API: SAVE / WRITE NEW NOTE
    if (req.method === 'POST' && req.url === '/api/save') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            const data = JSON.parse(body);
            const safeName = data.filename.replace(/[^a-zA-Z0-9_]/g, '');
            const safePath = path.join(DB_DIR, `${safeName}.txt`);
            
            const fileContent = `=========================================\n TITLE: ${data.title}\n DATE:  ${data.date}\n=========================================\n${data.content}\n=========================================\n Made with ❤️ by Nova Studios.\n=========================================`;
            fs.writeFileSync(safePath, fileContent, 'utf8');
            res.writeHead(200); res.end('Saved');
        });
        return;
    }

    // 5. BACKEND API: WIPE STORAGE
    if (req.method === 'POST' && req.url === '/api/wipe') {
        fs.readdir(DB_DIR, (err, files) => {
            if (!err) { files.forEach(f => fs.unlinkSync(path.join(DB_DIR, f))); }
            res.writeHead(200); res.end('Wiped');
        });
        return;
    }
});

server.listen(PORT, () => {
    console.log(`[+] Nova_Notes Web Server running on port ${PORT}`);
    console.log(`[+] Open http://localhost:${PORT} in your browser to view dashboard status logs.`);
});

