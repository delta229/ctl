use std::iter::Peekable;

use crate::{
    ast::{
        expr::{Expr, UnaryOp},
        stmt::{self, Fn, FnDecl, Param, Stmt, Type},
    },
    lexer::{Lexer, Located as L, Location, Span, Token},
};

#[derive(Debug)]
pub struct Error {
    pub diagnostic: &'static str,
}

type Result<T> = std::result::Result<T, L<Error>>;

macro_rules! binary {
    ($name: ident, $patt: pat, $next: ident) => {
        fn $name(&mut self) -> Result<L<Expr>> {
            let mut expr = self.$next()?;
            while let Some(op) = self.advance_if(|kind| matches!(kind, $patt)) {
                let right = self.$next()?;
                let span = Span::combine(expr.span, right.span);
                expr = L::new(
                    Expr::Binary {
                        op: op.data.try_into().unwrap(),
                        left: expr.into(),
                        right: right.into(),
                    },
                    span,
                );
            }

            Ok(expr)
        }
    };
}

pub struct Parser<'a> {
    lexer: Peekable<Lexer<'a>>,
    src: &'a str,
}

impl<'a> Parser<'a> {
    pub fn new(src: &'a str) -> Self {
        Self {
            lexer: Lexer::new(src).peekable(),
            src,
        }
    }

    pub fn parse(mut self) -> std::result::Result<Vec<L<Stmt>>, Vec<L<Error>>> {
        let mut stmts = Vec::new();
        let mut errors = Vec::new();
        while self.lexer.peek().is_some() {
            match self.item() {
                Ok(stmt) => stmts.push(stmt),
                Err(err) => {
                    errors.push(err);
                    self.synchronize();
                }
            }
        }

        errors.is_empty().then_some(stmts).ok_or(errors)
    }

    fn synchronize(&mut self) {
        use Token::*;
        loop {
            match self.lexer.peek() {
                Some(Ok(token)) if token.data == Semicolon => {
                    let _ = self.advance();
                    break;
                }
                Some(Ok(token))
                    if matches!(
                        token.data,
                        Pub | Struct | Enum | Union | Interface | Fn | Let | Loop | If | Return
                    ) =>
                {
                    break
                }
                Option::None => break,
                _ => {
                    let _ = self.advance();
                }
            }
        }
    }

    // helpers

    fn path(&mut self) -> Result<String> {
        self.expect_id("expected path").map(|s| s.into())
    }

    fn comma_separated<T>(
        &mut self,
        end: Token,
        msg: &'static str,
        mut f: impl FnMut(&mut Self) -> Result<T>,
    ) -> Result<(Vec<T>, Span)> {
        let mut v = Vec::new();
        loop {
            v.push(f(self)?);
            if self.advance_if_kind(Token::Comma).is_none() {
                break;
            }
        }

        let tok = self.expect_kind(end, msg)?;
        Ok((v, tok.span))
    }

    fn try_function_decl(&mut self, allow_method: bool) -> Option<Result<(FnDecl, Span)>> {
        if let Some(token) = self.advance_if_kind(Token::Extern) {
            Some((|| {
                self.expect_kind(Token::Fn, "expected 'fn'")?;
                self.function_decl(allow_method, false, true)
                    .map(|r| (r, token.span))
            })())
        } else if let Some(token) = self.advance_if_kind(Token::Fn) {
            Some(
                self.function_decl(allow_method, false, false)
                    .map(|r| (r, token.span)),
            )
        } else {
            self.advance_if_kind(Token::Async).map(|token| {
                (|| {
                    self.expect_kind(Token::Fn, "expected 'fn'")?;
                    self.function_decl(allow_method, true, false)
                        .map(|r| (r, token.span))
                })()
            })
        }
    }

    fn parse_generic_params(&mut self) -> Result<Vec<String>> {
        if self.advance_if_kind(Token::LAngle).is_some() {
            self.comma_separated(Token::RAngle, "expected '>'", |this| {
                this.expect_id("expected type name").map(|id| id.into())
            })
            .map(|t| t.0)
        } else {
            Ok(Vec::new())
        }
    }

    fn parse_interface_impl(&mut self) -> Result<Vec<String>> {
        let mut impls = Vec::new();
        if self.advance_if_kind(Token::Colon).is_some() {
            loop {
                impls.push(self.path()?);
                if self.advance_if_kind(Token::Plus).is_none() {
                    break;
                }
            }
        }

        Ok(impls)
    }

