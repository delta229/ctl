use derive_more::{Constructor, Deref, DerefMut};
use enum_as_inner::EnumAsInner;
use indexmap::IndexSet;
use std::collections::HashMap;

use crate::{
    ast::{
        checked::{CheckedExpr, CheckedPattern, CheckedStmt},
        parsed::{Expr, Linkage, Pattern, UsePath},
        Attribute,
    },
    lexer::Located,
    typeid::Type,
};

macro_rules! id {
    ($name: ident => $output: ident,
     $vec: ident,
     $($parts:ident).+,
     $suffix: ident) => {
        #[derive(Debug, PartialEq, Eq, Clone, Copy, Hash)]
        pub struct $name(usize);

        impl ItemId for $name {
            type Value = $output;

            fn get(self, scopes: &Scopes) -> &Scoped<Self::Value> {
                &scopes.$vec[self.0]
            }

            fn get_mut(self, scopes: &mut Scopes) -> &mut Scoped<Self::Value> {
                &mut scopes.$vec[self.0]
            }

            fn find(scopes: &Scopes, current: ScopeId, name: &str) -> Option<Vis<Self>> {
                for (id, scope) in scopes.walk(current) {
                    if let Some(item) = Self::find_in(scopes, name, id) {
                        return Some(item);
                    }

                    if matches!(scope.kind, ScopeKind::Module(_, _)) {
                        break;
                    }
                }

                None
            }

            fn find_in(scopes: &Scopes, name: &str, scope: ScopeId) -> Option<Vis<Self>> {
                scopes[scope].$vec
                    .iter()
                    .rev()
                    .find_map(|id| (scopes.$vec[id.0].$($parts).+ == name).then_some(*id))
            }

            fn insert_in(scopes: &mut Scopes, value: Self::Value, public: bool, scope: ScopeId) -> Self {
                let index = scopes.$vec.len();
                scopes.$vec.push(Scoped::new(value, scope));
                let id = $name(index);
                scopes[scope].$vec.insert(Vis { id, public });
                id
            }
        }

        impl std::fmt::Display for $name {
            fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
                write!(f, "{}", self.0)
            }
        }
    };
}

#[derive(Default, Debug, PartialEq, Eq, Clone, Copy, Hash)]
pub struct ScopeId(pub usize);

impl ScopeId {
    pub const ROOT: ScopeId = ScopeId(0);
}

id!(FunctionId => Function, fns, name.data, func);
id!(UserTypeId => UserType, types, name.data, user_type);
id!(VariableId => Variable, vars, name, var);
id!(ExtensionId => Extension, exts, name, ext);

#[derive(Default, Debug, Clone, EnumAsInner)]
pub enum ScopeKind {
    Block(Option<Type>, bool),
    Loop {
        target: Option<Type>,
        breaks: Option<bool>,
        infinite: bool,
    },
    Lambda(Option<Type>, bool),
    Function(FunctionId),
    UserType(UserTypeId),
    Module(String, Vec<UsePath>),
    Impl(UserTypeId),
    Extension(ExtensionId),
    #[default]
    None,
}

impl ScopeKind {
    pub fn name<'a, 'b>(&'a self, scopes: &'b Scopes) -> Option<&'b str>
    where
        'a: 'b,
    {
        match self {
            &ScopeKind::Function(id) => Some(&scopes.get(id).name.data),
            &ScopeKind::UserType(id) => Some(&scopes.get(id).name.data),
            &ScopeKind::Extension(id) => Some(&scopes.get(id).name),
            ScopeKind::Module(name, _) => Some(name),
            _ => None,
        }
    }
}

#[derive(Debug, Clone)]
pub enum DefaultExpr {
    Unchecked(ScopeId, Expr),
    Checked(CheckedExpr),
}

#[derive(Debug, Clone, EnumAsInner)]
pub enum ParamPattern {
    Unchecked(Located<Pattern>),
    Checked(CheckedPattern),
}

#[derive(Debug, Clone)]
pub struct CheckedParam {
    pub keyword: bool,
    pub label: String,
    pub patt: ParamPattern,
    pub ty: Type,
    pub default: Option<DefaultExpr>,
}

#[derive(Default, Debug, Clone)]
pub struct Variable {
    pub name: String,
    pub ty: Type,
    pub is_static: bool,
    pub mutable: bool,
    pub value: Option<CheckedExpr>,
}

#[derive(Default, Debug)]
pub struct Function {
    pub attrs: Vec<Attribute>,
    pub name: Located<String>,
    pub linkage: Linkage,
    pub is_async: bool,
    pub is_unsafe: bool,
    pub variadic: bool,
    pub type_params: Vec<UserTypeId>,
    pub params: Vec<CheckedParam>,
    pub ret: Type,
    pub body: Option<Vec<CheckedStmt>>,
    pub constructor: Option<UserTypeId>,
    pub body_scope: ScopeId,
    pub returns: bool,
}

