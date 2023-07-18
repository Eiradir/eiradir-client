@tool
extends RefCounted
class_name EiradirError

var type: String
var message: String
var details: String

func init(p_type: String, p_message: String, p_details: String) -> EiradirError:
    type = p_type
    message = p_message
    details = p_details
    return self

func _to_string() -> String:
    return type + ": " + message + "\n" + details