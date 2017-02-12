module application.helpers;

import vibe.http.server;

string get_current_user_id(HTTPServerRequest req) {
	return req.session.get!string("id");
}
