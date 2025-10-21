const express = require('express');
const app = express();
const PORT = 8000;

app.get('/', (req, res) => {
    res.send('Hello from Kubernetes! Your CI/CD pipeline is working! 🚀');
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});