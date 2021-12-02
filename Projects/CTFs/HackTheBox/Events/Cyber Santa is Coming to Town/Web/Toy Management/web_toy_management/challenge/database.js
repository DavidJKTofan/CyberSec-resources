let mysql = require('mysql')

class Database {

	constructor() {
		this.connection = mysql.createConnection({
			host: 'localhost',
			user: 'dbuser',
			password: 'DBPASS',
			database: 'toydb'
		});
	}

	async connect() {
		return new Promise((resolve, reject)=> {
			this.connection.connect((err)=> {
				if(err)
					reject(err)
				resolve()
			});
		})
	}
	
	async listToys(approved=1) {
		return new Promise(async (resolve, reject) => {
			let stmt = `SELECT * FROM toylist WHERE approved = ?`;
			this.connection.query(stmt, [approved], (err, result) => {
				if(err)
					reject(err)
				try {
					resolve(JSON.parse(JSON.stringify(result)))
				}
				catch (e) {
					reject(e)
				}
			})
			
		});
	}

	async loginUser(user, pass) {
		return new Promise(async (resolve, reject) => {
			let stmt = `SELECT username FROM users WHERE username = '${user}' and password = '${pass}'`;
			this.connection.query(stmt, (err, result) => {
				if(err)
					reject(err)
				try {
					resolve(JSON.parse(JSON.stringify(result)))
				}
				catch (e) {
					reject(e)
				}
			})
		});
	}

	async getUser(user) {
		return new Promise(async (resolve, reject) => {
			let stmt = `SELECT * FROM users WHERE username = '${user}'`;
			this.connection.query(stmt, (err, result) => {
				if(err)
					reject(err)
				try {
					resolve(JSON.parse(JSON.stringify(result)))
				}
				catch (e) {
					reject(e)
				}
			})
		});
	}

}

module.exports = Database;