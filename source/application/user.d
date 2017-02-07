module application.user;

import vibe.http.server;
import vibe.core.log;
import mondo;
import std.digest.sha;
import bsond;
import std.stdio;

import boiler.server;
import boiler.model;
import boiler.helpers;

class User_model {
	Mongo mongo;

	void setup(Mongo m, ref Model_method[string][string] models) {
		mongo = m;
		models["user"]["get_current_user_id"] = Model_method(
			[],
			&this.get_current_user_id
		);
		models["user"]["login_password"] = Model_method(
			[],
			&this.login_password
		);
		models["user"]["logout"] = Model_method(
			[],
			&this.logout
		);
		models["user"]["create_user"] = Model_method(
			[],
			&this.create_user
		);
		models["user"]["delete_user"] = Model_method(
			[],
			&this.delete_user
		);
	}

	void get_current_user_id(HTTPServerRequest req, HTTPServerResponse res) {
		if(!req.session) {
			res.writeJsonBody(false);
			return;
		}
		auto id = req.session.get!string("id");
		res.writeJsonBody(id);
	}

	void login_password(HTTPServerRequest req, HTTPServerResponse res) {
		//Do not allow double login, must log out first.
		//But we'll help out by terminating the old session to get a clean state.
		if(req.session) {
			res.terminateSession();
			res.writeJsonBody(false);
			return;
		}

		string username = req.json["username"].to!string;
		string password = req.json["password"].to!string;

		Collection user_collection = mongo.journal.user;

		Query q = new Query();
		q.conditions["name"] = username;
		q.fields["_id"] = true;
		q.fields["pass"] = true;
		q.fields["salt"] = true;
		auto r = user_collection.find(q);
		if(r.empty) {
			res.writeJsonBody(false);
			return;
		}
		auto user = r.front;

		ubyte[32] hash = sha512_256Of(user["salt"].as!string ~ password);
		string hashed_password = toHexString(hash);
		if(user["pass"].as!string != hashed_password) {
			res.writeJsonBody(false);
			return;
		}

		auto session = res.startSession();
		string user_id = user["_id"].as!string;
		session.set("id", user_id);
		res.writeJsonBody(true);
	}

	void logout(HTTPServerRequest req, HTTPServerResponse res) {
		if(req.session) {
			res.terminateSession();
		}
		res.writeJsonBody(true);
	}

	void create_user(HTTPServerRequest req, HTTPServerResponse res) {
		string username = req.json["username"].to!string;
		string password = req.json["password"].to!string;

		Collection user_collection = mongo.journal.user;

		auto success = false;
		try {
			Query q = new Query();
			q.conditions["name"] = username;
			q.fields["_id"] = true;
			auto r = user_collection.find(q);
			if(r.empty) {
				//Create the user
				string salt = get_random_string(32);
				ubyte[32] hash = sha512_256Of(salt ~ password);
				string hashed_password = toHexString(hash);

				user_collection.insert(
					BO(
						"name", username,
						"salt", salt,
						"pass", hashed_password
					)
				);
				success = true;
			}
		}
		catch(Exception e) {
			logInfo(e.msg);
		}

		res.writeJsonBody(success);
	}

	void delete_user(HTTPServerRequest req, HTTPServerResponse res) {
		string username = req.json["username"].to!string;
		//Method only for testing, in real usage users are never deleted.
		if(username != "testuser")
		{
			res.writeJsonBody(true);
			return;
		}

		Collection user_collection = mongo.journal.user;
		user_collection.remove(BO(
				"name", username
			)
		);

		res.writeJsonBody(true);
	}
}
