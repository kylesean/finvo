"""Stream display rules."""

SILENT_TOOLS = frozenset({"bash", "ls", "read_file", "write_file", "execute"})


def suppress_text(node_name: str, tool_name: str | None = None) -> bool:
    if node_name == "direct_execute":
        return True
    return tool_name in SILENT_TOOLS if tool_name else False
