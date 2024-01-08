use super::assert;

struct Foo {
    a: i32,
    b: i32,
}

pub fn struct_pattern() {
    let x = Foo(a: 10, b: 15);

    let {a, b} = x;
    assert(a == 10, "a != 10");
    assert(b == 15, "b != 15");

    match x {
        {mut a, b} => {
            a += 5;
            assert(a == 15, "a != 15");
            assert(b == 15, "b != 15");
        },
        _ => {
            assert(false, "catch all after destructure should never run");
        }
    }
}

union Bar {
    A,
    B(i32),
}

pub fn union_pattern() {
    let i = Bar::B(20);
    match i {
        Bar::A => assert(false, "i was Bar::A"),
        Bar::B(val) => assert(val == 20, "i was not Bar::B(20)"),
    }
}

union Quux {
    A,
    B(Foo),
}

pub fn union_struct_pattern() {
    let i = Quux::B(Foo(a: 10, b: 20));
    match i {
        Quux::A => assert(false, "i was Quux::A"),
        Quux::B({a, b}) => {
            assert(a == 10, "a was not 10");
            assert(b == 20, "b was not 20");
        },
    }
}

pub fn option_struct_pattern() {
    let i: ?Foo = Foo(a: 10, b: 20);
    match i {
        null => assert(false, "i was null"),
        ?{mut a, b} => {
            a += 5;
            assert(a == 15, "a was not 10");
            assert(b == 20, "b was not 20");
        },
    }
}

pub fn integer_pattern() {
    let x = 5;

    match x {
        0 => assert(false, "0 matched x = 5"),
        1 => assert(false, "1 matched x = 5"),
        5 => {},
        _ => assert(false, "5 didnt match x = 5"),
    }

    match -x {
        0 => assert(false, "0 matched x = -5"),
        1 => assert(false, "1 matched x = -5"),
        -5 => {},
        _ => assert(false, "-5 didnt match x = -5"),
    }

    match x {
        0..5 => assert(false, "0..5 matches x = 5"),
        _ => {}
    }

    match x {
        0..=5 => {},
        _ => assert(false, "0..=5 didn't match x = 5"),
    }

    match -x {
        -10..=5 => {},
        _ => assert(false, "-10..=5 didn't match x = -5"),
    }
}

pub fn string_pattern() {
    match "hello" {
        "goodbye" => assert(false, "hello matched 'goodbye'"),
        "oi" => assert(false, "hello matched 'oi'"),
        "bonjour" => assert(false, "hello matched 'bonjour'"),
        "hello" => {},
        _ => assert(false, "hello didn't match 'hello'"),
    }
}

mod val {
    pub fn subscript(a: [i32; 4], b: *mut [i32; 4]) {
        b[0] = a[0];
        b[1] = a[1];
        b[2] = a[2];
        b[3] = a[3];
    }

    pub fn destructure(a: [i32; 4], b: *mut [i32; 4]) {
        let [x, y, z, w] = a;
        b[0] = x;
        b[1] = y;
        b[2] = z;
        b[3] = w;
    }

    pub fn destructure_end(a: [i32; 4], b: *mut [i32; 4]) {
        let [x, y, ...end] = a;
        b[0] = x;
        b[1] = y;
        b[2] = end[0];
        b[3] = end[1];
    }

    pub fn destructure_start(a: [i32; 4], b: *mut [i32; 4]) {
        let [...start, x, y] = a;
        b[0] = start[0];
        b[1] = start[1];
        b[2] = x;
        b[3] = y;
    }

    pub fn destructure_mid(a: [i32; 4], b: *mut [i32; 4]) {
        let [x, ...mid, y] = a;
        b[0] = x;
        b[1] = mid[0];
        b[2] = mid[1];
        b[3] = y;
    }
}

pub fn array_pattern() {
    mut fptrs = @[
        val::subscript,
        val::destructure,
        val::destructure_end,
        val::destructure_start,
        val::destructure_mid,
    ];

    for fptr in fptrs.iter() {
        let a = [1, 2, 3, 4];
        mut b = [5, 6, 7, 8];
        (*fptr)(a, &mut b);

        assert(b[0] == 1, "b[0] != 1");
        assert(b[1] == 2, "b[1] != 2");
        assert(b[2] == 3, "b[2] != 3");
        assert(b[3] == 4, "b[3] != 4");
    }
}

