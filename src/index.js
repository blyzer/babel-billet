const http = require('http');
const { URL } = require('url');

/**
 * sayHello:
 *   Recibe un nombre (string). Devuelve un saludo.
 *   Si no recibe nombre, saluda a "World".
 */
function sayHello(name) {
  return `Hello, ${name || 'World'}!`;
}

// Si este archivo se ejecuta directamente (node src/index.js),
// se levanta un servidor HTTP en el puerto indicado por process.env.PORT o 3000.
if (require.main === module) {
  const port = process.env.PORT || 3000;

  const server = http.createServer((req, res) => {
    // Parseamos la URL completa (incluyendo query string)
    const parsedUrl = new URL(req.url, `http://${req.headers.host}`);
    const pathname = parsedUrl.pathname;      // ejemplo: "/"
    const nameParam = parsedUrl.searchParams.get('name'); // ejemplo: "Enver"

    if (pathname === '/') {
      // Si estamos en “/”, devolvemos el saludo
      res.writeHead(200, { 'Content-Type': 'text/plain' });
      res.end(sayHello(nameParam));
    } else {
      // Cualquier otra ruta → 404
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('Not Found');
    }
  });

  server.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
  });
}

module.exports = { sayHello };