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

    util.log_verbose "main class is {main.name}"

    def mainFunc = main.mainMethod
    mainFunc.add(insn.return_)

    main.writeTo(outfile)
    outfile.close
    util.log_verbose "done."
}
