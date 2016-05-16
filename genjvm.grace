import "io" as io
import "sys" as sys
import "ast" as ast
import "util" as util
import "jvm" as jvm
import "errormessages" as errormessages

method compile(module, outfile, rm, bt, buildinfo) {
    util.log_verbose "generating JVM bytecode."

    def file = jvm.classFile
}
