// This module implements a dictionary (key -> value mapping) using
// a kind of balanced tree called a 2-3 tree.  All nodes (except the
// root) contain exactly one or two ⟨key, value⟩ mappings, and two or 
// children three  Adding a new mapping to a twoNode produces a threeNode; 
// adding a new mapping to a threeNode splits it into a pair of twoNodes,
// and creates a new entry in the parent node.

class twoThreeTree {
    var root := emptyRoot
    var mods := 0
    var size := 0
    
    class twoNode(l, k, v, r) is confidential {
        method left { l }
        method right { r }
        method key { k }
        method value { v }
    }
    
    class threeNode(l, lk, lv, m, rk, rv, r) is confidential {
        method left { l }
        method leftKey { lk }
        method leftValue { lv }
        method middle { m }
        method rightKey { rk }
        method rightValue { rv }
        method right { r }
    }
        
    class twoLeafNode(k, v) is confidential {
        method key { k }
        method value { v }
    }
    
    class threeLeafNode(lk, lv, rk, rv) is confidential {
        method leftKey { lk }
        method leftValue { lv }
        method rightKey { rk }
        method rightValue { rv }
    }
    
    class emptyRoot {
        method at (k) ifAbsent (action) {
            action.apply
        }
        method at (k) put (v) {
            root := twoLeafNode(k, v)
            size := size + 1
        }
        method removeKey (k) ifAbsent (action) {
            action.apply
        }
        method removeValue (v) ifAbsent (action) {
            action.apply
        }
    }
}
