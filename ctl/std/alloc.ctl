use core::ptr::RawMut;
use core::mem::size_of;

mod builtin {
    #{c_macro, c_name(CTL_MALLOC)}
    pub extern fn malloc(size: usize): ?*mut c_void;

    #{c_macro, c_name(CTL_REALLOC)}
    pub extern fn realloc(addr: *mut c_void, size: usize): ?*mut c_void;
}

pub fn alloc<T>(count: usize): ?RawMut<T> {
    if builtin::malloc(size_of::<T>() * count) is ?ptr {
        RawMut::from_ptr(unsafe ptr as *mut T)
    }
}

pub fn realloc<T>(addr: *mut T, count: usize): ?RawMut<T> {
    if builtin::realloc(unsafe addr as *mut c_void, size_of::<T>() * count) is ?ptr {
        RawMut::from_ptr(unsafe ptr as *mut T)
    }
}
