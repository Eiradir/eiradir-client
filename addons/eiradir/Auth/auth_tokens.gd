@tool
extends RefCounted
class_name AuthTokens

var access_token: String
var expires_in: int
var expires_at: int
var refresh_token: String
var refresh_expires_in: int
var refresh_expires_at: int

func get_roles() -> PackedStringArray:
	var payload = parse_jwt_unverified(access_token)
	return payload.realm_access.roles

func base64url_to_base64(input: String) -> String:
	var mod = input.length() % 4
	if mod > 0:
		for i in range(4 - mod):
			input += "="
	return input.replace("-", "+").replace("_", "/")

func parse_jwt_unverified(jwt: String) -> Dictionary:
	var parts = jwt.split(".")
	if parts.size() != 3:
		return {}

	var base64_payload = base64url_to_base64(parts[1])
	var payload_json = Marshalls.base64_to_utf8(base64_payload)
	return JSON.parse_string(payload_json)
