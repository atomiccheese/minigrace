package net.gracelang.minigrace.runtime;

import net.gracelang.minigrace.runtime.GraceString;

public class GraceObject implements GraceObjectBase {
    public GraceObject print(Object param) {
        if(param instanceof GraceObject) {
            System.out.println(((GraceObject)param).runtimeAsString());
        } else {
            System.out.println(param.toString());
        }
        return null;
    }

    public GraceString asString() {
        return new GraceString("<an object>");
    }

    public void runtimeTopLevel() { }

    public String runtimeAsString() {
        return asString().runtimeAsString();
    }
};
