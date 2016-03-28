#pragma NativePrelude
#pragma ExtendedLineups

var isStandardPrelude := true

class successfulMatch(result', bindings') {
    inherits true
    method result { result' }
    method bindings { bindings' }
    method asString {
        "successfulMatch(result = {result}, bindings = {bindings})"
    }
}

class SuccessfulMatch.new(result', bindings') {
    inherits successfulMatch(result', bindings')
}

class failedMatch(result') {
    inherits false
    method result { result' }
    method bindings { emptySequence }
    method asString {
        "failedMatch(result = {result})"
    }
}

class FailedMatch.new(result') {
    inherits failedMatch(result')
}

method abstract {
    SubobjectResponsibility.raise "abstract method not overriden by subobject."
}

method required {
    SubobjectResponsibility.raise "required method not provided."
}

method do(action)while(condition) {
    while {
        action.apply
        condition.apply
    } do { }
}

method repeat(n)times(action) {
    var ix := n
    while {ix > 0} do {
        ix := ix - 1
        action.apply
    }
}

method for (cs) and (ds) do (action) -> Done {
    def dIter = ds.iterator
    cs.do { c -> 
        if (dIter.hasNext) then {
            action.apply(c, dIter.next)
        } else {
            return
        }
    }
}

method min(a, b) {
    if (a < b) then { a } else { b }
}

method max(a, b) {
    if (a > b) then { a } else { b }
}

class basicPattern {
    method &(o) {
        andPattern(self, o)
    }
    method |(o) {
        orPattern(self, o)
    }
}

class BasicPattern.new {
    inherits basicPattern
}

class matchAndDestructuringPattern(pat, items') {
    inherits basicPattern
    def pattern = pat
    def items = items'
    method match(o) {
        def m = pat.match(o)
        if (m) then{
            var mbindings := m.bindings
            def bindings = []
            if (mbindings.size < items.size) then {
                if (Extractable.match(o)) then {
                    mbindings := o.extract
                } else {
                    return failedMatch(o)
                }
            }
            print "match&Destructure start"
            for (items) and (mbindings) do { each, bind ->
                def b = each.match(bind)
                if (!b) then {
                    print "match&Destructure fail"
                    return failedMatch(o)
                }
                bindings.addAll(b.bindings)
            }
            print "match&Destructure success"
            successfulMatch(o, bindings)
        } else {
            failedMatch(o)
        }
    }
}

class MatchAndDestructuringPattern.new(pat, items') {
    inherits matchAndDestructuringPattern(pat, items')
}

class variablePattern(nm) {
    inherits basicPattern
    method match(o) {
        successfulMatch(o, [o])
    }
}

class VariablePattern.new(nm) {
    inherits variablePattern(nm)
}

class bindingPattern(pat) {
    inherits basicPattern
    method match(o) {
        def bindings = [o]
        def m = pat.match(o)
        if (!m) then {
            return m
        }
        for (m.bindings) do {b->
            bindings.push(b)
        }
        successfulMatch(o, bindings)
    }
}

class BindingPattern.new(pat) {
    inherits bindingPattern(pat)
}

class wildcardPattern {
    inherits basicPattern
    method match(o) {
        successfulMatch(o, [])
    }
}

class WildcardPattern.new {
    inherits wildcardPattern
}

class andPattern(p1, p2) {
    inherits basicPattern
    method match(o) {
        def m1 = p1.match(o)
        if (!m1) then {
            return m1
        }
        def m2 = p2.match(o)
        if (!m2) then {
            return m2
        }
        def bindings = []

        for (m1.bindings) do {b->
            bindings.push(b)
        }
        for (m2.bindings) do {b->
            bindings.push(b)
        }
        successfulMatch(o, bindings)
    }
}

class AndPattern.new(p1, p2) {
    inherits andPattern(p1, p2)
}

class orPattern(p1, p2) {
    inherits basicPattern
    method match(o) {
        if (p1.match(o)) then {
            return successfulMatch(o, [])
        }
        if (p2.match(o)) then {
            return successfulMatch(o, [])
        }
        failedMatch(o)
    }
}

class OrPattern.new(p1, p2) {
    inherits orPattern(p1, p2)
}

def Singleton is public = object {
    factory method new {
        inherits basicPattern
        method match(other) {
            if (self == other) then {
                successfulMatch(other, [])
            } else {
                failedMatch(other)
            }
        }
    }
    factory method named(printString) {
        inherits Singleton.new
        method asString { printString }
    }
}

class baseType(n) {
    var name is public := n

    method &(o) {
        typeIntersection(self, o)
    }
    method |(o) {
        typeVariant(self, o)
    }
    method +(o) {
        typeUnion(self, o)
    }
    method -(o) {
        typeSubtraction(self, o)
    }
    method asString {
        if (name == "") then { "type ‹anon›" }
                        else { "type {name}" }
    }
}

class BaseType.new(n) {
    inherits baseType(n)
}

class typeIntersection(t1, t2) {
    inherits andPattern(t1, t2)
    // uses baseType
    
    var name is public := "({t1} & {t2})"

    method &(o) {
        typeIntersection(self, o)
    }
    method |(o) {
        typeVariant(self, o)
    }
    method +(o) {
        typeUnion(self, o)
    }
    method -(o) {
        typeSubtraction(self, o)
    }
    method methodNames {
        t1.methodNames.addAll(t2.methodNames)
    }
    method asString { name }
}

class TypeIntersection.new(t1, t2) {
    inherits typeIntersection(t1, t2)
}

class typeVariant(t1, t2) {
    inherits orPattern(t1, t2)
    // uses baseType
    
    var name is public := "({t1} | {t2})"

    method &(o) {
        typeIntersection(self, o)
    }
    method |(o) {
        typeVariant(self, o)
    }
    method +(o) {
        typeUnion(self, o)
    }
    method -(o) {
        typeSubtraction(self, o)
    }
    method methodNames {
        self.TypeVariantsCannotBeCharacterizedByASetOfMethods
    }
    method asString { name }
}

class TypeVariant.new(t1, t2) {
    inherits typeVariant(t1, t2)
}

class typeUnion(t1, t2) {
    inherits basicPattern
//    uses baseType

    var name is public := "({t1} + {t2})"

    method &(o) {
        typeIntersection(self, o)
    }
    method |(o) {
        typeVariant(self, o)
    }
    method +(o) {
        typeUnion(self, o)
    }
    method -(o) {
        typeSubtraction(self, o)
    }
    method methodNames {
        t1.methodNames ** t2.methodNames
    }
    method match(o) {
        ResourceException.raise "matching against a typeUnion not yet implemented"
        // Why not?  Becuase it requires reflection, which
        // requires the mirror module, which requires this module.
        def mirror = ...
        def oMethodNames = mirror.reflect(o).methodNames
        for (self.methodNames) do { each ->
            if (! oMethodNames.contains(each)) then {
                return failedMatch(o)
            }
        }
        return successfulMatch(o, [])
    }
    method asString { name }
}

class TypeUnion.new(t1, t2) {
    inherits typeUnion(t1, t2)
}

class typeSubtraction(t1, t2) {
    inherits basicPattern

    var name is public := "({t1} - {t2})"

    method &(o) {
        typeIntersection(self, o)
    }
    method |(o) {
        typeVariant(self, o)
    }
    method +(o) {
        typeUnion(self, o)
    }
    method -(o) {
        typeSubtraction(self, o)
    }
    method methodNames {
        t1.methodNames.removeAll(t2.methodNames)
    }
    method asString { name }
}

class TypeSubtraction.new(t1, t2) {
    inherits typeSubtraction(t1, t2)
}

// Now define the types.  Because some of the types are defined
// using &, typeIntersection must be defined first.

type Extractable = {
    extract
}

type MatchResult = Boolean & type {
    result -> Unknown
    bindings -> List<Unknown>
}

type Pattern = {
    & (other:Pattern) -> Pattern
    | (other:Pattern) -> Pattern
    match(value:Object) -> MatchResult
}

type ExceptionKind = Pattern & type {
    refine -> ExceptionKind
    parent -> ExceptionKind
    raise(message:String) -> Done
    raise(message:String) with (argument:Object) -> Done
}

type Point =  {

    x -> Number
    // the x-coordinates of self

    y -> Number
    // the y-coordinate of self

    + (other:Point) -> Point
    // the Point that is the vector sum of self and other, i.e. (self.x+other.x) @ (self.y+other.y)

    - (other:Point) -> Point
    // the Point that is the vector difference of self and other, i.e. (self.x-other.x) @ (self.y-other.y)
    
    * (factor:Number) -> Point
    // this point scaled by factor, i.e. (self.x*factor) @ (self.y*factor)
    
    / (factor:Number) -> Point
    // this point scaled by 1/factor, i.e. (self.x/factor) @ (self.y/factor)

    length -> Number
    // distance from self to the origin

    distanceTo(other:Point) -> Number
    // distance from self to other
}

class point2Dx (x') y (y') {
    def x is readable = x'
    def y is readable = y'
    method asString { "({x}@{y})" }
    method asDebugString { self.asString }
    method distanceTo(other:Point) { (((x - other.x)^2) + ((y - other.y)^2))^(0.5) }
    method -(other:Point) { point2Dx (x - other.x) y (y - other.y) }
    method +(other:Point) { point2Dx (x + other.x) y (y + other.y) }
    method /(other:Number) { point2Dx (x / other) y (y / other) }
    method *(other:Number) { point2Dx (x * other) y (y * other) }
    method length {((x^2) + (y^2))^0.5}
    method ==(other) {
        match (other)
            case {o:Point -> (x == o.x) && (y == o.y)}
            case {_ -> false}
    }
    method prefix- { point2Dx (-x) y (-y) }
}

import "collectionsPrelude" as coll
// collectionsPrelude defines types using &, so it can't be imported until
// the above definition of TypeIntersection has been executed.

// We should just be able to put "is public" on the above import, but this is
// not fully implemented.  So instead we create an alias:
def collections is public = coll

type Block0<R> = collections.Block0<R>
type Block1<T,R> = collections.Block1<T,R>
type Fun<T,R> = collections.Block1<T,R>
type Block2<S,T,R> = collections.Block2<S,T,R>

type Collection<T> = collections.Collection<T>
type Iterable<T> = collections.Iterable<T>
type Expandable<T> = collections.Expandable<T>
type Enumerable<T> = collections.Enumerable<T>
type Binding<K,T> = collections.Binding<K,T>
type Iterator<T> = collections.Iterator<T>
type Sequence<T> = collections.Sequence<T>
type List<T> = collections.List<T>
type Set<T> = collections.Set<T>
type Dictionary<K,T> = collections.Dictionary<K,T>
type Lineup<T> = collections.Lineup<T>

def BoundsError is public = collections.BoundsError
def IteratorExhausted is public = collections.IteratorExhausted
def NoSuchObject is public = collections.NoSuchObject
def RequestError is public = collections.RequestError
def SubobjectResponsibility is public = collections.SubobjectResponsibility
def ConcurrentModification is public = collections.ConcurrentModification

def collection is public = collections.collection
def enumerable is public = collections.enumerable
def indexable is public = collections.indexable

method sequence<T>(arg) {
    collections.sequence<T>.withAll(arg)
}

def emptySequence is public = collections.sequence.empty

method list<T>(arg) {
    collections.list<T>.withAll(arg)
}
method emptyList { collections.list.empty }

method set<T>(arg) {
    collections.set<T>.withAll(arg)
}
method emptySet { collections.set.empty }

method dictionary<K, T>(arg) {
    collections.dictionary<K, T>.withAll(arg)
}
method emptyDictionary { collections.dictionary.empty }

def binding is public = collections.binding
def range is public = collections.range

method methods {
    prelude.clone(self)
}


