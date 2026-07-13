#!/usr/bin/env python
"""Flatten ["null", <type>] Avro unions to <type> for C++ code generation.

The camera telemetry schemas declare optional fields as a union of
"null" and a scalar type, with a null default. The C++ SAL generator
(avrogencpp plus the SAL wrapper copy code) does not support union
fields, so this tool produces a copy of a schema in which every
["null", <type>] union is replaced by <type> and the null default is
removed.

The original schema is left untouched; only the C++ header generation
consumes the flattened copy. The schema registered to the schema
registry and packaged for Java therefore remains the nullable version
that the camera CCS publishes.

Usage: flatten_avro_unions.py <input-schema.json> <output-schema.json>
"""

import json
import sys
import typing


def flatten_type(field_type: typing.Any, field_name: str) -> tuple[typing.Any, bool]:
    """Return the scalar type for a ["null", <type>] union field."""
    if not isinstance(field_type, list):
        return field_type, False
    non_null = [item for item in field_type if item != "null"]
    if len(non_null) != 1:
        sys.exit(f"ERROR: {field_name}: cannot flatten union {field_type}")
    return non_null[0], True


def flatten_schema(schema: dict[str, typing.Any]) -> dict[str, typing.Any]:
    """Flatten all union fields in an Avro record schema in place."""
    for field in schema.get("fields", []):
        field["type"], was_union = flatten_type(field["type"], field["name"])
        if was_union and field.get("default", "") is None:
            del field["default"]
    return schema


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    input_path, output_path = sys.argv[1], sys.argv[2]
    with open(input_path) as input_file:
        schema = json.load(input_file)
    flatten_schema(schema)
    with open(output_path, "w") as output_file:
        json.dump(schema, output_file, indent=4)


if __name__ == "__main__":
    main()
