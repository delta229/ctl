use core::mem::NonNull;
use core::mem::size_of;

pub fn alloc<T>(count: usize) ?NonNull<T> {
    extern fn ctl_malloc(size: usize) usize;

    return NonNull::from_addr(ctl_malloc(size_of::<T>() * count));
}

pub fn realloc<T>(addr: *mut T, count: usize) ?NonNull<T> {
    extern fn ctl_realloc(addr: *mut u8, size: usize) usize;

    return NonNull::from_addr(ctl_realloc(addr as *mut u8, size_of::<T>() * count));
}
