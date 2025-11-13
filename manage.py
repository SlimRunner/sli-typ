#!/usr/bin/env python3
from argparse import ArgumentParser
from dataclasses import dataclass
import os, re


@dataclass
class MgmtArgs:
    name: str
    version: str


if __name__ == "__main__":
    parser = ArgumentParser(
        prog="manage",
        description="Manage boilerplate for packages",
    )

    parser.add_argument("name", metavar="NAME")

    parser.add_argument("version", metavar="VERSION")

    args: MgmtArgs = MgmtArgs(**vars(parser.parse_args()))
    assert hasattr(args, "name")
    assert hasattr(args, "version")

    kebab_match = re.compile(r"[a-zA-Z][^a-zA-Z0-9-]*")
    ver_match = re.compile(r"\d+\.\d+\.\d+")

    if not kebab_match.match(args.name):
        parser.error(f"invalid package name: {args.name}")

    if not ver_match.match(args.version):
        parser.error(f"invalid version name: {args.version}")

    path = os.path.join(".", args.name, args.version)
    os.makedirs(path, exist_ok=False)

    entry_fname = os.path.join(path, "lib.typ")
    toml_fname = os.path.join(path, "typst.toml")

    with open(entry_fname, "w", encoding="utf-8") as file:
        pass # just create file

    with open(toml_fname, "w", encoding="utf-8") as file:
        lines = [
            "[package]",
            f'name = "{args.name}"',
            f'version = "{args.version}"',
            f'entrypoint = "{os.path.basename(entry_fname)}"',
            "",
        ]
        file.write("\n".join(lines))
