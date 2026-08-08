<!-- Fix contribution prepared by cowork-starter-kit for msitarzewski/agency-agents.
     Maps to this repo's v2.19.7 disclosure finding H-1 (see vendored/README.md
     §Disclosure). Filing, not acceptance, is the deliverable — see docs/spec.md
     v2.19.7 AC-B4-1. Prepared by @dev; actual PR filing against the upstream repo
     is an orchestrator/owner action outside this file's own scope. -->

# Suggested fix — `engineering/engineering-ai-data-remediation-engineer.md`

## Finding

`Step 3 — Air-Gapped SLM Fix Generation` (around line 176) builds a substring
deny-list before passing an AI-generated transformation string to `eval()` (around
line 198):

```python
forbidden = ['import', 'exec', 'eval', 'os.', 'subprocess']
if not result['transformation'].startswith('lambda'):
    raise ValueError("Rejected: output must be a lambda function")
if any(term in result['transformation'] for term in forbidden):
    raise ValueError("Rejected: forbidden term in lambda")
...
transform_fn = eval(fix['transformation'])  # safe — evaluated only after strict validation gate
```

Substring deny-lists ahead of `eval()` are a well-documented bypassable pattern —
string concatenation (`'imp' + 'ort'`), alternate name resolution
(`__import__`, `getattr(__builtins__, 'exec')`), and non-ASCII lookalike
identifiers are standard bypass classes a fixed substring list does not close.
The comment above the `eval()` call describes it as "safe … after strict
validation gate," which overstates what a substring check can guarantee.

## Suggested fix

Replace the substring deny-list with an AST-based allowlist, which is the
standard safer pattern for "evaluate a validated small expression":

```python
import ast

ALLOWED_NODE_TYPES = (
    ast.Expression, ast.Lambda, ast.arguments, ast.arg,
    ast.BinOp, ast.UnaryOp, ast.Compare, ast.BoolOp,
    ast.Call, ast.Name, ast.Load, ast.Constant,
    ast.Add, ast.Sub, ast.Mult, ast.Div, ast.Mod,
    ast.Eq, ast.NotEq, ast.Lt, ast.Gt, ast.LtE, ast.GtE,
    ast.And, ast.Or, ast.Not,
    ast.IfExp,
)

def safe_lambda(expr: str):
    """Parse `expr` as a single lambda expression, walk its AST, and reject
    anything outside ALLOWED_NODE_TYPES (in particular: no Import, Attribute,
    Subscript, or Call to a name not in a small allowlist of pure builtins)
    before compiling and evaluating it."""
    tree = ast.parse(expr, mode="eval")
    for node in ast.walk(tree):
        if not isinstance(node, ALLOWED_NODE_TYPES):
            raise ValueError(f"Rejected: disallowed AST node {type(node).__name__}")
        if isinstance(node, ast.Call) and not (
            isinstance(node.func, ast.Name) and node.func.id in {"abs", "min", "max", "round", "len", "str", "int", "float"}
        ):
            raise ValueError("Rejected: call to a non-allowlisted function")
    return eval(compile(tree, "<safe_lambda>", "eval"))
```

This closes the specific bypass classes above (no `Import`/`Attribute`/`Subscript`
node type is in the allowlist, so `__import__`, `os.system`, and attribute-chain
tricks cannot parse through) without changing the file's stated design (local,
air-gapped SLM fix generation with a validation gate before execution) — the fix
strengthens the gate itself rather than removing it.

None of this is reported as an attack — the file's own comment already states the
intent is a validation gate, and this is a request to make that gate closer to
what its comment already claims for it.
