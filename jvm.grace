import "io" as io
import "util" as util
import "jvmops" as ops

def moduleBaseClass = "net/gracelang/minigrace/runtime/GraceModule"
def objectBaseClass = "net/gracelang/minigrace/runtime/GraceObject"

class constantPoolTagged(typ) {
    def tag is readable = typ
    var fileIndex := object {
        def valid is readable = false
    }

    method hasIndex { fileIndex.valid }
    method setIndex(n) {
        if(hasIndex.not) then {
            fileIndex := object {
                def valid is readable = true
                def value is readable = n
            }
        }
    }
    method index { fileIndex.value }
    method writeTag(file) { file.writeU8(tag) }

    method addToFile(f) {
        f.addConstant(self)
    }
}

class constUnicode(str) {
    inherit constantPoolTagged(1)

    def value is readable = str

    method writeTo(file) {
        util.log_verbose "writing unicode object '{value}' l={value.length}"
        writeTag(file)
        file.writeU16(value.length)
        file.write(value)
    }
}

class constClassInfo(nameObject) {
    inherit constantPoolTagged(7)

    def value is readable = nameObject

    method writeTo(file) {
        writeTag(file)
        file.writeU16(nameObject.index)
    }
}

class methodNamed(n) descriptor(desc) index(idx) inside(c) {
    def name = n
    def index = idx
    def cls is confidential = c

    def nameConst = constUnicode(n).addToFile(c)
    def descConst = constUnicode(desc).addToFile(c)

    var flags := 2

    var code := list []

    method add(insn) { code.add(insn) }

    class label {
        def index is readable = code.size
    }

    method static {
        flags := flags + 8
        self
    }

    method writeTo(file) {
        file.writeU16(flags)
        file.writeU16(nameConst.index)
        file.writeU16(descConst.index)
        file.writeU16(0)
    }
}

method methodNamed(n) args(narg) index(idx) inside(cls) {
    var args := ""
    [1..narg].do { args := args ++ "L{objectBaseClass};" }
    methodNamed(n) descriptor("({args})L{objectBaseClass};") index(idx)
        inside(cls)
}

class classNamed(n) {
    def name is readable = n

    var constants   := list []
    var interfaces  := list []
    var fields      := list []
    var methods     := list []
    var attrs       := list []

    def modString = constUnicode(moduleBaseClass).addToFile(self)
    def objString = constUnicode(objectBaseClass).addToFile(self)
    def modClass = constClassInfo(modString).addToFile(self)
    def objClass = constClassInfo(objString).addToFile(self)

    def mainClassName = constUnicode(
        "net/gracelang/minigrace/modules/Grace_{n}").addToFile(self)
    def mainClass = constClassInfo(mainClassName).addToFile(self)

    method methodNamed(nm) withArgs(nargs) {
        def index = methods.size + 1
        def m = methodNamed(n) args(nargs) index(index) inside(self)
        methods.add(m)
        m
    }

    method mainMethod {
        def m = methodNamed("main") descriptor("([Ljava/lang/String)V")
            index(methods.size + 1) inside(self).static
        methods.add(m)
        m
    }

    method addConstant(const) {
        const.setIndex(constants.size + 1)
        constants.add(const)
        const
    }

    method writeTo(file) {
        writeHeaderTo(file)
        writeObjects(constants) toFile(file)
        writeFlagsTo(file)

        writeObjects(interfaces) toFile(file)
        writeObjects(fields) toFile(file)
        writeObjects(methods) toFile(file)
        writeObjects(attrs) toFile(file)
    }

    method writeObjects(objs) toFile(file) {
        file.writeU16(objs.size)
        objs.do { o -> o.writeTo(file) }
    }

    method writeFlagsTo(file) {
        file.writeU16(1)
        file.writeU16(mainClass.index)
        file.writeU16(modClass.index)
    }

    method writeHeaderTo(file) {
        file.writeU16(0xcafe)
        file.writeU16(0xbabe)
        file.writeU16(0)
        file.writeU16(52)
    }
}