impl FunctionId {
    pub const RESERVED: FunctionId = FunctionId(0);
}

#[derive(Debug, Clone)]
pub struct CheckedMember {
    pub public: bool,
    pub name: String,
    pub shared: bool,
    pub ty: Type,
}

#[derive(Debug, Clone)]
pub struct Union {
    pub variants: Vec<CheckedMember>,
    pub is_unsafe: bool,
}

impl Union {
    pub fn tag_type(&self) -> Type {
        Type::discriminant_for(self.variants.len())
    }

    pub fn variant_tag(&self, name: &str) -> Option<usize> {
        self.variants
            .iter()
            .filter(|m| !m.shared)
            .position(|m| m.name == name)
    }
}

#[derive(Debug, EnumAsInner)]
pub enum UserTypeData {
    Struct {
        members: Vec<CheckedMember>,
        init: FunctionId,
    },
    Union(Union),
    Template,
    Trait,
}

#[derive(Debug)]
pub struct UserType {
    pub name: Located<String>,
    pub body_scope: ScopeId,
    pub data: UserTypeData,
    pub impls: Vec<Type>,
    pub type_params: Vec<UserTypeId>,
    pub attrs: Vec<Attribute>,
}

impl UserType {
    pub fn members(&self) -> &[CheckedMember] {
        match &self.data {
            UserTypeData::Struct { members, .. } => members,
            UserTypeData::Union(union) => &union.variants,
            _ => &[],
        }
    }

    pub fn members_mut(&mut self) -> &mut [CheckedMember] {
        match &mut self.data {
            UserTypeData::Struct { members, .. } => members,
            UserTypeData::Union(union) => &mut union.variants,
            _ => &mut [],
        }
    }
}

pub trait HasTypeParams {
    fn get_type_params(&self) -> &[UserTypeId];
}

impl HasTypeParams for UserType {
    fn get_type_params(&self) -> &[UserTypeId] {
        &self.type_params
    }
}

impl HasTypeParams for Extension {
    fn get_type_params(&self) -> &[UserTypeId] {
        &self.type_params
    }
}

impl HasTypeParams for Function {
    fn get_type_params(&self) -> &[UserTypeId] {
        &self.type_params
    }
}

pub trait HasImplsAndTypeParams: HasTypeParams {
    fn get_impls(&self) -> &Vec<Type>;
    fn get_impls_mut(&mut self) -> &mut Vec<Type>;
}

impl HasImplsAndTypeParams for UserType {
    fn get_impls(&self) -> &Vec<Type> {
        &self.impls
    }

    fn get_impls_mut(&mut self) -> &mut Vec<Type> {
        &mut self.impls
    }
}

impl HasImplsAndTypeParams for Extension {
    fn get_impls(&self) -> &Vec<Type> {
        &self.impls
    }

    fn get_impls_mut(&mut self) -> &mut Vec<Type> {
        &mut self.impls
    }
}

#[derive(Debug)]
pub struct Extension {
    pub ty: Type,
    pub name: String,
    pub impls: Vec<Type>,
    pub type_params: Vec<UserTypeId>,
    pub body_scope: ScopeId,
}

impl Extension {
    pub fn matches_type(&self, ty: &Type) -> bool {
        // TODO: templates
        &self.ty == ty
    }
}

#[derive(Deref, DerefMut, Constructor)]
pub struct Scoped<T> {
    #[deref]
    #[deref_mut]
    pub item: T,
    pub scope: ScopeId,
}

#[derive(Debug, Deref, DerefMut, Constructor, Copy, Clone)]
pub struct Vis<T> {
    #[deref]
    #[deref_mut]
    pub id: T,
    pub public: bool,
}

impl<T: std::hash::Hash> std::hash::Hash for Vis<T> {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.id.hash(state);
    }
}

impl<T: PartialEq> PartialEq for Vis<T> {
    fn eq(&self, other: &Self) -> bool {
        self.id.eq(other)
    }
}

impl<T: Eq> Eq for Vis<T> {}

pub trait ItemId: Sized {
    type Value;

    fn get(self, scopes: &Scopes) -> &Scoped<Self::Value>;
    fn get_mut(self, scopes: &mut Scopes) -> &mut Scoped<Self::Value>;

    fn find(scopes: &Scopes, current: ScopeId, name: &str) -> Option<Vis<Self>>;
    fn find_in(scopes: &Scopes, name: &str, scope: ScopeId) -> Option<Vis<Self>>;

    fn insert_in(scopes: &mut Scopes, value: Self::Value, public: bool, scope: ScopeId) -> Self;
}

