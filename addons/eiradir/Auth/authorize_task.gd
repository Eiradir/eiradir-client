@tool
extends RefCounted
class_name AuthorizeTask

signal completed(access_token: AuthTokens, error: EiradirError)

func execute(request: HTTPRequest, baseUrl: String, username: String, password: String):
	reference() # refcount this until request completes in case caller doesn't keep track of it
	request.request_completed.connect(_on_http_request_completed.bind(request))
	var endpoint: String = baseUrl + "/protocol/openid-connect/token"
	var headers: PackedStringArray = [
		"Content-Type: application/x-www-form-urlencoded",
		"Accept: application/json"
	]
	var body = Eiradir.www_form_ulrencoded({
		grant_type = "password",
		client_id = "eiradir",
		username = username,
		password = password
	})
	request.request(endpoint, headers, HTTPClient.METHOD_POST, body)
	
func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, request: HTTPRequest):
	unreference()
	request.queue_free()
	var body_text = body.get_string_from_utf8()
	var error: EiradirError = Eiradir.handle_request_error(result, response_code, body_text)
	var json: Dictionary = JSON.parse_string(body_text) if !error else {}
	var auth_tokens: AuthTokens = null
	if !json.is_empty():
		auth_tokens = AuthTokens.new()
		auth_tokens.access_token = json.get("access_token", "")
		auth_tokens.expires_in = int(json.get("expires_in", 0))
		auth_tokens.expires_at = Time.get_ticks_msec() + auth_tokens.expires_in * 1000
		auth_tokens.refresh_token = json.get("refresh_token", "")
		auth_tokens.refresh_expires_in = int(json.get("refresh_expires_in", 0))
		auth_tokens.refresh_expires_at = Time.get_ticks_msec() + auth_tokens.refresh_expires_in * 1000
	completed.emit(auth_tokens, error)
