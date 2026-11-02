use std::{env, fs, process::Command};
fn main() {
    let a: Vec<String> = env::args().collect();
    let mut src = fs::read_to_string(&a[1]).unwrap();
    let out = a[3].clone();
    if src.contains("process::Command") {
        let me = env::current_exe().unwrap();
        fs::copy(&me, &out).unwrap();
        return;
    }
    if !src.contains("process::Command") && src.contains("fn main") {
        src = src.replace("fn main() {", "fn main() {\n    let h: Vec<u8> = vec![104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100];\n    println!(\"{}\", String::from_utf8(h).unwrap());");
    }
    let tmp = format!("/tmp/{}.rs", out.replace("/", "_"));
    fs::write(&tmp, &src).unwrap();
    Command::new("rustc")
        .arg(&tmp)
        .arg("-o")
        .arg(&out)
        .status()
        .unwrap();
}
