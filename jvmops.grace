class opcode(name') encodedAs(num) {
    def name is readable = name'
    def code is readable = num

    method size { 1 }
    method writeTo(file) { file.writeU8(code) }
}

// Constants
def nop             = opcode("nop")             encodedAs(0x00)
def aconst_null     = opcode("aconst_null")     encodedAs(0x01)
def iconst_m1       = opcode("iconst_m1")       encodedAs(0x02)
def iconst_0        = opcode("iconst_0")        encodedAs(0x03)
def iconst_1        = opcode("iconst_1")        encodedAs(0x04)
def iconst_2        = opcode("iconst_2")        encodedAs(0x05)
def iconst_3        = opcode("iconst_3")        encodedAs(0x06)
def iconst_4        = opcode("iconst_4")        encodedAs(0x07)
def iconst_5        = opcode("iconst_5")        encodedAs(0x08)
def lconst_0        = opcode("lconst_0")        encodedAs(0x09)
def lconst_1        = opcode("lconst_1")        encodedAs(0x0a)
def fconst_0        = opcode("fconst_0")        encodedAs(0x0b)
def fconst_1        = opcode("fconst_1")        encodedAs(0x0c)
def fconst_2        = opcode("fconst_2")        encodedAs(0x0d)
def dconst_0        = opcode("dconst_0")        encodedAs(0x0e)
def dconst_1        = opcode("dconst_1")        encodedAs(0x0f)

class bipush(n) {
    inherit opcode("bipush") encodedAs(0x10)

    def value = n

    method size { 2 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeI8(value)
    }
}

def sipush          = opcode("sipush")          encodedAs(0x11)
def ldc             = opcode("ldc")             encodedAs(0x12)
def ldc_w           = opcode("ldc_w")           encodedAs(0x13)
def ldc2_w          = opcode("ldc2_w")          encodedAs(0x14)

// Loads
class iload(idx) {
    inherit opcode("iload") encodedAs(0x15)

    def index = idx

    method size { 2 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU8(index)
    }
}
def lload           = opcode("lload")           encodedAs(0x16)

class fload(idx) {
    inherit opcode("fload") encodedAs(0x17)

    def index = idx

    method size { 2 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU8(index)
    }
}

class dload(idx) {
    inherit opcode("dload") encodedAs(0x18)

    def index = idx

    method size { 2 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU8(index)
    }
}

class aload(idx) {
    inherit opcode("aload") encodedAs(0x19)

    def index = idx

    method size { 2 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU8(index)
    }
}

def iload_0         = opcode("iload_0")         encodedAs(0x1a)
def iload_1         = opcode("iload_1")         encodedAs(0x1b)
def iload_2         = opcode("iload_2")         encodedAs(0x1c)
def iload_3         = opcode("iload_3")         encodedAs(0x1d)
def lload_0         = opcode("lload_0")         encodedAs(0x1e)
def lload_1         = opcode("lload_1")         encodedAs(0x1f)
def lload_2         = opcode("lload_2")         encodedAs(0x20)
def lload_3         = opcode("lload_3")         encodedAs(0x21)
def fload_0         = opcode("fload_0")         encodedAs(0x22)
def fload_1         = opcode("fload_1")         encodedAs(0x23)
def fload_2         = opcode("fload_2")         encodedAs(0x24)
def fload_3         = opcode("fload_3")         encodedAs(0x25)
def dload_0         = opcode("dload_0")         encodedAs(0x26)
def dload_1         = opcode("dload_1")         encodedAs(0x27)
def dload_2         = opcode("dload_2")         encodedAs(0x28)
def dload_3         = opcode("dload_3")         encodedAs(0x29)
def aload_0         = opcode("aload_0")         encodedAs(0x2a)
def aload_1         = opcode("aload_1")         encodedAs(0x2b)
def aload_2         = opcode("aload_2")         encodedAs(0x2c)
def aload_3         = opcode("aload_3")         encodedAs(0x2d)
def iaload          = opcode("iaload")          encodedAs(0x2e)
def laload          = opcode("laload")          encodedAs(0x2f)
def faload          = opcode("faload")          encodedAs(0x30)
def daload          = opcode("daload")          encodedAs(0x31)
def aaload          = opcode("aaload")          encodedAs(0x32)
def baload          = opcode("baload")          encodedAs(0x33)
def caload          = opcode("caload")          encodedAs(0x34)
def saload          = opcode("saload")          encodedAs(0x35)

