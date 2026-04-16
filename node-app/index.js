const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('<h1>Node app running inside combined image</h1><p>Open via VNC or visit /api</p>');
});

app.get('/api', (req, res) => {
  res.json({status: 'ok', service: 'node'});
});

app.listen(port, () => console.log(`Node app listening on ${port}`));
