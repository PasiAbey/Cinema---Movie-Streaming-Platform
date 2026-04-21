const express = require('express');
const cors = require('cors');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5001; // Using 5001 to avoid conflicts

app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'Catalog Service is healthy' });
});

// TMDB Proxy Logic
app.use('/tmdb', async (req, res) => {
    console.log(`[Catalog Service] Request: ${req.url}`);
    try {
        const endpoint = req.url.split('?')[0].replace(/^\//, '');
        if (!endpoint) return res.status(400).json({ error: 'Endpoint is required' });

        const queryParams = new URLSearchParams(req.query).toString();
        const tmdbUrl = `https://api.themoviedb.org/3/${endpoint}?${queryParams}`;

        const response = await axios.get(tmdbUrl, {
            headers: {
                Authorization: `Bearer ${process.env.TMDB_API_KEY}`,
                "Content-Type": "application/json"
            }
        });
        res.json(response.data);
    } catch (error) {
        console.error('TMDB API Error:', error.response ? error.response.data : error.message);
        res.status(error.response ? error.response.status : 500).json({ error: 'Failed to fetch from TMDB' });
    }
});

app.listen(PORT, () => {
    console.log(`Catalog Service running on port ${PORT}`);
});
