function load_product_page() {
	$.get("/source/html/product.html", function(data) {
		$("#content").html(data);
		
		var productViewModel = function() {
			var self = this;

			self.model = ko.mapping.fromJS({
				id: "",
				title: "Test",
				created: ""
			});

			self.new_product = function() {

			};

			self.save_product = function() {
				var data = ko.mapping.toJS(this.model);
				data.model = "product";
				data.method = "save_product";
				console.log(data);
				ajax_post(data, function(returnedData) {
					console.log(returnedData);
					if(returnedData == true) {
						self.model = ko.mapping.fromJS(returnedData.model);
					}
				});
			};
		};
		ko.cleanNode($("#content")[0]);
		ko.applyBindings(new productViewModel(), $("#content")[0]);
	});
}