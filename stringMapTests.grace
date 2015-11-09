import "gUnit" as gU
import "stringMap" as map
import "unicode" as unicode
import "math" as math
import "sys" as sys

def stringMapTest = object {
    class forMethod(meth) {
        inherits gU.testCaseNamed(meth)
        
        def m123 = map.new
        m123.put("one", 1).put("two", 2).put("three", 3)
        
        def m12 = map.new
        m12.put("one", 1).put("two", 2)

        method testSize3 {
            assert (m123.size) shouldBe 3
        }
        
        method testSize2 {
            assert (m12.size) shouldBe 2
        }

        method testAsString {
            def m12Str = m12.asString
            assert ((m12Str == "map.new[two::2, one::1]")  || (m12Str == "map.new[one::1, two::2]"))
                description "m12.asString == {m12Str}"
        }
        method testAsList {
            def m123List = m123.asList
            assert (m123List.size) shouldBe 3
            assert (m123List.contains("one"::1)) 
                description "{m123List} does not contain \"one\"::1"
            assert (m123List.contains("two"::2))
                description "{m123List} does not contain \"two\"::2"
            assert (m123List.contains("three"::3))
                description "{m123List} does not contain \"three\"::3"
        }
        method testGetPresent {
            assert (m123.get "two") shouldBe 2
        }
        method testGetAbsent {
            assert {m123.get "foo"} shouldRaise (NoSuchObject)
        }
        method testGetIfAbsentPresent {
            assert (m123.get "two" ifAbsent { failBecause "two is absent" }) shouldBe 2
        }
        method testGetIfAbsent {
            var absent := false
            assert (m123.get "foo" ifAbsent { absent := true ; "absent" }) shouldBe "absent"
        }
        method testContainsPresent {
            assert (m123.contains "two") description "m123 does not contain \"two\""
        }
        method testContainsAbsent {
            deny (m123.contains "foo") description "m123 contains \"foo\""
        }
        method testMany {
            def n = if (engine == "c") then { 1000 } else { 10000 }
            def keys = randomStrings(n);
            def m = map.new
            def startTime = sys.elapsedTime
            keys.keysAndValuesDo { i, k ->
                m.put(k, i)
            }
            keys.do { k ->
                def v = m.get(k)
                assert (keys.at(v) == k) description "wrong value found for {k}"
            }
            def duration = sys.elapsedTime - startTime
            print "stringMap with {n} keys in {engine}:"
            print "    elapsed time to create and check is {duration}s"
            print "    {n - m.size} collisions."
        }
        method testDo {
            var sum := 0
            m123.do { val -> sum := sum + val }
            assert (sum) shouldBe 6
        }
        method testKeysDo {
            def keys = set.empty
            m123.keysDo { k -> keys.add(k) }
            assert (keys) shouldBe (set.with("one", "two", "three"))
        }
        method randomStrings(n) {
            def base = "a".ord
            def result = list.empty
            (1..n).do { ix ->
                var s := ""
                repeat ((math.random * 10).truncated + 3) times {
                    def ch = (math.random * 26).truncated + base
                    s := s ++ unicode.create(ch)
                }
                result.add(s)
            }
            result
        }
        method randomInts(n) {
            def maxInt = 0x7FFFFFFF
            def result = list.empty
            repeat (n) times {
                result.add((math.random * maxInt * 2).truncated - maxInt)
            }
            result
        }
        method testStringHash {
            def n = if (engine == "c") then { 500 } else { 5000 }
            def strings = randomStrings(n)
            def hashes = dictionary.empty
            var total := 0
            var minh := infinity
            var maxh := 0
            def startTime = sys.elapsedTime
            var p := 8
            while { p < (2 * n) } do { p := p * 2 }
            strings.do { s ->
                def h = s.hash
                if (h > maxh) then { maxh := h }
                if (h < minh) then { minh := h }
                def allStrings = hashes.at(h % p) ifAbsent {list.empty}
                hashes.at(h % p) put (allStrings.add(s))
            }
            def duration = sys.elapsedTime - startTime
            var twoUp := 0
            var threeUp := 0
            hashes.keysAndValuesDo { k, v -> 
                if (v.size > 1) then {
                    v.sort
                    def w = list.with(v.first)
                    v.do { each ->
                        if (w.last ≠ each) then { w.addLast(each) }
                    }
                    if (w.size == 2) then {
                        twoUp := twoUp + 1 
                    } elseif { w.size == 3 } then {
                        threeUp := threeUp + 1
                    } elseif { w.size > 3 } then {
                        print "hash {k} shared by {w}"
                    }
                }
                total := total + v.size
            }
            print "testing stringHash on {n} strings:"
            print "    {twoUp} buckets contain 2 values."
            print "    {threeUp} buckets contain 3 values."
            assert (total) shouldBe (n)
            print "    In {engine}, elapsed time is {duration}s."
            print "    Hash range is {minh}..{maxh}."
            print "    {hashes.size} distinct mod {p} values."
        }
        method testIntHash {
            def n = if (engine == "c") then { 500 } else { 5000 }
            def ints = randomInts(n)
            def hashes = dictionary.empty
            var total := 0
            var minh := infinity
            var maxh := 0
            def startTime = sys.elapsedTime
            var p := 8
            while { p < (2 * n) } do { p := p * 2 }
            ints.do { s ->
                def h = s.hash
                if (h > maxh) then { maxh := h }
                if (h < minh) then { minh := h }
                def allInts = hashes.at(h % p) ifAbsent {list.empty}
                hashes.at(h % p) put (allInts.add(s))
            }
            def duration = sys.elapsedTime - startTime
            var twoUp := 0
            var threeUp := 0
            hashes.keysAndValuesDo { k, v -> 
                if (v.size > 1) then {
                    v.sort
                    def w = list.with(v.first)
                    v.do { each ->
                        if (w.last ≠ each) then { w.addLast(each) }
                    }
                    if (w.size == 2) then {
                        twoUp := twoUp + 1 
                    } elseif { w.size == 3 } then {
                        threeUp := threeUp + 1
                    } elseif { w.size > 3 } then {
                        print "hash {k} shared by {w}"
                    }
                }
                total := total + v.size
            }
            print "testing intHash on {n} integers:"
            print "    {twoUp} buckets contain 2 values."
            print "    {threeUp} buckets contain 3 values."
            assert (total) shouldBe (n)
            print "    In {engine}, elapsed time for {n} hashes is {duration}s."
            print "    Hash range is {minh}..{maxh}."
            print "    {hashes.size} distinct mod {p} values."
        }
    }
}


def mapTests = gU.testSuite.fromTestMethodsIn(stringMapTest)
mapTests.name := "map tests"
mapTests.runAndPrintResults
