package net.gracelang.minigrace.runtime;

public class GraceString implements GraceObjectBase {
    public String value;

    public GraceString(String s) {
        super();
        value = s;
    }

    public GraceString asString() {
        return this;
    }

    public String runtimeAsString() {
        return value;
    }
};