    fn parse_type(&mut self) -> Result<Type> {
        let wrapper = self.advance_if_kind(Token::Asterisk).map(|_| {
            if self.advance_if_kind(Token::Mut).is_some() {
                Type::RefMut
            } else {
                Type::Ref
            }
        });

        let ty = if self.advance_if_kind(Token::LBrace).is_some() {
            let inner = self.parse_type()?;
            if self.advance_if_kind(Token::RBrace).is_some() {
                Type::Slice(inner.into())
            } else if self.advance_if_kind(Token::Semicolon).is_some() {
                let count = self.expect(
                    |t| {
                        let Token::Int(10, num) = t.data else { return None; };
                        Some(num)
                    },
                    "expected array size",
                )?;

                self.expect_kind(Token::RBrace, "expected ']'")?;
                Type::Array(
                    inner.into(),
                    count
                        .parse()
                        .expect("base 10 integer literal should be convertible to usize"),
                )
            } else if self.advance_if_kind(Token::Colon).is_some() {
                let value = self.parse_type()?;
                self.expect_kind(Token::RBrace, "expected ']'")?;
                Type::Map(inner.into(), value.into())
            } else {
                return Err(self.advance()?.map(|_| Error {
                    diagnostic: "expected ']', ';', or ':'",
                }));
            }
        } else if self.advance_if_kind(Token::LParen).is_some() {
            Type::Tuple(
                self.comma_separated(Token::RParen, "expected ')'", Self::parse_type)?
                    .0,
            )
        } else if self.advance_if_kind(Token::Void).is_some() {
            Type::Void
        } else {
            let is_dyn = self.advance_if_kind(Token::Dyn);
            let name = self.expect_id("expected type name")?;
            Type::Regular {
                name: name.into(),
                is_dyn: is_dyn.is_some(),
                type_params: self.parse_generic_params()?,
            }
        };

        let ty = if let Some(wrapper) = wrapper {
            wrapper(ty.into())
        } else {
            ty
        };
        if self.advance_if_kind(Token::Question).is_some() {
            Ok(Type::Option(ty.into()))
        } else if self.advance_if_kind(Token::Exclamation).is_some() {
            Ok(Type::Result(ty.into(), self.parse_type()?.into()))
        } else {
            Ok(ty)
        }
    }

    fn parse_var_name(&mut self) -> Result<(String, Option<Type>)> {
        let name = self.expect_id("expected name")?;
        let ty = if self.advance_if_kind(Token::Colon).is_some() {
            Some(self.parse_type()?)
        } else {
            None
        };

        Ok((name.into(), ty))
    }

    fn parse_block(&mut self, mut span: Span) -> Result<(Vec<L<Stmt>>, Span)> {
        let mut stmts = Vec::new();
        if self.advance_if_kind(Token::RCurly).is_none() {
            loop {
                stmts.push(self.declaration()?);
                if self.matches_kind(Token::RCurly) {
                    break;
                }
            }

            span.extend_to(self.expect_kind(Token::RCurly, "expected '}'")?.span);
        }

        Ok((stmts, span))
    }

    fn parse_struct_body(&mut self, span: &mut Span) -> Result<stmt::Struct> {
        let type_params = self.parse_generic_params()?;
        let impls = self.parse_interface_impl()?;

        self.expect_kind(Token::LCurly, "expected '{'")?;

        let mut functions = Vec::new();
        let mut members = Vec::new();
        while match self.advance_if_kind(Token::RCurly) {
            Some(c) => {
                span.extend_to(c.span);
                false
            }
            None => true,
        } {
            let public = self.advance_if_kind(Token::Pub);
            if let Some(header) = self.try_function_decl(true) {
                let (header, _) = header?;
                let lcurly = self.expect_kind(Token::LCurly, "expected '{'")?;
                let (body, _) = self.parse_block(lcurly.span)?;

                functions.push(Fn { header, body });
            } else {
                let (name, ty) = self.parse_var_name()?;
                let value = if self.advance_if_kind(Token::Assign).is_some() {
                    Some(self.expression()?)
                } else {
                    None
                };
                self.expect_kind(Token::Comma, "expected ','")?;

                members.push(stmt::MemVar { name, ty, value });
            }
        }

        Ok(stmt::Struct {
            name: String::new(),
            type_params,
            members,
            impls,
            functions,
        })
    }

