# MultiJson will use Oj, currently noted as being faster
# than most other Parsers available to Ruby
json.metadata safe_json_load metadata.to_json

json.errors safe_json_load(errors.to_json) if errors.display?

json.result safe_json_load yield
