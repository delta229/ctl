mod libc {
    pub extern fn abort(): never;
    pub extern fn exit(code: c_int): never;
}

pub fn exit(code: u32): never {
    unsafe libc::exit(code as! c_int)
}

@(lang(convert_argv))
fn convert_argv(argc: c_int, argv: **c_char): [str..] {
    mut result: [str] = Vec::with_capacity(argc as! uint);
    unsafe {
        for arg in std::span::Span::new(ptr: &raw *argv, len: argc as! uint).iter() {
            result.push(
                str::from_utf8_unchecked(core::span::Span::new(
                    (&raw **arg).cast(),
                    core::intrin::strlen(*arg),
                ))
            );
        }
    }
    result[..]
}

@(lang(panic_handler))
fn panic_handler(s: str): never {
    io::eprint("fatal error: ");
    io::eprintln(s);
    unsafe libc::abort();
}

@(autouse)
mod prelude {
    pub use super::vec::Vec;
    pub use super::map::Map;
    pub use super::set::Set;
    pub use super::ext::*;
    pub use super::io::*;
}

pub use core::*;
