function load_product_page(product) {
	$.get("/source/html/product.html", function(data) {
		$("#content").html(data);
		
		var productViewModel = function() {
			var self = this;

			self.model = ko.mapping.fromJS({
				id: "",
				title: "",
				created: ""
			});

			self.new_product = function() {

			};

			self.save_product = function() {
				var data = ko.mapping.toJS(self.model);
				data.model = "product";
				data.method = "save_product";
				console.log(data);
				ajax_post(data, function(returnedData) {
					console.log(returnedData);
					if(returnedData == true) {
						window.location.hash = "product/" + self.model.title();
					}
				});
			};

			if(product) {
				ajax_post({model: "product", method: "get_product", title: product}, function(returnedData) {
					d = returnedData;
					console.log(returnedData);
					if(returnedData.success == true) {
						ko.mapping.fromJS(returnedData.product, self.model);
					}
				});
			}
		};


		ko.cleanNode($("#content")[0]);
		ko.applyBindings(new productViewModel(), $("#content")[0]);
	});
}