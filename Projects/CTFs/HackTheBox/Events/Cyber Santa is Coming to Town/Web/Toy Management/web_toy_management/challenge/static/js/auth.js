// register enterKey event
(function($) {
	$.fn.catchEnter = function(sel) {
		return this.each(function() {
			$(this).on('keyup', sel, function(e) {
				if (e.keyCode == 13)
					$(this).trigger('enterkey');
			})
		});
	};
})(jQuery);

$(document).ready(() => {
	// set input events
	$('#login-btn').on('click', () => {
		auth()
	});
	$('#username').on('keydown', () => {
		$('#resp-msg').hide()
	});
	$('#password').on('keydown', () => {
		$('#resp-msg').hide()
	});
	$('#username').catchEnter().on('enterkey', () => {
		auth()
	});
	$('#password').catchEnter().on('enterkey', () => {
		auth()
	});

});

function toggleInputs(state) {
	$("#username").prop("disabled", state);
	$("#password").prop("disabled", state);
	$("#login-btn").prop("disabled", state);
	$("#register-btn").prop("disabled", state);
}


async function auth() {

	toggleInputs(true); // disable inputs

	// prepare alert
	let card = $("#resp-msg");
	card.attr("class", "alert alert-info");
	card.hide();

	// validate
	let user = $("#username").val();
	let pass = $("#password").val();
	if ($.trim(user) === '' || $.trim(pass) === '') {
		toggleInputs(false);
		card.text("Please input email and password first!");
		card.attr("class", "alert alert-danger");
		card.show();
		return;
	}

	const data = {
		username: user,
		password: pass
	};

	await fetch('/api/login', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify(data),
		})
		.then((response) => response.json()
			.then((resp) => {
				card.attr("class", "alert alert-danger");
				if (response.status == 200) {
					card.attr("class", "alert alert-success");
					window.location.href = '/dashboard';
				}
				card.text(resp.message);
				card.show();
			}))
		.catch((error) => {
			card.text(error);
			card.attr("class", "alert alert-danger");
			card.show();
		});

	toggleInputs(false); // enable inputs
}