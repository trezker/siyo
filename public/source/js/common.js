function ajax_post_ko(data, done) {
    $.ajax({
        method      : "POST",
        dataType    : 'json',
        contentType : 'application/json; charset=UTF-8',
        url: "/ajax/" + data.model + "/" + data.method,
        data: data
    })
    .success(done);
}

function ajax_post(data, done) {
	$.ajax({
		method		: "POST",
		dataType   	: 'json',
		contentType	: 'application/json; charset=UTF-8',
		url: "/ajax/" + data.model + "/" + data.method,
		data: JSON.stringify(data)
	})
	.success(done);
}

function ajax_html(url, done) {
	$.ajax({
		cache		: false,
		method		: "GET",
		dataType   	: 'html',
		contentType	: 'application/json; charset=UTF-8',
		url: url
	})
	.done(done);
}
