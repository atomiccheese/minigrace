import "io" as io

class classFile {
    method writeTo(file) {
        file.writeU32(0xcafebabe)
    }
}