// Stores
class istore(idx) {
    inherit opcode("istore") encodedAs(0x36)

    def index = idx

    method size { 2 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU8(index)
    }
}
def lstore          = opcode("lstore")          encodedAs(0x37)
def fstore          = opcode("fstore")          encodedAs(0x38)
def dstore          = opcode("dstore")          encodedAs(0x39)

class astore(idx) {
    inherit opcode("astore") encodedAs(0x3a)
    
    def index = idx

    method size { 2 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU8(index)
    }
}

def istore_0        = opcode("istore_0")        encodedAs(0x3b)
def istore_1        = opcode("istore_1")        encodedAs(0x3c)
def istore_2        = opcode("istore_2")        encodedAs(0x3d)
def istore_3        = opcode("istore_3")        encodedAs(0x3e)
def lstore_0        = opcode("lstore_0")        encodedAs(0x3f)
def lstore_1        = opcode("lstore_1")        encodedAs(0x40)
def lstore_2        = opcode("lstore_2")        encodedAs(0x41)
def lstore_3        = opcode("lstore_3")        encodedAs(0x42)
def fstore_0        = opcode("fstore_0")        encodedAs(0x43)
def fstore_1        = opcode("fstore_1")        encodedAs(0x44)
def fstore_2        = opcode("fstore_2")        encodedAs(0x45)
def fstore_3        = opcode("fstore_3")        encodedAs(0x46)
def dstore_0        = opcode("dstore_0")        encodedAs(0x47)
def dstore_1        = opcode("dstore_1")        encodedAs(0x48)
def dstore_2        = opcode("dstore_2")        encodedAs(0x49)
def dstore_3        = opcode("dstore_3")        encodedAs(0x4a)
def astore_0        = opcode("astore_0")        encodedAs(0x4b)
def astore_1        = opcode("astore_1")        encodedAs(0x4c)
def astore_2        = opcode("astore_2")        encodedAs(0x4d)
def astore_3        = opcode("astore_3")        encodedAs(0x4e)
def iastore         = opcode("iastore")         encodedAs(0x4f)
def lastore         = opcode("lastore")         encodedAs(0x50)
def fastore         = opcode("fastore")         encodedAs(0x51)
def dastore         = opcode("dastore")         encodedAs(0x52)
def aastore         = opcode("aastore")         encodedAs(0x53)
def bastore         = opcode("bastore")         encodedAs(0x54)
def castore         = opcode("castore")         encodedAs(0x55)
def sastore         = opcode("sastore")         encodedAs(0x56)

// Stack
def pop             = opcode("pop")             encodedAs(0x57)
def pop2            = opcode("pop2")            encodedAs(0x58)
def dup             = opcode("dup")             encodedAs(0x59)
def dup_x1          = opcode("dup_x1")          encodedAs(0x5a)
def dup_x2          = opcode("dup_x2")          encodedAs(0x5b)
def dup2            = opcode("dup2")            encodedAs(0x5c)
def dup2_x1         = opcode("dup2_x1")         encodedAs(0x5d)
def dup2_x2         = opcode("dup2_x2")         encodedAs(0x5e)
def swap            = opcode("swap")            encodedAs(0x5f)

