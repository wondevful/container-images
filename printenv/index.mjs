import http from 'http';

const port = process.env.PORT || 8080;

http.createServer((req, res) => {
    console.log(`Received request for ${req.url}`);
    
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(process.env, null, 2));
}).listen(port, () => {
    console.log(`Server running at http://localhost:${port}/`);
});