const express = require('express');
const app = express();
const apiRoutes = require('./routes');
const cors = require('cors');

app.use(cors());
// Middleware to parse JSON bodies
app.use(express.json());

// Use API routes
app.use(apiRoutes);



// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});