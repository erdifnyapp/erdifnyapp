
class Response {

  final String key;
  final String uid;
  final String reason;
  final String amount;

	Response.fromJsonMap(Map<String, dynamic> map): 
		key = map["key"],
		uid = map["uid"],
		reason = map["reason"],
		amount = map["amount"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['key'] = key;
		data['uid'] = uid;
		data['reason'] = reason;
		data['amount'] = amount;
		return data;
	}
}