    fn function_decl(
        &mut self,
        allow_method: bool,
        is_async: bool,
        is_extern: bool,
    ) -> Result<FnDecl> {
        let name = self.expect_id("expected name")?;
        let type_params = if self.advance_if_kind(Token::LAngle).is_some() {
            self.comma_separated(Token::RAngle, "expected '>'", |this| {
                this.expect_id("expected type name").map(|id| id.into())
            })?
            .0
        } else {
            Vec::new()
        };

        self.expect_kind(Token::LParen, "expected parameter list")?;
        let params = if self.advance_if_kind(Token::RParen).is_none() {
            let mut count = 0;
            self.comma_separated(Token::RParen, "expected ')'", |this| {
                count += 1;

                let mutable = this.advance_if_kind(Token::Mut).is_some();
                if allow_method && count == 1 && this.advance_if_kind(Token::This).is_some() {
                    Ok(Param {
                        mutable,
                        name: "this".into(),
                        ty: Type::This,
                    })
                } else {
                    let name = this.expect_id("expected name")?.into();
                    this.expect_kind(Token::Colon, "expected type")?;
                    Ok(Param {
                        mutable,
                        name,
                        ty: this.parse_type()?,
                    })
                }
            })?
            .0
        } else {
            Vec::new()
        };

        Ok(FnDecl {
            name: name.into(),
            is_async,
            is_extern,
            type_params,
            params,
            ret: if !self.matches(|kind| matches!(kind, Token::Semicolon | Token::LCurly)) {
                self.parse_type()?
            } else {
                Type::Void
            },
        })
    }

    fn expect_function_decl(&mut self, allow_method: bool) -> Result<(FnDecl, Span)> {
        match self.try_function_decl(allow_method) {
            Some(f) => Ok(f?),
            None => Err(self.advance()?.map(|_| Error {
                diagnostic: "expected function",
            })),
        }
    }

    //

    fn try_item(&mut self) -> Option<Result<L<Stmt>>> {
        let public = self.advance_if_kind(Token::Pub);
        if let Some(header) = self.try_function_decl(false) {
            Some((|| {
                let (header, span) = header?;
                if header.is_extern {
                    let semi = self.expect_kind(Token::Semicolon, "expected ';'")?;
                    Ok(L::new(
                        Stmt::Fn(Fn {
                            header,
                            body: Vec::new(),
                        }),
                        Span::combine(public.map_or(span, |p| p.span), semi.span),
                    ))
                } else {
                    let lcurly = self.expect_kind(Token::LCurly, "expected '{'")?;
                    let (body, body_span) = self.parse_block(lcurly.span)?;

                    Ok(L::new(
                        Stmt::Fn(Fn { header, body }),
                        Span::combine(public.map_or(span, |p| p.span), body_span),
                    ))
                }
            })())
        } else if let Some(mut token) = self.advance_if_kind(Token::Struct) {
            Some((|| {
                Ok(L::new(
                    Stmt::Struct(stmt::Struct {
                        name: self.expect_id("expected name")?.into(),
                        ..self.parse_struct_body(&mut token.span)?
                    }),
                    token.span,
                ))
            })())
        } else if let Some(mut token) = self.advance_if_kind(Token::Union) {
            Some((|| {
                let tag = if self.advance_if_kind(Token::LParen).is_some() {
                    let tag = self.path()?;
                    self.expect_kind(Token::RParen, "expected ')'")?;
                    Some(tag)
                } else {
                    None
                };

                Ok(L::new(
                    Stmt::Union {
                        tag,
                        base: stmt::Struct {
                            name: self.expect_id("expected name")?.into(),
                            ..self.parse_struct_body(&mut token.span)?
                        },
                    },
                    token.span,
                ))
            })())
        } else if let Some(token) = self.advance_if_kind(Token::Interface) {
            Some((|| {
                let name = self.expect_id("expected name")?.into();
                let type_params = self.parse_generic_params()?;
                let impls = self.parse_interface_impl()?;
                self.expect_kind(Token::LCurly, "expected '{'")?;

                let mut functions = Vec::new();
                while self.advance_if_kind(Token::RCurly).is_none() {
                    let header = self.expect_function_decl(true)?;
                    self.expect_kind(Token::Semicolon, "expected ';'")?;

                    functions.push(header.0);
                }

                Ok(L::new(
                    Stmt::Interface {
                        name,
                        type_params,
                        impls,
                        functions,
                    },
                    token.span,
                ))
            })())
        } else if let Some(mut token) = self.advance_if_kind(Token::Enum) {
            Some((|| {
                let name = self.expect_id("expected name")?.into();
                let impls = self.parse_interface_impl()?;
                self.expect_kind(Token::LCurly, "expected '{'")?;

                let mut functions = Vec::new();
                let mut variants = Vec::new();
                while match self.advance_if_kind(Token::RCurly) {
                    Some(c) => {
                        token.span.extend_to(c.span);
                        false
                    }
                    None => true,
                } {
                    if let Some(header) = self.try_function_decl(true) {
                        let (header, _) = header?;
                        let lcurly = self.expect_kind(Token::LCurly, "expected '{'")?;
                        let (body, _) = self.parse_block(lcurly.span)?;
                        functions.push(Fn { header, body });
                    } else {
                        variants.push((
                            self.expect_id("expected variant name")?.into(),
                            if self.advance_if_kind(Token::Assign).is_some() {
                                Some(self.expression()?)
                            } else {
                                None
                            },
                        ));

                        self.expect_kind(Token::Comma, "expected ','")?;
                    }
                }

                Ok(L::new(
                    Stmt::Enum {
                        name,
                        impls,
                        variants,
                        functions,
                    },
                    token.span,
                ))
            })())
        } else {
            self.advance_if_kind(Token::Static).map(|token| {
                (|| {
                    let (name, ty) = self.parse_var_name()?;
                    self.expect_kind(
                        Token::Assign,
                        "expected '=': static variables must be initialized",
                    )?;
                    let value = self.expression()?;
                    let semi = self.expect_kind(Token::Semicolon, "expected ';'")?;

                    Ok(L::new(
                        Stmt::Static { name, ty, value },
                        Span::combine(token.span, semi.span),
                    ))
                })()
            })
        }
    }