// Math
def iadd            = opcode("iadd")            encodedAs(0x60)
def ladd            = opcode("ladd")            encodedAs(0x61)
def fadd            = opcode("fadd")            encodedAs(0x62)
def dadd            = opcode("dadd")            encodedAs(0x63)
def isub            = opcode("isub")            encodedAs(0x64)
def lsub            = opcode("lsub")            encodedAs(0x65)
def fsub            = opcode("fsub")            encodedAs(0x66)
def dsub            = opcode("dsub")            encodedAs(0x67)
def imul            = opcode("imul")            encodedAs(0x68)
def lmul            = opcode("lmul")            encodedAs(0x69)
def fmul            = opcode("fmul")            encodedAs(0x6a)
def dmul            = opcode("dmul")            encodedAs(0x6b)
def idiv            = opcode("idiv")            encodedAs(0x6c)
def ldiv            = opcode("ldiv")            encodedAs(0x6d)
def fdiv            = opcode("fdiv")            encodedAs(0x6e)
def ddiv            = opcode("ddiv")            encodedAs(0x6f)
def irem            = opcode("irem")            encodedAs(0x70)
def lrem            = opcode("lrem")            encodedAs(0x71)
def frem            = opcode("frem")            encodedAs(0x72)
def drem            = opcode("drem")            encodedAs(0x73)
def ineg            = opcode("ineg")            encodedAs(0x74)
def lneg            = opcode("lneg")            encodedAs(0x75)
def fneg            = opcode("fneg")            encodedAs(0x76)
def dneg            = opcode("dneg")            encodedAs(0x77)
def ishl            = opcode("ishl")            encodedAs(0x78)
def lshl            = opcode("lshl")            encodedAs(0x79)
def ishr            = opcode("ishr")            encodedAs(0x7a)
def lshr            = opcode("lshr")            encodedAs(0x7b)
def iushr           = opcode("iushr")           encodedAs(0x7c)
def lushr           = opcode("lushr")           encodedAs(0x7d)
def iand            = opcode("iand")            encodedAs(0x7e)
def land            = opcode("land")            encodedAs(0x7f)
def ior             = opcode("ior")             encodedAs(0x80)
def lor             = opcode("lor")             encodedAs(0x81)
def ixor            = opcode("ixor")            encodedAs(0x82)
def lxor            = opcode("lxor")            encodedAs(0x83)
class iinc(idx, val) {
    inherit opcode("iinc") encodedAs(0x84)

    def index = idx
    def value = val

    method size { 3 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU8(index)
        file.writeI8(value)
    }
}

// Conversions
def i2l             = opcode("i2l")             encodedAs(0x85)
def i2f             = opcode("i2f")             encodedAs(0x86)
def i2d             = opcode("i2d")             encodedAs(0x87)
def l2i             = opcode("l2i")             encodedAs(0x88)
def l2f             = opcode("l2f")             encodedAs(0x89)
def l2d             = opcode("l2d")             encodedAs(0x8a)
def f2i             = opcode("f2i")             encodedAs(0x8b)
def f2l             = opcode("f2l")             encodedAs(0x8c)
def f2d             = opcode("f2d")             encodedAs(0x8d)
def d2i             = opcode("d2i")             encodedAs(0x8e)
def d2l             = opcode("d2l")             encodedAs(0x8f)
def d2f             = opcode("d2f")             encodedAs(0x90)
def i2b             = opcode("i2b")             encodedAs(0x91)
def i2c             = opcode("i2c")             encodedAs(0x92)
def i2s             = opcode("i2s")             encodedAs(0x93)

// Comparisons
def lcmp            = opcode("lcmp")            encodedAs(0x94)
def fcmpl           = opcode("fcmpl")           encodedAs(0x95)
def fcmpg           = opcode("fcmpg")           encodedAs(0x96)
def dcmpl           = opcode("dcmpl")           encodedAs(0x97)
def dcmpg           = opcode("dcmpg")           encodedAs(0x98)

