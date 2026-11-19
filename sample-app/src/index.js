const http = require('http');

const PORT = process.env.PORT || 8080;
const APP_ENV = process.env.APP_ENV || 'production';
const APP_VERSION = process.env.APP_VERSION || '1.0.0';

const server = http.createServer((req, res) => {
  const url = req.url;

  // Liveness Probe Endpoint
  if (url === '/healthz') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ status: 'UP', timestamp: new Date().toISOString() }));
  }

  // Readiness Probe Endpoint
  if (url === '/ready') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ ready: true }));
  }

  // Application Metrics / Status Endpoint
  if (url === '/metrics') {
    const memoryUsage = process.memoryUsage();
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({
      version: APP_VERSION,
      environment: APP_ENV,
      uptime_seconds: process.uptime(),
      memory: memoryUsage
    }));
  }

  // Default API Endpoint
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    message: 'Hello from Azure Cloud & DevOps Microservice!',
    version: APP_VERSION,
    environment: APP_ENV,
    deployed_by: 'CI/CD Pipeline (GitHub Actions & Azure DevOps)'
  }));
});

server.listen(PORT, () => {
  console.log(`[INFO] Server running on port ${PORT} in ${APP_ENV} mode.`);
});

// Graceful Shutdown Handling (SIGTERM from Kubernetes)
process.on('SIGTERM', () => {
  console.log('[INFO] SIGTERM signal received. Closing HTTP server gracefully...');
  server.close(() => {
    console.log('[INFO] HTTP server closed.');
    process.exit(0);
  });
});
