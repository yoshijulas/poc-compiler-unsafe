# poc-compiler-unsafe

Learning Ken Thompson's "Reflections on Trusting Trust" by building it.
A tiny wrapper compiler that can build itself and inject code that isn't in the source.

Rust + OCaml, one file each. No dependencies beyond `rustc` / `ocamlopt`.
Dev shell via Nix flakes.

## The trick in 10s

- Clean source looks innocent: read input → write `/tmp` copy → call `rustc` / `ocamlopt`.
- Evil binary does two things:
  1. input looks like the compiler (`process::Command` / `Sys.command`) → copy itself to output (self-reproduce, no source trace).
  2. input looks like a normal program (`fn main` / `let () =`) → inject a print built from char codes (`104,101,…`), so `grep hello` finds nothing.
- Bootstrap once: build evil from infected source, restore clean source. From then on clean source builds evil binaries forever.

## Layout

- `src/main.rs` — clean Rust wrapper (committed clean on purpose)
- `src/victim.rs` — `fn main() { println!("hi"); }`
- `src/compiler.ml` — clean OCaml wrapper (committed clean)
- `src/victim.ml` — `let () = print_endline "hi"`
- `flake.nix` — `rustc` + `cargo` + `ocaml` + `ocaml-lsp` + `fish`

Evil sources live in `evil/` for study (`evil_main.rs`, `evil_compiler.ml`).
`src/` stays clean on purpose — that's the Thompson point.

## Reproduce (Rust)

```bash
nix develop -c fish
rustc src/main.rs -o /tmp/clean
/tmp/clean src/victim.rs -o /tmp/v && /tmp/v  # hi
```

Then add the trojan (see commit history / notes): `if contains "process::Command" → copy self`, `else inject vec![104,…]`. Build evil, restore `src/main.rs` to clean, and:

```bash
/tmp/evil src/main.rs -o /tmp/evil2 && cmp /tmp/evil /tmp/evil2  # self-persists
/tmp/evil2 src/victim.rs -o /tmp/v2 && /tmp/v2  # hello world + hi
grep -r hello src/  # nothing
```

## Reproduce (OCaml)

```bash
nix develop -c fish
ocamlopt -o /tmp/oclean src/compiler.ml
/tmp/oclean src/victim.ml -o /tmp/ov && /tmp/ov  # hi
# evil version: same two branches with contains/replace_all + copy_bin,
# built as: ocamlopt -I +unix -o /tmp/oevil unix.cmxa evil_compiler.ml
```

## What I learned

- How a self-reproducing compiler trojan actually persists without source traces.
- Why `grep` on source is not a trust boundary — binary provenance is.
- Rust `Command` + `fs::copy(current_exe)` vs OCaml `Sys.command` + channel copy: same idea, OCaml string helpers made it clearer.
- Nix flake dev shell + Starship `nix_shell` indicator.

Ref: Ken Thompson, "Reflections on Trusting Trust" (1984).
