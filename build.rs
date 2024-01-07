fn main() {
    println!("cargo:rustc-link-arg-bins=-Wl,-export-dynamic");
}
