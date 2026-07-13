extends Node
## Structured logger with bounded in-memory history.

enum Severity { DEBUG, INFO, WARNING, ERROR, FATAL }
const MAX_RECORDS := 500
var records: Array[Dictionary] = []

func write(severity: Severity, category: StringName, code: StringName, message: String, context := {}) -> void:
    var record := {
        "timestamp": Time.get_datetime_string_from_system(true),
        "severity": Severity.keys()[severity],
        "category": String(category),
        "code": String(code),
        "message": message,
        "context": context.duplicate(true) if context is Dictionary else {},
    }
    records.append(record)
    if records.size() > MAX_RECORDS: records.pop_front()
    var rendered := "[%s][%s][%s] %s" % [record.severity, category, code, message]
    if severity >= Severity.ERROR: push_error(rendered)
    elif severity == Severity.WARNING: push_warning(rendered)
    elif OS.is_debug_build(): print(rendered)

func info(category: StringName, code: StringName, message: String, context := {}) -> void:
    write(Severity.INFO, category, code, message, context)

func warning(category: StringName, code: StringName, message: String, context := {}) -> void:
    write(Severity.WARNING, category, code, message, context)

func error(category: StringName, code: StringName, message: String, context := {}) -> void:
    write(Severity.ERROR, category, code, message, context)
