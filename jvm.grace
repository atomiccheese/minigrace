import "io" as io
import "jvmops" as ops

class methodNamed(n) withIndex(idx) inClass(c) {
    def name = n
    def index = idx
    def cls is confidential = c
}

class classNamed(n) inheriting(par) inPackage(p) {
    def name is readable = n
    def parent = par
    def package = p

    var constants   := list []
    var interfaces  := list []
    var fields      := list []
    var methods     := list []
    var attrs       := list []

    method methodNamed(nm) {
        def m = methodNamed(n) withIndex(methods.size) inClass(self)
        methods.add(m)
        m
    }

    method constantString(s) {
    }

    method writeTo(file) {
        file.writeU32(0xcafebabe)

    }
}