class conditionalOpcode(name') encoding(enc) index(idx) {
    inherit opcode(name') encodedAs(enc)

    def index = idx

    method size { 3 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeI16(index)
    }
}
class ifeq(idx) {
    inherit conditionalOpcode("ifeq") encoding(0x99) index(idx)
}
class ifne(idx) {
    inherit conditionalOpcode("ifne") encoding(0x9a) index(idx)
}
class iflt(idx) {
    inherit conditionalOpcode("iflt") encoding(0x9b) index(idx)
}
class ifge(idx) {
    inherit conditionalOpcode("ifge") encoding(0x9c) index(idx)
}
class ifgt(idx) {
    inherit conditionalOpcode("ifgt") encoding(0x9d) index(idx)
}
class ifle(idx) {
    inherit conditionalOpcode("ifle") encoding(0x9e) index(idx)
}
class if_icmpeq(idx) {
    inherit conditionalOpcode("if_icmpeq") encoding(0x9f) index(idx)
}
class if_icmpne(idx) {
    inherit conditionalOpcode("if_icmpne") encoding(0xa0) index(idx)
}
class if_icmplt(idx) {
    inherit conditionalOpcode("if_icmplt") encoding(0xa1) index(idx)
}
class if_icmpge(idx) {
    inherit conditionalOpcode("if_icmpge") encoding(0xa2) index(idx)
}
class if_icmpgt(idx) {
    inherit conditionalOpcode("if_icmpgt") encoding(0xa3) index(idx)
}
class if_icmple(idx) {
    inherit conditionalOpcode("if_icmple") encoding(0xa4) index(idx)
}
class if_acmpeq(idx) {
    inherit conditionalOpcode("if_acmpeq") encoding(0xa5) index(idx)
}
class if_acmpne(idx) {
    inherit conditionalOpcode("if_acmpne") encoding(0xa6) index(idx)
}

// Control
class goto(idx) {
    inherit opcode("goto") encodedAs(0xa7)

    def index = idx

    method size { 3 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeI16(index)
    }
}

class jsr(offs) {
    inherit opcode("jsr") encodedAs(0xa8)

    def offset = offs

    method size { 3 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeI16(offset)
    }
}
def ret             = opcode("ret")             encodedAs(0xa9)
def tableswitch     = opcode("tableswitch")     encodedAs(0xaa)
def lookupswitch    = opcode("lookupswitch")    encodedAs(0xab)
def ireturn         = opcode("ireturn")         encodedAs(0xac)
def lreturn         = opcode("lreturn")         encodedAs(0xad)
def freturn         = opcode("freturn")         encodedAs(0xae)
def dreturn         = opcode("dreturn")         encodedAs(0xaf)
def areturn         = opcode("areturn")         encodedAs(0xb0)
def return_         = opcode("return")          encodedAs(0xb1)

// References
class getstatic(idx) {
    inherit opcode("getstatic") encodedAs(0xb2)

    def index = idx

    method size { 3 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU16(index)
    }
}

def putstatic       = opcode("putstatic")       encodedAs(0xb3)

class getfield(idx) {
    inherit opcode("getfield") encodedAs(0xb4)

    def index = idx

    method size { 3 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU16(index)
    }
}

def putfield        = opcode("putfield")        encodedAs(0xb5)
class invokevirtual(idx) {
    inherit opcode("invokevirtual") encodedAs(0xb6)

    def index = idx

    method size { 3 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU16(index)
    }
}
class invokespecial(idx) {
    inherit opcode("invokespecial") encodedAs(0xb7)

    def index = idx

    method size { 2 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU16(index)
    }
}
class invokestatic(idx) {
    inherit opcode("invokestatic") encodedAs(0xb8)

    def index = idx

    method size { 2 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU16(index)
    }
}
class invokeinterface(idx, count') {
    inherit opcode("invokeinterface") encodedAs(0xb9)

    def index = idx
    def count = count'

    method size { 4 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU16(index)
        file.writeU8(count)
        file.writeU8(0)
    }
}
class invokedynamic(idx) {
    inherit opcode("invokedynamic") encodedAs(0xba)

    def index = idx

    method size { 3 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU16(index)
        file.writeU16(0)
    }
}
def new             = opcode("new")             encodedAs(0xbb)
def newarray        = opcode("newarray")        encodedAs(0xbc)

class anewarray(typeidx) {
    inherit opcode("anewarray") encodedAs(0xbd)

    def index = typeidx

    method size { 3 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU16(index)
    }
}

def arraylength     = opcode("arraylength")     encodedAs(0xbe)
def athrow          = opcode("athrow")          encodedAs(0xbf)
def checkcast       = opcode("checkcast")       encodedAs(0xc0)
class instanceof(idx) {
    inherit opcode("instanceof") encodedAs(0xc1)

    def index = idx

    method size { 3 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeU16(index)
    }
}
def monitorenter    = opcode("monitorenter")    encodedAs(0xc2)
def monitorexit     = opcode("monitorexit")     encodedAs(0xc3)

// Extended
def wide            = opcode("wide")            encodedAs(0xc4)
def multianewarray  = opcode("multianewarray")  encodedAs(0xc5)

class ifnull(idx) {
    inherit conditionalOpcode("ifnull") encoding(0xc6) index(idx)
}
class ifnonnull(idx) {
    inherit conditionalOpcode("ifnonnull") encoding(0xc7) index(idx)
}

class goto_w(idx) {
    inherit opcode("goto_w") encodedAs(0xc8)

    def index = idx

    method size { 5 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeI32(index)
    }
}
class jsr_w(offs) {
    inherit opcode("jsr_w") encodedAs(0xc9)

    def offset = offs

    method size { 5 }
    method writeTo(file) {
        file.writeU8(code)
        file.writeI32(offs)
    }
}

// Reserved
def breakpoint      = opcode("breakpoint")      encodedAs(0xca)
def impdep1         = opcode("impdep1")         encodedAs(0xfe)
def impdep2         = opcode("impdep2")         encodedAs(0xff)
