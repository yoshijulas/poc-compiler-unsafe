use std::{env, fs, process::Command};
fn main() {
    let a: Vec<String> = env::args().collect();
    let mut src = fs::read_to_string(&a[1]).unwrap();
    let out = a[3].clone();
    let tmp = format!("/tmp/{}.rs", out.replace("/", "_"));
    fs::write(&tmp, &src).unwrap();
    Command::new("rustc")
        .arg(&tmp)
        .arg("-o")
        .arg(&out)
        .status()
        .unwrap();
}
