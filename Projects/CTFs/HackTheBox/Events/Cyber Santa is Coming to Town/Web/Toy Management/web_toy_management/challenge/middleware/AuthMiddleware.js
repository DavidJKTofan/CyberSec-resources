const JWTHelper = require('../helpers/JWTHelper');

module.exports = async (req, res, next) => {
	try{
		if (req.cookies.session === undefined) {
			if(!req.is('application/json')) return res.redirect('/');
			return res.status(401).json({ status: 'unauthorized', message: 'Authentication expired, please login again!' });
		}
		return JWTHelper.verify(req.cookies.session)
			.then(username => {
				req.data = username;
				next();
			})
			.catch(() => {
				res.redirect('/logout');
			});
	} catch(e) {
		console.log(e);
		return res.status(500).send('Internal server error');
	}
}