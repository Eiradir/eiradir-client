extends Node

signal join_token_fetched

var authUrl = "https://id.twelveiterations.com/realms/eiradir"

func _ready():
	pass # Replace with function body.


func authorize(username, password):
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_authorize_completed)
	var endpoint = authUrl + "/protocol/openid-connect/authorize"
	#http.request()

func _authorize_completed():
	pass

func fetch_join_token(apiBaseUrl):
	var http = HTTPRequest.new()
	add_child(http)
	
	var endpoint = apiBaseUrl + "/authorize"
	var headers = [
		"Authorization: Bearer " + Supabase.auth.client.access_token
	]
	http.request(endpoint, headers, HTTPClient.METHOD_GET)
	return join_token_fetched