#[derive(Default, Debug)]
pub struct Scope {
    pub kind: ScopeKind,
    pub parent: Option<ScopeId>,
    pub fns: IndexSet<Vis<FunctionId>>,
    pub types: IndexSet<Vis<UserTypeId>>,
    pub vars: IndexSet<Vis<VariableId>>,
    pub exts: IndexSet<Vis<ExtensionId>>,
    pub children: IndexSet<Vis<ScopeId>>,
    pub use_stmts: Vec<UsePath>,
}

pub struct Scopes {
    scopes: Vec<Scope>,
    fns: Vec<Scoped<Function>>,
    types: Vec<Scoped<UserType>>,
    vars: Vec<Scoped<Variable>>,
    exts: Vec<Scoped<Extension>>,
    pub lang_types: HashMap<String, UserTypeId>,
    pub intrinsics: HashMap<FunctionId, String>,
    pub panic_handler: Option<FunctionId>,
}

impl Scopes {
    pub fn new() -> Self {
        Self {
            scopes: vec![Scope::default()],
            fns: vec![Scoped::new(Function::default(), ScopeId::ROOT)],
            types: Vec::new(),
            vars: Vec::new(),
            exts: Vec::new(),
            lang_types: HashMap::new(),
            intrinsics: HashMap::new(),
            panic_handler: None,
        }
    }

    pub fn create_scope(&mut self, parent: ScopeId, kind: ScopeKind) -> ScopeId {
        let id = ScopeId(self.scopes.len());
        self.scopes.push(Scope {
            parent: Some(parent),
            kind,
            ..Default::default()
        });
        id
    }

    pub fn walk(&self, id: ScopeId) -> impl Iterator<Item = (ScopeId, &Scope)> {
        pub struct ScopeIter<'a> {
            scopes: &'a Scopes,
            next: Option<ScopeId>,
        }

        impl<'a> Iterator for ScopeIter<'a> {
            type Item = (ScopeId, &'a Scope);

            fn next(&mut self) -> Option<Self::Item> {
                self.next.map(|i| {
                    self.next = self.scopes[i].parent;
                    (i, &self.scopes[i])
                })
            }
        }

        ScopeIter {
            scopes: self,
            next: Some(id),
        }
    }

    pub fn full_name(&self, id: ScopeId, ident: &str) -> String {
        let mut name: String = ident.chars().rev().collect();
        for scope_name in self.walk(id).flat_map(|(_, scope)| scope.kind.name(self)) {
            name.reserve(scope_name.len() + 1);
            name.push('_');
            for c in scope_name.chars().rev() {
                name.push(c);
            }
        }

        name.chars().rev().collect::<String>()
    }

    pub fn function_of(&self, scope: ScopeId) -> Option<FunctionId> {
        self.walk(scope)
            .find_map(|(_, scope)| scope.kind.as_function().copied())
    }

    pub fn module_of(&self, id: ScopeId) -> Option<ScopeId> {
        self.walk(id)
            .find(|(_, current)| current.kind.is_module())
            .map(|(id, _)| id)
    }

    pub fn vars(&self) -> impl Iterator<Item = (VariableId, &Scoped<Variable>)> {
        self.vars
            .iter()
            .enumerate()
            .map(|(i, var)| (VariableId(i), var))
    }

    pub fn extensions(&self) -> &[Scoped<Extension>] {
        &self.exts
    }

    pub fn functions(&self) -> impl Iterator<Item = (FunctionId, &Scoped<Function>)> {
        self.fns
            .iter()
            .enumerate()
            .map(|(i, var)| (FunctionId(i), var))
    }

    pub fn find_module_in(&self, name: &str, scope: ScopeId) -> Option<Vis<ScopeId>> {
        self[scope]
            .children
            .iter()
            .find(|&&id| matches!(&self[*id].kind, ScopeKind::Module(mn, _) if name == mn))
            .copied()
    }

    pub fn get_option_id(&self) -> Option<UserTypeId> {
        self.lang_types.get("option").copied()
    }

    pub fn intrinsic_name(&self, id: FunctionId) -> Option<&str> {
        self.intrinsics.get(&id).map(|s| s.as_str())
    }

    pub fn get<T: ItemId>(&self, id: T) -> &Scoped<T::Value> {
        id.get(self)
    }

    pub fn get_mut<T: ItemId>(&mut self, id: T) -> &mut Scoped<T::Value> {
        id.get_mut(self)
    }

    pub fn find_in<T: ItemId>(&self, name: &str, scope: ScopeId) -> Option<Vis<T>> {
        T::find_in(self, name, scope)
    }
}

impl std::ops::Index<ScopeId> for Scopes {
    type Output = Scope;

    fn index(&self, index: ScopeId) -> &Self::Output {
        &self.scopes[index.0]
    }
}

impl std::ops::IndexMut<ScopeId> for Scopes {
    fn index_mut(&mut self, index: ScopeId) -> &mut Self::Output {
        &mut self.scopes[index.0]
    }
}

impl Default for Scopes {
    fn default() -> Self {
        Self::new()
    }
}
