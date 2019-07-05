const proxy = require('http-proxy-middleware');

module.exports = {
  setupProxy: function(app) {
    app.use(proxy('/backend', { target: 'http://localhost:80/money-manager/backend/api.php' }));
  }
};