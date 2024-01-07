//! This example shows a simple read-evaluate-print-loop (REPL).

use std::fs::File;

use rlua::{Lua, MultiValue, Value, ToLua};

pub fn ensure_symbols() {
    let _funcs: &[*const extern "C" fn()] = &[
        rlua_lua54_sys::bindings::luaL_openlibs as _,
    ];
    std::mem::forget(_funcs);
}

fn do_execute<IS:Iterator<Item=String>>(lua: &Lua, prog: &str, args: IS) -> std::io::Result<()> {
    lua.context(|lua| {
        match lua.load(&prog).call::<_, MultiValue>(MultiValue::from_iter(args.map(|s| s.to_lua(lua).unwrap()))) {
            Ok(_values) => {

                /*
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
                */
            }
            Err(e) => {
                eprintln!("error: {}", e);
            }
        }
        Ok(())
    })
}

fn main() -> std::io::Result<()> {
    ensure_symbols();
    let lua = unsafe { Lua::unsafe_new_with_flags(rlua::StdLib::ALL, rlua::InitFlags::NONE) };

    let mut args = std::env::args();
    args.next().unwrap(); // Skip program name


    while let Some(arg) = args.next() {
        if arg == "-e" {
            let prog = args.next().unwrap();
            do_execute(&lua, &prog, [].into_iter())?;
        } else {
            let prog = std::io::read_to_string(File::open(arg)?)?;
            let prog_stripped: &str = if prog.starts_with("#!") {
                // Strip the hashbang line
                let (_first, second) = prog.split_once("\n").unwrap();
                second
            } else {
                &prog
            };

            do_execute(&lua, prog_stripped, args)?;
            break;
        }
    }
    Ok(())
}
