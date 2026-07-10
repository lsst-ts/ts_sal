#!/usr/bin/env python
"""Merge Avro-sourced telemetry topics into the SAL Tcl sidecar files.

Some components (ATCamera, CCCamera, MTCamera) define telemetry topics
as native Avro schema files instead of SAL XML. get_component_info
already writes those topics to avro-templates/<subsys>/<subsys>_*.json,
but the Tcl sidecar files (<subsys>_tlmdef.tcl, <subsys>_metadata.tcl)
are only generated from the XML definitions, so the Avro-only topics
are invisible to the SAL code generators.

This tool reads the topic schemas in avro-templates/<subsys>/ and
updates the sidecar files:

* Topics missing from TLM_ALIASES are added, with TLMS param/plist
  entries derived from the Avro schema.
* Topics whose sidecar field list no longer matches the schema (an
  Avro schema replaced an XML definition of the same name) have their
  TLMS entries regenerated from the schema.
* METADATA entries (description, units, size) are written for the
  added or regenerated topics, replacing any stale entries.

Usage: avro_to_tcl_definitions.py <avro-templates-dir> <subsystem>
"""

import json
import pathlib
import re
import sys

AVRO_TO_SAL_TYPE = {
    "boolean": "boolean",
    "int": "int",
    "long": "long",
    "float": "float",
    "double": "double",
    "string": "string",
}

NON_TOPIC_SUFFIXES = ("_hash_table", "_field_enums", "_global_enums")


def tcl_quote(value):
    """Return value as a double-quoted Tcl string literal."""
    escaped = re.sub(r'([\\"$\[\]])', r"\\\1", str(value))
    return f'"{escaped}"'


def resolve_field_type(field, topic_name):
    """Return the SAL param type for an Avro field.

    Unions of the form ["null", <type>] resolve to <type>.
    """
    avro_type = field["type"]
    if isinstance(avro_type, list):
        non_null = [item for item in avro_type if item != "null"]
        if len(non_null) != 1:
            sys.exit(
                f"ERROR: {topic_name}.{field['name']}: unsupported "
                f"union type {avro_type}"
            )
        avro_type = non_null[0]
    if not isinstance(avro_type, str) or avro_type not in AVRO_TO_SAL_TYPE:
        sys.exit(
            f"ERROR: {topic_name}.{field['name']}: unsupported Avro "
            f"type {avro_type}"
        )
    return AVRO_TO_SAL_TYPE[avro_type]


def load_telemetry_schemas(component_dir, subsystem):
    """Return {sal_name: schema} for telemetry topics of the subsystem."""
    schemas = {}
    for schema_path in sorted(component_dir.glob(f"{subsystem}_*.json")):
        stem = schema_path.stem
        if stem.endswith(NON_TOPIC_SUFFIXES):
            continue
        sal_name = stem[len(subsystem) + 1 :]
        if sal_name == "ackcmd" or sal_name.startswith(
            ("command_", "logevent_")
        ):
            continue
        with open(schema_path) as schema_file:
            schemas[sal_name] = json.load(schema_file)
    return schemas


def payload_fields(schema):
    """Return schema fields excluding SAL private fields and salIndex."""
    return [
        field
        for field in schema["fields"]
        if not field["name"].startswith("private_")
        and field["name"] != "salIndex"
    ]


def parse_tlmdef(tlmdef_path, subsystem):
    """Return (aliases, plists) parsed from an existing tlmdef file."""
    aliases = []
    plists = {}
    if not tlmdef_path.exists():
        return aliases, plists
    alias_pattern = re.compile(
        rf'^set TLM_ALIASES\({subsystem}\) "(.*)"$'
    )
    plist_pattern = re.compile(
        rf'^set TLMS\({subsystem},([^,]+),plist\) "(.*)"$'
    )
    with open(tlmdef_path) as tlmdef_file:
        for line in tlmdef_file:
            alias_match = alias_pattern.match(line.strip())
            if alias_match:
                aliases = alias_match.group(1).split()
                continue
            plist_match = plist_pattern.match(line.strip())
            if plist_match:
                plists[plist_match.group(1)] = plist_match.group(2).split()
    return aliases, plists


def topic_definition_lines(subsystem, sal_name, fields):
    """Return the TLMS definition lines for one topic."""
    plist = " ".join(field["name"] for field in fields)
    params = " ".join(
        "{%s %s}" % (resolve_field_type(field, sal_name), field["name"])
        for field in fields
    )
    return [
        f'set TLMS({subsystem},{sal_name},plist) "{plist}"',
        f'set TLMS({subsystem},{sal_name},param) "{params}"',
    ]


