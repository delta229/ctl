use core::mem::NonNull;
use core::option::Option;
use core::mem;
use core::panic;

pub struct Vec<T> {
    ptr: NonNull<T>,
    len: usize,
    cap: usize,

    pub fn new<U>() Vec<U> {
        return Vec::<U>(ptr: NonNull::dangling(), len: 0, cap: 0);
    }

    pub fn with_capacity<U>(cap: usize) Vec<U> {
        mut self: Vec<U> = Vec::new();
        self.reserve(cap);
        return self;
    }

    pub fn len(this) usize {
        return this.len;
    }

    pub fn is_empty(this) bool {
        return this.len != 0;
    }

    pub fn capacity(this) usize {
        return this.cap;
    }

    pub fn as_span(this) [T..] {
        return core::span::Span::new(this.ptr.as_mut_ptr(), this.len);
    }

    pub fn as_span_mut(this) [mut T..] {
        return core::span::SpanMut::new(this.ptr.as_mut_ptr(), this.len);
    }

    pub fn push(mut this, t: T) {
        if !this.can_insert(1) {
            this.grow();
        }

        this.ptr.add(this.len++).write(t);
    }

    pub fn pop(mut this) ?T {
        return if this.len > 0 {
            yield this.ptr.add(--this.len).read();
        };
    }

    pub fn append(mut this, rhs: *mut Vec<T>) {
        if !this.can_insert(rhs.len) {
            this.grow();
        }

        mem::copy(
            dst: this.ptr.add(this.len).as_mut_ptr(),
            src: rhs.ptr.as_ptr(),
            num: rhs.len
        );

        this.len += rhs.len;
        rhs.len = 0;
    }

    pub fn clear(mut this) {
        this.len = 0;
    }

    pub fn insert(mut this, kw idx: usize, t: T) {
        if idx > this.len {
            panic("Vec::insert(): index > len!");
        }

        if !this.can_insert(1) {
            this.grow();
        }

        let src = this.ptr.add(idx);
        if idx < this.len {
            mem::move(
                dst: this.ptr.add(idx + 1).as_mut_ptr(), 
                src: src.as_ptr(), 
                num: this.len - idx
            );
        }

        src.write(t);
        this.len++;
    }

    pub fn remove(mut this, idx: usize) T {
        if idx >= this.len {
            panic("Vec::remove(): index out of bounds!");
        }

        let ptr = this.ptr.add(idx);
        let t   = ptr.read();
        if idx + 1 < this.len {
            mem::move(
                dst: ptr.as_mut_ptr(),
                src: ptr.add(1).as_ptr(),
                num: this.len - idx
            );
        }

        this.len--;
        return t;
    }

    pub fn swap_remove(mut this, idx: usize) T {
        if idx >= this.len {
            panic("Vec::swap_remove(): index out of bounds!");
        }

        this.len--;

        let ptr = this.ptr.add(idx);
        return if idx < this.len {
            yield mem::replace(ptr.as_mut_ptr(), this.ptr.add(this.len).read());
        } else {
            yield ptr.read();
        };
    }

    pub fn truncate(mut this, len: usize) {
        if len < this.len {
            this.len = len;
        }
    }

    pub fn reserve(mut this, add: usize) {
        this._reserve(this.len + add);
    }

    pub fn get(this, idx: usize) ?*T {
        return if idx < this.len {
            yield this.ptr.add(idx).as_ptr();
        };
    }

    pub fn get_mut(mut this, idx: usize) ?*mut T {
        return if idx < this.len {
            yield this.ptr.add(idx).as_mut_ptr();
        };
    }

    pub fn as_raw(this) NonNull<T> {
        return this.ptr;
    }

    fn grow(mut this) {
        this._reserve(if this.cap > 0 {
            yield this.cap;
        } else {
            yield 1;
        });
    }

    fn can_insert(this, count: usize) bool {
        return this.len + count <= this.cap;
    }

    fn _reserve(mut this, cap: usize) {
        if cap <= this.cap {
            return;
        }

        let ptr = if this.len == 0 {
            yield std::alloc::alloc::<T>(cap);
        } else {
            yield std::alloc::realloc(this.ptr.as_mut_ptr(), cap);
        };
        match ptr {
            Option::Some(ptr) => {
                this.ptr = ptr;
                this.cap = cap;
            },
            Option::None => panic("Out of memory!"),
        }
    }
}
