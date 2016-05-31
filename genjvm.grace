import "io" as io
import "sys" as sys
import "ast" as ast
import "util" as util
import "jvm" as jvm
import "jvmops" as insn
import "errormessages" as errormessages

method compile(module, outfile, rm, bt, buildinfo) {
    util.log_verbose "generating JVM bytecode."

    def main = jvm.classNamed "{util.modnamev}" 
    def ctor = main.defaultConstructor
    def mainFn = main.mainMethod

    def initMethod = main.methodRef("<init>") withDesc("()V")
    def runMethod = main.methodRef("runtimeTopLevel") withDesc("()V")
    mainFn.withCode { code ->
        code.add(insn.new(main.classType))
        code.add(insn.dup)
        code.add(insn.invokespecial(initMethod))
        code.add(insn.invokevirtual(runMethod))
        code.add(insn.return_)
    }

    util.log_verbose "main class is {main.name}"

    // Find a list of classes to build
    //def classVisit = ast.classTypeVisitor
    //module.visit(classVisit)
    //print(classVisit.objects.asDebugString)

    module.addInstanceVarsTo(main)
    module.addMethodsTo(main)
    module.addGlobalCodeTo(main)

    main.writeTo(outfile)
    outfile.close
    util.log_verbose "done."
}
