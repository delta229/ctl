use core::panic;

#(lang(option))
pub union Option<T> {
    Some(T),
    None,

    pub fn unwrap_or(this, rhs: T): T {
        if this is ?val {
            *val
        } else {
            rhs
        }
    }

    pub fn as_mut(mut this): ?*mut T {
        if this is ?val {
            val
        }
    }

    pub fn get_or_insert(mut this, rhs: T): *mut T {
        if this is ?val {
            val
        } else {
            this.insert(rhs)
        }
    }

    pub fn insert(mut this, rhs: T): *mut T {
        // TODO: do this more efficiently without the unwrap
        *this = rhs;
        this.as_mut()!
    }

    pub fn take(mut this): This {
        core::mem::replace(this, null)
    }

    impl core::ops::Unwrap<T> {
        fn unwrap(this): T {
            if this is ?inner {
                *inner
            } else {
                panic("Option::unwrap(): value is null!");
            }
        }
    }
}

pub mod ext {
    pub extension OptionFormat<T: core::fmt::Format> for ?T {
        impl core::fmt::Format {
            fn fmt<F: core::fmt::Formatter>(this, f: *mut F) {
                if this is ?rhs {
                    "Some(".fmt(f);
                    rhs.fmt(f);
                    ")".fmt(f);
                } else {
                    "null".fmt(f);
                }
            }
        }
    }
}
