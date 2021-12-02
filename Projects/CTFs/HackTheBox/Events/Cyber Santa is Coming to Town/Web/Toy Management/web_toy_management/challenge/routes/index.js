const crypto         = require('crypto');
const express        = require('express');
const router         = express.Router();
const JWTHelper      = require('../helpers/JWTHelper');
const AuthMiddleware = require('../middleware/AuthMiddleware');

let db;

const response = data => ({ message: data });

router.get('/', (req, res) => {
	return res.render('login.html');
});

router.post('/api/login', async (req, res) => {
	const { username, password } = req.body;
	if (username && password) {
		passhash = crypto.createHash('md5').update(password).digest('hex');
		return db.loginUser(username, passhash)
			.then(user => {
				if (!user.length) return res.status(403).send(response('Invalid username or password!'));
				JWTHelper.sign({ username: user[0].username })
					.then(token => {
						res.cookie('session', token, { maxAge: 43200000 });
						res.send(response('User authenticated successfully!'));
					})
			})
			.catch(() => res.status(403).send(response('Invalid username or password!')));
	}
	return res.status(500).send(response('Missing parameters!'));
});

router.get('/dashboard', AuthMiddleware, async (req, res, next) => {
	return db.getUser(req.data.username)
		.then(user => {
			res.render('dashboard.html', { user: user[0] });
		})
		.catch(() => res.status(500).send(response('Something went wrong!')));
});

router.get('/api/toylist', AuthMiddleware, async (req, res) => {
	return db.getUser(req.data.username)
		.then(user => {
			approved = 1;
			if (user[0].username == 'admin') approved = 0;
			return db.listToys(approved)
				.then(toyInfo => {
					return res.json(toyInfo);
				})
				.catch(() => res.status(500).send(response('Something went wrong!')));
		})
		.catch(() => res.status(500).send(response('Something went wrong!')));
});

router.get('/logout', (req, res) => {
	res.clearCookie('session');
	return res.redirect('/');
});

module.exports = database => { 
	db = database;
	return router;
};