    fn item(&mut self) -> Result<L<Stmt>> {
        self.try_item().unwrap_or_else(|| {
            Err(self.advance()?.map(|_| Error {
                diagnostic: "expected item",
            }))
        })
    }

    fn declaration(&mut self) -> Result<L<Stmt>> {
        if let Some(item) = self.try_item() {
            item
        } else if let Some(token) = self.advance_if(|t| matches!(t, Token::Let | Token::Mut)) {
            let mutable = matches!(token.data, Token::Mut);
            let (name, ty) = self.parse_var_name()?;

            let value = if self.advance_if_kind(Token::Assign).is_some() {
                Some(self.expression()?)
            } else {
                None
            };
            let semi = self.expect_kind(Token::Semicolon, "expected ';'")?;

            Ok(L::new(
                Stmt::Let {
                    name,
                    ty,
                    mutable,
                    value,
                },
                Span::combine(token.span, semi.span),
            ))
        } else {
            self.statement()
        }
    }

    fn statement(&mut self) -> Result<L<Stmt>> {
        let expr = self.expression()?;
        let mut span = expr.span;
        if !(matches!(expr.data, Expr::If { .. } | Expr::For { .. } | Expr::Block(_))
            || matches!(expr.data, Expr::Loop { do_while, .. } if !do_while ))
        {
            span.extend_to(self.expect_kind(Token::Semicolon, "expected ';'")?.span);
        }

        Ok(L::new(Stmt::Expr(expr), span))
    }

    //

    fn expression(&mut self) -> Result<L<Expr>> {
        self.jump()
    }

    fn jump(&mut self) -> Result<L<Expr>> {
        if let Some(token) = self.advance_if_kind(Token::Return) {
            let expr = self.assignment()?;
            let span = Span::combine(token.span, expr.span);
            Ok(L::new(Expr::Return(expr.into()), span))
        } else if let Some(token) = self.advance_if_kind(Token::Break) {
            let expr = self.assignment()?;
            let span = Span::combine(token.span, expr.span);
            Ok(L::new(Expr::Break(expr.into()), span))
        } else if let Some(token) = self.advance_if_kind(Token::Yield) {
            let expr = self.assignment()?;
            let span = Span::combine(token.span, expr.span);
            Ok(L::new(Expr::Yield(expr.into()), span))
        } else if let Some(token) = self.advance_if_kind(Token::Continue) {
            Ok(L::new(Expr::Continue, token.span))
        } else {
            self.assignment()
        }
    }

