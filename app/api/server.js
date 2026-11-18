const express = require('express');
const { Pool } = require('pg');

const app = express();
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

app.get('/health', (_, res) => res.json({ status: 'ok' }));

app.get('/visits', async (_, res) => {
  await pool.query('CREATE TABLE IF NOT EXISTS visits (id SERIAL PRIMARY KEY, at TIMESTAMP DEFAULT NOW())');
  await pool.query('INSERT INTO visits DEFAULT VALUES');
  const { rows } = await pool.query('SELECT COUNT(*) FROM visits');
  res.json({ visits: Number(rows[0].count) });
});

app.listen(3000, () => console.log('API on 3000'));