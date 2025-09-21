var express =  require('express');
var app = express();
// var path = require('path');

app.set('view engine', 'ejs');

const URL = process.env.BACKEND_URL || 'http://localhost:5000/api';



const fetch = (...args) =>
    import('node-fetch').then(({default: fetch}) => fetch(...args));

// app.use(express.static(path.join(__dirname, 'public')));

app.get('/', async function(req, res) {
//    res.sendFile(path.join(__dirname + '/public/index.html'));
    const options = {
        method: 'GET'
    };
    fetch(URL,options)
        .then(res => res.json())
        .then(json => console.log(json))
        .catch(err => console.error('error:' + err));
    try {
        let response = await fetch(URL, options);
        response = await  response.json();
        res.render('index', response)
    } catch (err) {
        console.log(err);
        res.status(500).json({msg: 'Internal Server Error'});
    }
});

const PORT = process.env.EXPRESS_PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Express listening on port ${PORT}`);
});