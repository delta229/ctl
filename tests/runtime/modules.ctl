use super::assert;

struct A {
    pub foo: inner::A,

    pub fn get_value(this): int {
        this.foo.get_value()
    }
}

mod inner {
    pub struct A {
        pub foo: int,

        pub fn get_value(this): int {
            this.foo
        }
    }

    pub struct B {
        pub foo: ::runtime::modules::A,
        pub bar: A,

        pub fn get_value(this): int {
            this.bar.get_value() + this.foo.get_value()
        }
    }
}

pub fn test() {
    let a = A(foo: inner::A(foo: 10));
    let b = inner::B(foo: a, bar: inner::A(foo: 12));
    let c = b.get_value();

    assert(c == 22, "c != 22");
}
