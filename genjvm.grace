import "io" as io
import "sys" as sys
import "ast" as ast
import "util" as util
import "jvm" as jvm
import "errormessages" as errormessages

method compile(module, outfile, rm, bt, buildinfo) {
    util.log_verbose "generating JVM bytecode."

    def cls = jvm.classNamed "Grace_{util.modnamev}" inheriting "GraceObject"
        inPackage "net.gracelang.minigrace"

    util.log_verbose "main class is {cls.name}"

    outfile.close
    util.log_verbose "done."
}