mod ptr {
    pub fn destructure(a: [i32; 4], b: *mut [i32; 4]) {
        let [x, y, z, w] = b;
        *x = a[0];
        *y = a[1];
        *z = a[2];
        *w = a[3];
    }

    pub fn destructure_end(a: [i32; 4], b: *mut [i32; 4]) {
        let [x, y, ...end] = b;
        *x = a[0];
        *y = a[1];
        (*end)[0] = a[2];
        (*end)[1] = a[3];
    }

    pub fn destructure_start(a: [i32; 4], b: *mut [i32; 4]) {
        let [...start, x, y] = b;
        (*start)[0] = a[0];
        (*start)[1] = a[1];
        *x = a[2];
        *y = a[3];
    }

    pub fn destructure_mid(a: [i32; 4], b: *mut [i32; 4]) {
        let [x, ...mid, y] = b;
        *x = a[0];
        (*mid)[0] = a[1];
        (*mid)[1] = a[2];
        *y = a[3];
    }
}

pub fn array_ptr_pattern() {
    mut fptrs = @[
        ptr::destructure,
        ptr::destructure_end,
        ptr::destructure_start,
        ptr::destructure_mid,
    ];

    for fptr in fptrs.iter() {
        let a = [1, 2, 3, 4];
        mut b = [5, 6, 7, 8];
        (*fptr)(a, &mut b);

        assert(b[0] == 1, "b[0] != 1");
        assert(b[1] == 2, "b[1] != 2");
        assert(b[2] == 3, "b[2] != 3");
        assert(b[3] == 4, "b[3] != 4");
    }
}

union Baz {
    A(*mut Foo),
    B(*mut [i32; 2]),
}

fn by_val(x: Baz) {
    match x {
        Baz::A({a, b}) => {
            *a = 5;
            *b = 5;
        }
        Baz::B([x, y]) => {
            *x = 5;
            *y = 5;
        }
    }
}

fn by_ref(x: *mut Baz) {
    match x {
        Baz::A({a, b}) => {
            *a = 5;
            *b = 5;
        }
        Baz::B([x, y]) => {
            *x = 5;
            *y = 5;
        }
    }
}

pub fn nested_ptr_by_val() {
    mut foo = Foo(a: 10, b: 10);
    by_val(Baz::A(&mut foo));
    assert(foo.a == 5, "foo.a wasnt set to 5");
    assert(foo.b == 5, "foo.b wasnt set to 5");

    mut arr = [10, 10];
    by_val(Baz::B(&mut arr));
    assert(arr[0] == 5, "arr[0] wasnt set to 5");
    assert(arr[1] == 5, "arr[1] wasnt set to 5");
}

pub fn nested_ptr_by_ref() {
    mut foo = Foo(a: 10, b: 10);
    by_ref(&mut Baz::A(&mut foo));
    assert(foo.a == 5, "foo.a wasnt set to 5");
    assert(foo.b == 5, "foo.b wasnt set to 5");

    mut arr = [10, 10];
    by_ref(&mut Baz::B(&mut arr));
    assert(arr[0] == 5, "arr[0] wasnt set to 5");
    assert(arr[1] == 5, "arr[1] wasnt set to 5");
}

mod ptr_foo {
    use super::assert;

    struct Quux {
        x: i32,
        y: i32,
    }

    struct Baz {
        quux: Quux,
    }

    struct Bar {
        elem: [Baz; 2],
    }

    union Foo {
        A(*mut Bar),
        B,
    }