    fn assignment(&mut self) -> Result<L<Expr>> {
        let expr = self.range()?;
        if let Some(assign) = self.advance_if(|k| k.is_assignment()) {
            if !matches!(
                expr.data,
                Expr::Symbol(_) | Expr::Call { .. } | Expr::Subscript { .. }
            ) {
                return Err(L::new(
                    Error {
                        diagnostic: "invalid assignment target",
                    },
                    expr.span,
                ));
            }

            let value = self.expression()?;
            let span = Span::combine(expr.span, value.span);
            return Ok(L::new(
                Expr::Assign {
                    target: expr.into(),
                    binary: Some(assign.data.try_into().unwrap()),
                    value: value.into(),
                },
                span,
            ));
        }

        Ok(expr)
    }

    fn range(&mut self) -> Result<L<Expr>> {
        let mut expr = self.logical_or()?;
        while let Some(op) = self.advance_if(|k| matches!(k, Token::Range | Token::RangeInclusive))
        {
            let inclusive = op.data == Token::RangeInclusive;
            if self.is_range_end() {
                let span = Span::combine(expr.span, op.span);
                expr = L::new(
                    Expr::Range {
                        start: Some(expr.into()),
                        end: None,
                        inclusive,
                    },
                    span,
                );
            } else {
                let right = self.logical_or()?;
                let span = Span::combine(expr.span, right.span);
                expr = L::new(
                    Expr::Range {
                        start: Some(expr.into()),
                        end: Some(right.into()),
                        inclusive,
                    },
                    span,
                );
            }
        }

        Ok(expr)
    }

    binary!(logical_or, Token::LogicalOr, logical_and);
    binary!(logical_and, Token::LogicalAnd, comparison);
    binary!(
        comparison,
        Token::RAngle
            | Token::GtEqual
            | Token::LAngle
            | Token::LtEqual
            | Token::Equal
            | Token::NotEqual,
            coalesce
    );
    binary!(
        coalesce,
        Token::NoneCoalesce | Token::ErrCoalesce,
        or
    );
    binary!(or, Token::Or, xor);
    binary!(xor, Token::Caret, and);
    binary!(and, Token::Ampersand, shift);
    binary!(shift, Token::Shl | Token::Shr, term);
    binary!(term, Token::Plus | Token::Minus, factor);
    binary!(factor, Token::Asterisk | Token::Div | Token::Rem, unary);

    fn unary(&mut self) -> Result<L<Expr>> {
        if let Some(t) = self.advance_if(|k| {
            matches!(
                k,
                Token::Plus
                    | Token::Minus
                    | Token::Asterisk
                    | Token::Ampersand
                    | Token::Increment
                    | Token::Decrement
                    | Token::Exclamation
            )
        }) {
            let op = if t.data == Token::Ampersand && self.advance_if_kind(Token::Mut).is_some() {
                UnaryOp::AddrMut
            } else {
                t.data.try_into().unwrap()
            };

            let expr = self.unary()?;
            let span = Span::combine(t.span, expr.span);
            return Ok(L::new(
                Expr::Unary {
                    op,
                    expr: expr.into(),
                },
                span,
            ));
        }

        self.call()
    }

    fn call(&mut self) -> Result<L<Expr>> {
        let mut expr = self.primary()?;
        loop {
            if self.advance_if_kind(Token::LParen).is_some() {
                let (args, span) = if let Some(rparen) = self.advance_if_kind(Token::RParen) {
                    (Vec::new(), rparen.span)
                } else {
                    self.comma_separated(Token::RParen, "expected ')'", Self::expression)?
                };

                let span = Span::combine(expr.span, span);
                expr = L::new(
                    Expr::Call {
                        callee: expr.into(),
                        args,
                    },
                    span,
                );
            } else if self.advance_if_kind(Token::Dot).is_some() {
                let (member, span) = self.expect_id_with_span("expected member name")?;
                let span = Span::combine(expr.span, span);
                expr = L::new(
                    Expr::Member {
                        source: expr.into(),
                        member: member.into(),
                    },
                    span,
                );
            } else if self.advance_if_kind(Token::LBrace).is_some() {
                let (args, span) =
                    self.comma_separated(Token::RBrace, "expected ']'", Self::expression)?;
                let span = Span::combine(expr.span, span);
                expr = L::new(
                    Expr::Subscript {
                        callee: expr.into(),
                        args,
                    },
                    span,
                );
            } else {
                break Ok(expr);
            }
        }
    }

