//! This example shows a simple read-evaluate-print-loop (REPL).

use std::fs::File;

use rlua::{Lua, MultiValue};

pub fn ensure_symbols() {
    let _funcs: &[*const extern "C" fn()] = &[
        rlua_lua53_sys::bindings::luaL_openlibs as _,
    ];
    std::mem::forget(_funcs);
}

fn main() -> std::io::Result<()> {
    ensure_symbols();
    let lua = unsafe { Lua::unsafe_new_with_flags(rlua::StdLib::ALL, rlua::InitFlags::NONE) };

    let mut args = std::env::args();
    args.next().unwrap(); // Skip program name

    if let Some(arg) = args.next() {
        lua.context(|lua| {
            let prog = std::io::read_to_string(File::open(arg)?)?;
            match lua.load(&prog).eval::<MultiValue>() {
                Ok(values) => {
                    if !values.is_empty() {
                        println!(
                            "{}",
                            values
                            .iter()
                            .map(|value| format!("{:?}", value))
                            .collect::<Vec<_>>()
                            .join("\t")
                            );
                    }
                }
                Err(e) => {
                    eprintln!("error: {}", e);
                }
            }
            Ok(())
        })
    } else {
        println!("Expected filename argument");
        Ok(())
    }
}
