@tool
extends Node

const ENVIRONMENT_VARIABLES : String = "eiradir/config"

var server_api: EiradirServerAPI 
var auth: EiradirAuthAPI

var config: Dictionary = {
	auth_url = "https://id.twelveiterations.com/realms/eiradir"
}

var tokens: AuthTokens

func _ready() -> void:
	load_config()
	load_nodes()

func load_config() -> void:
	var env = ConfigFile.new()
	var err = env.load("res://addons/eiradir/.env")
	if err == OK:
		for key in config.keys(): 
			var value : String = env.get_value(ENVIRONMENT_VARIABLES, key, "")
			if value == "":
				printerr("%s has not a valid value." % key)
			else:
				config[key] = value
	else:
		print("Unable to read .env file at path 'res://.env'")

func load_nodes() -> void:
	server_api = EiradirServerAPI.new(config)
	add_child(server_api)
	auth = EiradirAuthAPI.new(config)
	add_child(auth)

func handle_request_error(result: int, response_code: int, body: String) -> EiradirError:
	if result > 0:
		return EiradirError.new().init("network_error", "Network Error (" + str(result) + ")", body)
	if response_code < 200 || response_code > 299:
		var parsed = JSON.parse_string(body)
		if parsed && parsed.has("error"):
			return EiradirError.new().init(parsed.error, parsed.error_description, body)
		return EiradirError.new().init("http_error", "HTTP Error (" + str(response_code) + ")", body)
	return null

func www_form_ulrencoded(params: Dictionary) -> String:
	var body_string = ""
	for key in params.keys():
		body_string += "%s=%s&" % [key.uri_encode(), params[key].uri_encode()]
	body_string = body_string.trim_suffix("&") # remove trailing '&'
	return body_string
