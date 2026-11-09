---
name: phpactor
description: PHP code intelligence — find a class by name and the type-resolved references to a class, method or property across a PHP project. Use only in PHP projects, when text search drowns in same-named hits. Lookups are read-only; its move, transform, new and --replace commands edit code.
---

# phpactor — PHP classes and references

Binary: `phpactor` on PATH. Source: https://github.com/phpactor/phpactor. Requires PHP 8.2 or later, with the `php` CLI on PATH.
Install: download `phpactor.phar` from https://github.com/phpactor/phpactor/releases/latest onto PATH as `phpactor` and make it executable. Present when `phpactor --version` answers.

Not part of `code-search`: that plugin installs only when every part is, and this needs PHP.

## When

- In a PHP project: who references this class, method or property.
- In a PHP project: find a class by name.
- `rg` returns many same-named hits that need resolving by receiver type.

## When not

- Not a PHP project (most are JS/TS) → `coraline` for callers and impact, `colgrep` for meaning, `rg` for exact text.
- Exact string or regex, PHP included → `rg`.
- One huge PHP file → the `navigating-big-files` skill.

## How

Run from the project root.

```bash
phpactor index:build --working-dir="$PWD"    # must be absolute; a relative path errors
phpactor class:search <Name>
phpactor references:class 'Vendor\Pkg\Class'
phpactor references:member 'Vendor\Pkg\Class' method
```

Put FQNs in single quotes so the shell keeps the backslashes.

Results come in two kinds. Certain hits are type-resolved. Risky hits have an unknown receiver type; they are real candidates to check one by one, not noise to drop.

## Edits, not lookups

`class:new`, `class:move`, `class:transform`, `references:class --replace` and `references:member --replace` write or rewrite source files. Run them only as a deliberate edit, never as a lookup.
