import "io" as io
import "util" as util
import "jvmops" as ops

// See https://docs.oracle.com/javase/specs/jvms/se7/html for more information
// on the JVM's class file format.

def moduleBaseClass is readable = "net/gracelang/minigrace/runtime/GraceModule"
def objectBaseClass is readable = "net/gracelang/minigrace/runtime/GraceObject"

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

    method writeBody(file) { }

    method writeTo(file) {
        file.writeU8(tag)
        writeBody(file)
    }

    method addToFile(f) {
        f.addConstant(self)
    }
}

class constUnicode(str) {
    inherit constantPoolTagged(1)

    def value is readable = str

    method writeBody(file) {
        file.writeU16(value.length)
        file.write(value)
    }
}

class constClassInfo(nameObject) {
    inherit constantPoolTagged(7)

    def value is readable = nameObject

    method writeBody(file) {
        file.writeU16(nameObject.index)
    }
}

class constMethodRef(nameAndType, cls) {
    inherit constantPoolTagged(10)

    def signature is readable = nameAndType
    def className is readable = cls

    method writeBody(file) {
        file.writeU16(className.index)
        file.writeU16(signature.index)
    }
}

class constStringInfo(str) {
    inherit constantPoolTagged(8)

    def value is readable = str

    method writeBody(file) {
        file.writeU16(value.index)
    }
}

class constNameAndType(name', desc) {
    inherit constantPoolTagged(12)

    def name is readable = name'
    def descriptor is readable = desc

    method writeBody(file) {
        file.writeU16(name.index)
        file.writeU16(descriptor.index)
    }
}

class constFloatInfo(val) {
    inherit constantPoolTagged(4)

    def value is readable = val

    method writeBody(file) {
        file.writeF32(value)
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

    method parentClass { cls }

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

    def mainClassName = stringConst("Grace_{n}")
    def mainClass = constClassInfo(mainClassName).addToFile(self)

    method classType { mainClass }

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

    method outerMethod {
        def m = methodNamed("runtimeTopLevel") descriptor("()V")
            index(methods.size + 1) inside(self)
        methods.add(m)
        m
    }

    method constructor {
        def objInit = methodRef("<init>") withDesc("()V")
            inClass(moduleBaseClass)
        def m = methodNamed("<init>") descriptor("()V")
            index(methods.size + 1) inside(self)
        methods.add(m)
        m.withCode { code ->
            code.add(ops.aload_0)
            code.add(ops.invokespecial(objInit))
        }
        m
    }

    method defaultConstructor {
        def c = constructor
        c.withCode { code ->
            code.add(ops.return_)
        }
        c
    }

    method addConstant(const) {
        const.setIndex(constants.size + 1)
        constants.add(const)
        const
    }

    method methodRef(name') withDesc(desc) inClass(cls) {
        def name_str = stringConst(name')
        def desc_str = stringConst(desc)
        def nat_elem = constNameAndType(name_str, desc_str).addToFile(self)
        def cls_elem = constClassInfo(stringConst(cls)).addToFile(self)
        constMethodRef(nat_elem, cls_elem).addToFile(self)
    }

    method methodRef(name') withDesc(desc) {
        def name_str = stringConst(name')
        def desc_str = stringConst(desc)
        def nat_elem = constNameAndType(name_str, desc_str).addToFile(self)
        constMethodRef(nat_elem, mainClass).addToFile(self)
    }

    method graceMethodRef(name') withArgs(nargs) inClass(cls) {
        var args := ""
        (1..nargs).do { x -> args := args ++ "Ljava/lang/Object;" }
        print("Adding Grace method reference")
        methodRef(name') withDesc("({args})L{objectBaseClass};") inClass(cls)
    }

    method stringConst(str) {
        cachedStrings.at(str) ifAbsent {
            print("Adding {str}")
            def s = constUnicode(str).addToFile(self)
            cachedStrings.at(str) put(s)
            s
        }
    }

    method stringInfoConst(str) {
        def s = stringConst(str)
        constStringInfo(s).addToFile(self)
    }

    method floatConst(val) {
        constFloatInfo(val).addToFile(self)
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
        file.writeU16(0x21)
        file.writeU16(mainClass.index)
        file.writeU16(modClass.index)
    }

    method writeHeaderTo(file) {
        def magicHighOrder = 0xcafe
        def magicLowOrder = 0xbabe
        def versionUpper = 0
        def versionLower = 52
        file.writeU16(magicHighOrder)
        file.writeU16(magicLowOrder)
        file.writeU16(versionUpper)
        file.writeU16(versionLower)
    }
}
