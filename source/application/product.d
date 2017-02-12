module application.product;

import vibe.http.server;
import vibe.core.log;
import mondo;
import bsond;
import std.stdio;
import std.datetime;
import std.conv;

import boiler.server;
import boiler.model;
import boiler.helpers;

import application.helpers;

class Product_model {
	Mongo mongo;
	Db db;
	Model_method[string][string] models;

	void setup(Mongo m, ref Model_method[string][string] models) {
		mongo = m;
		db = m["siyo"];
		models["product"]["save_product"] = Model_method(
			[],
			&this.save_product
		);
	}

	void save_product(HTTPServerRequest req, HTTPServerResponse res) {
		
		string id = req.json["id"].to!string;
		string title = req.json["title"].to!string;
		string owner = get_current_user_id(req);
		
		auto created = Clock.currTime();
		//auto created = to!DateTime(systime);
		
		Collection product_collection = db.product;

		auto success = false;
		try {
			if(id == "") {
				//Create the product
				product_collection.insert(
					BO(
						"title", title,
						"owner", owner,
						"created", created
					)
				);
				success = true;
			}
			else {
				//Update product
			}
		}
		catch(Exception e) {
			logInfo(e.msg);
		}

		res.writeJsonBody(success);
	}
}