    fn primary(&mut self) -> Result<L<Expr>> {
        let token = self.advance()?;
        Ok(match token.data {
            Token::False => L::new(Expr::Bool(false), token.span),
            Token::True => L::new(Expr::Bool(true), token.span),
            Token::None => L::new(Expr::None, token.span),
            Token::Int(base, value) => L::new(Expr::Integer(base, value.into()), token.span),
            Token::Float(value) => L::new(Expr::Float(value.into()), token.span),
            Token::String(value) => L::new(Expr::String(value.into()), token.span),
            Token::LParen => {
                let expr = self.expression()?;
                if self.advance_if_kind(Token::Comma).is_some() {
                    let mut exprs = vec![expr];
                    let mut span = token.span;
                    while match self.advance_if_kind(Token::RParen) {
                        Some(lparen) => {
                            span.extend_to(lparen.span);
                            false
                        }
                        None => true,
                    } {
                        exprs.push(self.expression()?);
                    }

                    L::new(Expr::Tuple(exprs), span)
                } else {
                    let end = self.expect_kind(Token::RParen, "exprected ')'")?;
                    L::new(expr.data, Span::combine(token.span, end.span))
                }
            }
            Token::Ident(ident) => L::new(Expr::Symbol(ident.into()), token.span),
            Token::This => L::new(Expr::Symbol("this".into()), token.span),
            Token::Range => {
                if self.is_range_end() {
                    L::new(
                        Expr::Range {
                            start: None,
                            end: None,
                            inclusive: false,
                        },
                        token.span,
                    )
                } else {
                    let end = self.expression()?;
                    let span = Span::combine(token.span, end.span);
                    L::new(
                        Expr::Range {
                            start: None,
                            end: Some(end.into()),
                            inclusive: false,
                        },
                        span,
                    )
                }
            }
            Token::LCurly => self.block_expr(token.span)?,
            Token::If => {
                let cond = self.expression()?;
                let lcurly = self.expect_kind(Token::LCurly, "expected block")?;
                let if_branch = self.block_expr(lcurly.span)?;
                let else_branch = if self.advance_if_kind(Token::Else).is_some() {
                    if !self.matches_kind(Token::If) {
                        let lcurly = self.expect_kind(Token::LCurly, "expected block")?;
                        Some(self.block_expr(lcurly.span)?)
                    } else {
                        Some(self.expression()?)
                    }
                } else {
                    None
                };
                let span = Span::combine(
                    token.span,
                    else_branch.as_ref().map_or(if_branch.span, |e| e.span),
                );
                L::new(
                    Expr::If {
                        cond: cond.into(),
                        if_branch: if_branch.into(),
                        else_branch: else_branch.map(|e| e.into()),
                    },
                    span,
                )
            }
            Token::Loop => {
                let (cond, lcurly) = if let Some(lcurly) = self.advance_if_kind(Token::LCurly) {
                    (None, lcurly)
                } else {
                    (
                        Some(self.expression()?),
                        self.expect_kind(Token::LCurly, "expected '{'")?,
                    )
                };

                let (body, mut span) = self.parse_block(lcurly.span)?;
                let (cond, do_while) = if let Some(cond) = cond {
                    (cond, false)
                } else if self.advance_if_kind(Token::While).is_some() {
                    let cond = self.expression()?;
                    span.extend_to(cond.span);
                    (cond, true)
                } else {
                    (L::new(Expr::Bool(true), token.span), false)
                };

                L::new(
                    Expr::Loop {
                        cond: cond.into(),
                        body,
                        do_while,
                    },
                    span,
                )
            }
            Token::For => {
                let var = self.expect_id("expected type name")?;
                self.expect_kind(Token::In, "expected 'in'")?;
                // TODO: parse for foo in 0.. {} as |0..| |{}| instead of |0..{}|
                let iter = self.expression()?;
                let lcurly = self.expect_kind(Token::LCurly, "expected '{'")?;
                let (body, span) = self.parse_block(lcurly.span)?;
                L::new(
                    Expr::For {
                        var: var.into(),
                        iter: iter.into(),
                        body,
                    },
                    Span::combine(token.span, span),
                )
            }
            Token::LBrace => {
                let expr = self.expression()?;
                if self.advance_if_kind(Token::Comma).is_some() {
                    let mut exprs = vec![expr];
                    let mut span = token.span;
                    while match self.advance_if_kind(Token::RBrace) {
                        Some(lparen) => {
                            span.extend_to(lparen.span);
                            false
                        }
                        None => true,
                    } {
                        exprs.push(self.expression()?);
                    }

                    L::new(Expr::Array(exprs), span)
                } else {
                    self.expect_kind(Token::Colon, "expected ':' or ','")?;
                    let mut exprs = vec![(expr, self.expression()?)];
                    let mut span = token.span;
                    while match self.advance_if_kind(Token::RBrace) {
                        Some(lparen) => {
                            span.extend_to(lparen.span);
                            false
                        }
                        None => true,
                    } {
                        let key = self.expression()?;
                        self.expect_kind(Token::Colon, "expected ':'")?;
                        let value = self.expression()?;
                        exprs.push((key, value));
                    }

                    L::new(Expr::Map(exprs), span)
                }
            }
            _ => {
                return Err(token.map(|_| Error {
                    diagnostic: "unexpected token",
                }))
            }
        })
    }

