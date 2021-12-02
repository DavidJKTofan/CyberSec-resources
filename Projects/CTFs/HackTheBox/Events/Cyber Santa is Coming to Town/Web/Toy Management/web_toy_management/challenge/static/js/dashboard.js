$(document).ready(() => {
	loadToyInfo();
});

const loadToyInfo = async () => {

	await fetch('/api/toylist', {
			method: 'GET',
			credentials: 'include'
		})
		.then((response) => response.json())
		.then(async (toyList) => {
			for (let toyInfo of toyList) {
				populateTable(toyInfo);			
			}
		})
		.catch((error) => console.log(error));
}

const populateTable = (toyInfo) => {

	rowData = `<tr>`;
	rowData += `<td>${htmlEncode(toyInfo.toy)}</td>`;
	rowData += `<td>${htmlEncode(toyInfo.receiver)}</td>`;
	rowData += `<td>${htmlEncode(toyInfo.location)}</td>`;
	rowData += `<td>${(toyInfo.approved == 1) ? 'true': 'false'}</td>`;
	rowData += `</tr>`;

	$('#toy-listing > tbody:last-child').append(rowData);

}

// can I haz security?
const htmlEncode = (str) => {
	return String(str).replace(/[^\w. ]/gi, function(c) {
		return '&#' + c.charCodeAt(0) + ';';
	});
}
const htmlDecode = (str) => {
	var doc = new DOMParser().parseFromString(str, "text/html");
	return doc.documentElement.textContent;
}