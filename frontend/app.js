var express =  require('express');
var app = express();
// var path = require('path');


app.set('view engine', 'ejs');


const URL = process.env.BACKEND_URL || 'http://localhost:5000/api';


const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));


app.get('/', async function(req, res) {
  try {
    let response = await fetch(URL);         // Call backend API
    let data = await response.json();        // { data: [...] }


    // Pass the array to EJS
    res.render('index', { data: data.data || [] });
  } catch (err) {
    console.error('Error fetching backend:', err);
    res.status(500).json({ msg: 'Internal Server Error' });
  }
});


app.listen(3000, function() {
  console.log('Arena frontend listening on port 3000!');
});
