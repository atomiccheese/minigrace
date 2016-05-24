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

    def nameConst = c.stringConst(n)
    def descConst = c.stringConst(desc)
    def codeConst = c.stringConst("Code")

    var flags := 1

    def code is readable = object {
        var insns := list []

        method dataLength {
            var codesize := 0
            insns.do { i -> codesize := codesize + i.size }

            var exceptionTableSize := 0
            var attrsSize := 0

            12 + codesize + exceptionTableSize + attrsSize
        }

        method writeTo(file) {
            file.writeU16(512)
            file.writeU16(512)

            var codesize := 0
            insns.do { i -> codesize := codesize + i.size }
            file.writeU32(codesize)

            insns.do { i -> i.writeTo(file) }

            file.writeU16(0)
            file.writeU16(0)
        }

        method add(insn) { insns.add(insn) }

        class label {
            def index is readable = insns.size
        }
    }

    var attrs := list []

    method withCode(block) {
        block.apply(code)
    }

    method setPrivate {
        flags := flags + 1
        self
    }

    method setStatic {
        flags := flags + 8
        self
    }

    method writeTo(file) {
        file.writeU16(flags)
        file.writeU16(nameConst.index)
        file.writeU16(descConst.index)
        file.writeU16(attrs.size + 1)

        writeCodeAttributeTo(file)
    }

    method writeCodeAttributeTo(file) {
        file.writeU16(codeConst.index)
        file.writeU32(code.dataLength)
        code.writeTo(file)
    }
}

method methodNamed(n) args(narg) index(idx) inside(cls) {
    var args := ""
    (1..narg).do { x -> args := args ++ "L{objectBaseClass};" }
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

    var cachedStrings := dictionary []

    def modString = stringConst(moduleBaseClass)
    def objString = stringConst(objectBaseClass)
    def modClass = constClassInfo(modString).addToFile(self)
    def objClass = constClassInfo(objString).addToFile(self)

    def mainClassName = stringConst("net/gracelang/minigrace/modules/Grace_{n}")
    def mainClass = constClassInfo(mainClassName).addToFile(self)

    method methodNamed(nm) withArgs(nargs) {
        def m = methodNamed(nm) args(nargs) index(methods.size + 1) inside(self)
        methods.add(m)
        m
    }

    method mainMethod {
        def m = methodNamed("main") descriptor("([Ljava/lang/String;)V")
            index(methods.size + 1) inside(self).setStatic
        methods.add(m)
        m
    }

    method addConstant(const) {
        const.setIndex(constants.size + 1)
        constants.add(const)
        const
    }

    method stringConst(str) {
        cachedStrings.at(str) ifAbsent {
            def s = constUnicode(str).addToFile(self)
            cachedStrings.at(str) put(s)
            s
        }
    }

    method writeTo(file) {
        writeHeaderTo(file)
        writeConstantPoolToFile(file)
        writeFlagsTo(file)

        writeObjects(interfaces) toFile(file)
        writeObjects(fields) toFile(file)
        writeObjects(methods) toFile(file)
        writeObjects(attrs) toFile(file)
    }

    method writeConstantPoolToFile(file) {
        file.writeU16(constants.size + 1)
        constants.do { o -> o.writeTo(file) }
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