    //

    fn block_expr(&mut self, lcurly: Span) -> Result<L<Expr>> {
        let (expr, span) = self.parse_block(lcurly)?;
        Ok(L::new(Expr::Block(expr), span))
    }

    fn is_range_end(&mut self) -> bool {
        self.matches(|k| {
            matches!(
                k,
                Token::Semicolon | Token::Comma | Token::RBrace | Token::RParen
            )
        })
    }

    fn advance(&mut self) -> Result<L<Token<'a>>> {
        match self.lexer.next() {
            Some(Ok(tok)) => Ok(tok),
            Some(Err(err)) => Err(err.map(|data| Error {
                diagnostic: data.tell(),
            })),
            None => Err(L::new(
                Error {
                    diagnostic: "unexpected eof ",
                },
                Span {
                    loc: Location {
                        row: 0,
                        col: 0,
                        pos: self.src.len(),
                    },
                    len: 0,
                },
            )),
        }
    }

    fn advance_if(&mut self, pred: impl FnOnce(&Token) -> bool) -> Option<L<Token<'a>>> {
        self.lexer
            .next_if(|tok| matches!(tok, Ok(tok) if pred(&tok.data)))
            .map(|token| token.unwrap())
    }

    fn advance_if_kind(&mut self, kind: Token) -> Option<L<Token<'a>>> {
        self.advance_if(|t| t == &kind)
    }

    fn expect<T>(
        &mut self,
        pred: impl FnOnce(L<Token<'a>>) -> Option<T>,
        msg: &'static str,
    ) -> Result<T> {
        let token = self.advance()?;
        let span = token.span;
        match pred(token) {
            Some(t) => Ok(t),
            None => Err(L::new(Error { diagnostic: msg }, span)),
        }
    }

    fn expect_kind(&mut self, kind: Token, msg: &'static str) -> Result<L<Token<'a>>> {
        self.expect(|t| (t.data == kind).then_some(t), msg)
    }

    fn expect_id(&mut self, msg: &'static str) -> Result<&'a str> {
        self.expect(
            |t| {
                let Token::Ident(ident) = t.data else { return None; };
                Some(ident)
            },
            msg,
        )
    }

    fn expect_id_with_span(&mut self, msg: &'static str) -> Result<(&'a str, Span)> {
        self.expect(
            |t| {
                let Token::Ident(ident) = t.data else { return None; };
                Some((ident, t.span))
            },
            msg,
        )
    }

    fn matches(&mut self, pred: impl FnOnce(&Token) -> bool) -> bool {
        self.lexer.peek().map_or(
            false,
            |token| matches!(token, Ok(token) if pred(&token.data)),
        )
    }

    fn matches_kind(&mut self, kind: Token) -> bool {
        self.matches(|t| t == &kind)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_type() {
        let mut parser = Parser::new("&[dyn Into<T>!(i44, [u70: str], E?); 3]?");
        let _ty = dbg!(parser.parse_type().unwrap());
    }

    #[test]
    fn parse_fn() {
        let mut parser = Parser::new(
            "
            fn hello<T, E>(a: T, mut b: E) T!E {}
        ",
        );

        _ = dbg!(parser.item());
    }

    #[test]
    fn parse_struct() {
        let mut parser = Parser::new(
            "
struct Hello<T, E> : Add + Sub {
    foo: T,
    bar: E,

    fn new(a: T, b: C) Hello {}
}
            ",
        );

        _ = dbg!(parser.item());
    }
}
