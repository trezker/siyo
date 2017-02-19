module application.product;

import vibe.http.server;
import vibe.core.log;
import vibe.data.json;
import mondo;
import bsond;
import std.stdio;
import std.datetime;
import std.conv;
import std.json;

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
		models["product"]["get_product"] = Model_method(
			[],
			&this.get_product
		);
		models["product"]["my_products"] = Model_method(
			[],
			&this.my_products
		);
	}

	void save_product(HTTPServerRequest req, HTTPServerResponse res) {
		string id = req.json["id"].to!string;
		string title = req.json["title"].to!string;
		string owner = get_current_user_id(req);
		
		auto created = Clock.currTime();
		
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

	void get_product(HTTPServerRequest req, HTTPServerResponse res) {
		JSONValue result = JSONValue([
			"success": false
		]);

		try {
			string owner = get_current_user_id(req);
			string title = req.json["title"].to!string;
			Query q = new Query();
			q.conditions["owner"] = owner;
			q.conditions["title"] = title;
			q.fields["_id"] = true;
			q.fields["title"] = true;
			q.fields["created"] = true;
			Collection product_collection = db.product;
			auto r = product_collection.find(q);
			
			JSONValue product;
			foreach (p; r) {
				product = JSONValue([ 
					"id": JSONValue(p["_id"].as!string),
					"title": JSONValue(p["title"].as!string),
					"created": JSONValue(p["created"].as!string) 
				]);
			}
			result["success"] = true;
			result["product"] = product;
		}
		catch(Exception e) {
			logInfo(e.msg);
		}

		res.writeBody(result.toString, "application/json; charset=UTF-8");
	}

	void my_products(HTTPServerRequest req, HTTPServerResponse res) {
		JSONValue result = JSONValue([
			"success": false
		]);

		try {
			string owner = get_current_user_id(req);
			Query q = new Query();
			q.conditions["owner"] = owner;
			q.fields["_id"] = true;
			q.fields["title"] = true;
			Collection product_collection = db.product;
			auto r = product_collection.find(q);
			
			JSONValue[] products;
			foreach (p; r) {
				products ~= JSONValue([ 
					"id": JSONValue(p["_id"].as!string),
					"title": JSONValue(p["title"].as!string) 
				]);
			}
			result["success"] = true;
			result["products"] = products;
		}
		catch(Exception e) {
			logInfo(e.msg);
		}

		res.writeBody(result.toString, "application/json; charset=UTF-8");
	}
}
