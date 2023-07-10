use crate::typecheck::{ScopeId, VariableId};

use self::stmt::CheckedStmt;

#[derive(Debug, Clone)]
pub struct Block {
    pub body: Vec<CheckedStmt>,
    pub scope: ScopeId,
}

#[derive(Debug, Clone)]
pub struct UnionPattern {
    pub binding: Option<VariableId>,
    pub variant: (String, usize),
}

pub mod expr {
    use std::collections::HashMap;

    use crate::{
        ast::expr::{BinaryOp, UnaryOp},
        typecheck::{GenericFunc, GenericUserType, Symbol, TypeId},
    };

    use super::{Block, UnionPattern};

    #[derive(Default, Debug, Clone)]
    pub enum ExprData {
        Binary {
            op: BinaryOp,
            left: Box<CheckedExpr>,
            right: Box<CheckedExpr>,
        },
        Unary {
            op: UnaryOp,
            expr: Box<CheckedExpr>,
        },
        Call {
            func: GenericFunc,
            args: Vec<CheckedExpr>,
            inst: Option<GenericUserType>,
        },
        Instance(HashMap<String, CheckedExpr>),
        Array(Vec<CheckedExpr>),
        ArrayWithInit {
            init: Box<CheckedExpr>,
            count: usize,
        },
        Tuple(Vec<CheckedExpr>),
        Map(Vec<(CheckedExpr, CheckedExpr)>),
        Bool(bool),
        Signed(i128),
        Unsigned(u128),
        Float(String),
        String(String),
        Char(char),
        Void,
        Symbol(Symbol),
        None,
        Assign {
            target: Box<CheckedExpr>,
            binary: Option<BinaryOp>,
            value: Box<CheckedExpr>,
        },
        Block(Block),
        If {
            cond: Box<CheckedExpr>,
            if_branch: Box<CheckedExpr>,
            else_branch: Option<Box<CheckedExpr>>,
        },
        Loop {
            cond: Box<CheckedExpr>,
            body: Block,
            do_while: bool,
        },
        For {
            var: String,
            iter: Box<CheckedExpr>,
            body: Block,
        },
        Match {
            expr: Box<CheckedExpr>,
            body: Vec<(UnionPattern, CheckedExpr)>,
        },
        Member {
            source: Box<CheckedExpr>,
            member: String,
        },
        Subscript {
            callee: Box<CheckedExpr>,
            args: Vec<CheckedExpr>,
        },
        Return(Box<CheckedExpr>),
        Yield(Box<CheckedExpr>),
        Break(Box<CheckedExpr>),
        Continue,
        #[default]
        Error,
    }

    #[derive(Debug, Default, Clone, derive_more::Constructor)]
    pub struct CheckedExpr {
        pub ty: TypeId,
        pub data: ExprData,
    }
}

pub mod stmt {
    use super::{expr::CheckedExpr, Block};
    use crate::typecheck::VariableId;

    #[derive(Debug, Default, Clone)]
    pub enum CheckedStmt {
        Expr(CheckedExpr),
        Let(VariableId),
        Module {
            name: String,
            body: Block,
        },
        None,
        #[default]
        Error,
    }
}
