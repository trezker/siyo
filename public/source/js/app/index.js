function sign_out() {
	var data = {};
	data.model = "user";
	data.method = "logout";
	ajax_post(data, function(returnedData) {
		if(returnedData == true) {
			window.location.href = window.location.href;
		}
	});
}

var d = null;
function load_start_page() {
	$.get("/source/html/start.html", function(data) {
		$("#content").html(data);
		
		var startViewModel = function() {
			var self = this;

			self.products = ko.observableArray();

			self.openProduct = function(product) {
				window.location.hash = "product/" + product.title;
			}
			self.newProduct = function() {
				window.location.hash = "product";
			}

			ajax_post({model: "product", method: "my_products"}, function(returnedData) {
				d = returnedData;
				console.log(returnedData);
				if(returnedData.success == true) {
					self.products(returnedData.products);
				}
			});
		};
		ko.cleanNode($("#content")[0]);
		ko.applyBindings(new startViewModel(), $("#content")[0]);
	});
}

function load_by_hash() {
	var hash = location.hash;
	var path = hash.split("/");
	switch(path[0]) {
	case '#product':
		load_product_page(path[1]);
	break;
	case '':
		load_start_page();
	break;
	default:
		console.log("Faulty hash");
	}
}

$(window).hashchange(load_by_hash);
$(load_by_hash);