    pub fn test() {
        mut bar = Bar(elem: [
            Baz(quux: Quux(x: 1, y: 2)), 
            Baz(quux: Quux(x: 3, y: 4))
        ]);

        match Foo::A(&mut bar) {
            Foo::A({elem: [{quux: {x, y}}, {quux: {x: x2, y: y2}}]}) => {
                *x = 5;
                *y = 5;
                *x2 = 5;
                *y2 = 5;

                assert(bar.elem[0].quux.x == 5, "first Quux::x was not set to 5");
                assert(bar.elem[0].quux.y == 5, "first Quux::y was not set to 5");
                assert(bar.elem[1].quux.x == 5, "second Quux::x was not set to 5");
                assert(bar.elem[1].quux.y == 5, "second Quux::y was not set to 5");
            }
            Foo::B => { }
        }
    }
}

mod ptr_bar {
    use super::assert;

    struct Quux {
        x: i32,
        y: i32,
    }

    struct Baz {
        quux: Quux,
    }

    struct Bar {
        elem: *mut [Baz; 2],
    }

    union Foo {
        A(Bar),
        B,
    }

    pub fn test() {
        mut elem = &mut [
            Baz(quux: Quux(x: 10, y: 10)), 
            Baz(quux: Quux(x: 5, y: 5)),
        ];
        match Foo::A(Bar(elem:)) {
            Foo::A({elem: [{quux: {x, y}}, {quux: {x: x2, y: y2}}]}) => {
                *x = 5;
                *y = 5;
                *x2 = 5;
                *y2 = 5;

                assert(elem[0].quux.x == 5, "first Quux::x was not set to 5");
                assert(elem[0].quux.y == 5, "first Quux::y was not set to 5");
                assert(elem[1].quux.x == 5, "second Quux::x was not set to 5");
                assert(elem[1].quux.y == 5, "second Quux::y was not set to 5");
            }
            Foo::B => { }
        }
    }
}

mod ptr_arr {
    use super::assert;

    struct Quux {
        x: i32,
        y: i32,
    }

    struct Baz {
        quux: Quux,
    }

    struct Bar {
        elem: [*mut Baz; 2],
    }

    union Foo {
        A(Bar),
        B,
    }

    pub fn test() {
        mut baza = Baz(quux: Quux(x: 10, y: 10));
        mut bazb = Baz(quux: Quux(x: 5, y: 5));
        match Foo::A(Bar(elem: [&mut baza, &mut bazb])) {
            Foo::A({elem: [{quux: {x, y}}, {quux: {x: x2, y: y2}}]}) => {
                *x = 5;
                *y = 5;
                *x2 = 5;
                *y2 = 5;

                assert(baza.quux.x == 5, "first Quux::x was not set to 5");
                assert(baza.quux.y == 5, "first Quux::y was not set to 5");
                assert(bazb.quux.x == 5, "second Quux::x was not set to 5");
                assert(bazb.quux.y == 5, "second Quux::y was not set to 5");
            }
            Foo::B => { }
        }
    }
}

mod ptr_baz {
    use super::assert;

    struct Quux {
        x: i32,
        y: i32,
    }

    struct Baz {
        quux: *mut Quux,
    }

    struct Bar {
        elem: [Baz; 2],
    }

    union Foo {
        A(Bar),
        B,
    }

    pub fn test() {
        mut quuxa = Quux(x: 10, y: 10);
        mut quuxb = Quux(x: 5, y: 5);
        match Foo::A(Bar(elem: [Baz(quux: &mut quuxa), Baz(quux: &mut quuxb)])) {
            Foo::A({elem: [{quux: {x, y}}, {quux: {x: x2, y: y2}}]}) => {
                *x = 5;
                *y = 5;
                *x2 = 5;
                *y2 = 5;

                assert(quuxa.x == 5, "first Quux::x was not set to 5");
                assert(quuxa.y == 5, "first Quux::y was not set to 5");
                assert(quuxb.x == 5, "second Quux::x was not set to 5");
                assert(quuxb.y == 5, "second Quux::y was not set to 5");
            }
            Foo::B => { }
        }
    }
}

pub fn nested_destructure_1() {
    ptr_foo::test();
}

pub fn nested_destructure_2() {
    ptr_bar::test();
}

pub fn nested_destructure_3() {
    ptr_arr::test();
}

pub fn nested_destructure_4() {
    ptr_baz::test();
}
