import http from 'http';

const port = process.env.PORT || 8080;
const secret = process.env.SECRET;

http.createServer((req, res) => {

    const url = new URL(`http://${process.env.HOST ?? 'localhost'}${req.url}`); 
    console.log(`PATH: ${url.pathname}`);
    if (url.pathname.startsWith('/health')) {
        console.log('Healthcheck request');
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end("It's alive!\n");
        return;
    }
    if (secret && req.headers['x-secret'] !== secret) {
        console.log('Protected request');
        res.writeHead(403, { 'Content-Type': 'text/plain' });
        res.end('Forbidden\n');
        return;
    }

    console.log(`Received request for ${req.url}`);

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    res.writeHead(200, { 'Content-Type': 'application/json' });

    const data = { env: process.env, header: req.headers, timestamp: new Date().toISOString() };

    res.end(JSON.stringify(data, null, 2));
}).listen(port, () => {
    console.log('Print Environment Server');
    console.log(`Server running at http://localhost:${port}/`);
});