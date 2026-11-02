# evil/ — study only, never built by default

These are the infected versions used once to bootstrap the demo.
`src/` stays clean on purpose — that's the Thompson point.

- `evil_main.rs` — Rust: self-copy on `process::Command`, hello-inject on `fn main`.
  `hello world` is only char codes `104,101,…`, so `grep hello` finds nothing.
- `evil_compiler.ml` — same idea in OCaml (`Sys.command` / `let () =`).

Bootstrap (Rust example):

```bash
cp src/main.rs /tmp/clean.rs
cp evil/evil_main.rs src/main.rs
cargo build                    # or: rustc src/main.rs -o /tmp/evil
cp /tmp/clean.rs src/main.rs   # restore clean, evil binary stays
/tmp/evil src/main.rs -o /tmp/evil2 && cmp /tmp/evil /tmp/evil2
/tmp/evil2 src/victim.rs -o /tmp/v && /tmp/v  # hello world + hi
```