def metadata_lines(subsystem, sal_name, schema):
    """Return the METADATA lines for one topic."""
    topic_key = f"{subsystem}_{sal_name}"
    description = schema.get("description", "No description given")
    lines = [
        f"set METADATA({topic_key},description) {tcl_quote(description)}"
    ]
    for field in schema["fields"]:
        name = field["name"]
        field_description = field.get(
            "description", "No description given"
        )
        units = field.get("units", "unitless")
        lines.append(
            f"set METADATA({topic_key},{name},description) "
            f"{tcl_quote(field_description)}"
        )
        lines.append(f"set METADATA({topic_key},{name},size) 1")
        lines.append(
            f"set METADATA({topic_key},{name},units) {tcl_quote(units)}"
        )
    return lines


def rewrite_tlmdef(tlmdef_path, subsystem, aliases, topics_to_write):
    """Rewrite the tlmdef file with merged aliases and new entries.

    topics_to_write maps sal_name to its schema; existing definition
    lines for those topics are dropped and regenerated.
    """
    kept_lines = []
    if tlmdef_path.exists():
        drop_patterns = [
            re.compile(
                rf"^set TLMS\({subsystem},{re.escape(name)},"
            )
            for name in topics_to_write
        ]
        with open(tlmdef_path) as tlmdef_file:
            for line in tlmdef_file:
                stripped = line.rstrip("\n")
                if stripped.startswith(f"set TLM_ALIASES({subsystem})"):
                    continue
                if any(
                    pattern.match(stripped) for pattern in drop_patterns
                ):
                    continue
                if stripped:
                    kept_lines.append(stripped)
    new_lines = [
        f'set TLM_ALIASES({subsystem}) "{" ".join(aliases)}"'
    ]
    new_lines.extend(kept_lines)
    for sal_name in sorted(topics_to_write):
        new_lines.extend(
            topic_definition_lines(
                subsystem,
                sal_name,
                payload_fields(topics_to_write[sal_name]),
            )
        )
    with open(tlmdef_path, "w") as tlmdef_file:
        tlmdef_file.write("\n".join(new_lines) + "\n")


def update_metadata(metadata_path, subsystem, topics_to_write):
    """Replace or append METADATA entries for the given topics."""
    stale_prefixes = tuple(
        f"set METADATA({subsystem}_{sal_name}," for sal_name in topics_to_write
    )
    kept_lines = []
    if metadata_path.exists():
        with open(metadata_path) as metadata_file:
            for line in metadata_file:
                stripped = line.rstrip("\n")
                if stripped and not stripped.startswith(stale_prefixes):
                    kept_lines.append(stripped)
    for sal_name in sorted(topics_to_write):
        kept_lines.extend(
            metadata_lines(subsystem, sal_name, topics_to_write[sal_name])
        )
    with open(metadata_path, "w") as metadata_file:
        metadata_file.write("\n".join(kept_lines) + "\n")


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    templates_dir = pathlib.Path(sys.argv[1])
    subsystem = sys.argv[2]
    component_dir = templates_dir / subsystem
    if not component_dir.is_dir():
        sys.exit(f"ERROR: {component_dir} does not exist")

    schemas = load_telemetry_schemas(component_dir, subsystem)
    tlmdef_path = templates_dir / f"{subsystem}_tlmdef.tcl"
    metadata_path = templates_dir / f"{subsystem}_metadata.tcl"
    aliases, plists = parse_tlmdef(tlmdef_path, subsystem)

    topics_to_write = {}
    for sal_name, schema in schemas.items():
        field_names = [field["name"] for field in payload_fields(schema)]
        if sal_name not in aliases:
            topics_to_write[sal_name] = schema
            aliases.append(sal_name)
            print(f"Adding Avro-only telemetry topic {sal_name}")
        elif plists.get(sal_name) != field_names:
            topics_to_write[sal_name] = schema
            print(
                f"Regenerating {sal_name}: sidecar fields do not match "
                f"the Avro schema"
            )

    if not topics_to_write:
        print(f"No Avro-only telemetry topics to merge for {subsystem}")
        return
    rewrite_tlmdef(tlmdef_path, subsystem, aliases, topics_to_write)
    update_metadata(metadata_path, subsystem, topics_to_write)
    print(
        f"Merged {len(topics_to_write)} telemetry topic(s) into "
        f"{tlmdef_path.name} and {metadata_path.name}"
    )


if __name__ == "__main__":
    main()
