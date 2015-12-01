import "unicode" as unicode
import "math" as math
import "mgwords" as mgw

def words = mgw.graceWords.asSet

def rs = randomStrings(1000)

printMetrics ".hash on 1..1000" forFun {x -> x} onData (1..1000)
printMetrics ".hashJ6 on 1..1000" forFun {x -> x.hashJ6} onData (1..1000)
printMetrics ".hash on 1000 random strings" forFun {x -> x.hash} onData (rs)
printMetrics ".hashJ5 on 1000 random strings" forFun {x -> x.hashJ5} onData (rs)
printMetrics ".hashJ6 on 1000 random strings" forFun {x -> x.hashJ6} onData (rs)
printMetrics ".hashP on 1000 random strings" forFun {x -> x.hashP} onData (rs)
printMetrics ".hash on mg words" forFun {x -> x.hash} onData (words)
printMetrics ".hashJ5 on mg words" forFun {x -> x.hashJ5} onData (words)
printMetrics ".hashJ6 on mg words" forFun {x -> x.hashJ6} onData (words)
printMetrics ".hashP on mg words" forFun {x -> x.hashP} onData (words)

class hashQuality(data, hashFn) {
    def sizeD is public = data.size
    def hashDict = dictionary.empty
    var histogram is readable := list.with(0, 0, 0, 0, 0)
    data.do { d ->
        def h = hashFn.apply(d)
        def indicator = hashDict.at(h) ifAbsent { 0 }
        hashDict.at(h) put(indicator + 1)
    }

    method collisionRate {
        def sizeHashD = hashDict.size
        if (sizeD == 0) then { 0 } else { sizeD / sizeHashD }
    }
    
    method numberOfCollisions {
        def sizeHashD = hashDict.size
        if (sizeD == 0) then { 0 } else { sizeD - sizeHashD }
    }

    method quality {
        if (collisionRate == 0) then { return 100 }
        100 / collisionRate
    }

    method chiSquared {
        // Valoud's Chi-squared test
        var sum := 0
        var count := 0
        histogram := list.with(0, 0, 0, 0, 0)
        def hSize = histogram.size - 1
        hashDict.valuesDo { v ->
            if (v > 0) then { sum := sum + (v-1)*(v-1) }
            count := count + v
            if (v <= 0) then { print "v = {v} !!!" }
            if (v <= hSize) then {
                histogram.at(v) put(histogram.at(v) + 1)
            } else {
                histogram.at(hSize + 1) put(histogram.at(hSize + 1) + 1)
            }
        }
        if (count ≠ sizeD) then { print "count = {count} but sizeD = {sizeD}" }
        if (sizeD == 0) then { 0 } else { sum / sizeD }
    }

    method chiSquaredModP {
        var p' := 8
//        print "in chiSquaredModP; sizeD = {sizeD}"
        while { p' < sizeD } do {
            p' := p' * 2
        }
        class resultRecord(modulus) {
//            print "creating resultRecord({modulus})"
            var chiSquared is public := 0
            var distribution is public
            method p { modulus }
            method asString { "χ²_{p} = {chiSquared}; histogram = {distribution}" }
            method == (other) { p == other.p }
            method < (other) { p < other.p }
        }
        def results = list.empty
//        print "initialized results = {results}"
        while {
//            print "in while condition; p' = {p'}"
//            print "(sizeD * 4) = {sizeD * 4}"
            p' < (sizeD * 4)
        } do {
//            print "about to request resultRecord({p'})"
            results.add( resultRecord(p') )
            p' := p' * 2
        }
//        print "established results for powers of 2"
        p' := results.first.p / 2.sqrt
        if (p'.rounded > sizeD) then { 
            results.add(resultRecord(p'.rounded))
        }
        while { p' := p' * 2 ; p' < (sizeD * 4) } do {
            results.add( resultRecord(p'.rounded) )
        }
//        print "established results for powers of 2 * sqrt(2)"
        results.sort
        results.do { each ->
            p' := each.p
            def histogram' = list.with(0, 0, 0, 0, 0)
            def hSize = histogram'.size - 1
            def counts = list.empty
            repeat (p') times { counts.addLast(0) }
            var countTotal := 0
            hashDict.keysAndValuesDo { h, count ->
                def hModP = (h % p') + 1
                counts.at (hModP) put (counts.at(hModP) + count)
                countTotal := countTotal + count
            }
            if (countTotal ≠ sizeD) then {
                print "countTotal = {countTotal} but sizeD = {sizeD}"
            }
            var sum := 0
            var cTotal := 0
            counts.do { count ->
                if (count > 1) then {
                    sum := sum + ((count - 1)*(count - 1))
                }
                if (count > 0) then {
                    if (count <= hSize) then {
                        histogram'.at(count) put(histogram'.at(count) + 1)
                    } else {
                        histogram'.at(hSize + 1) put(histogram'.at(hSize + 1) + 1)
                    }
                }
                cTotal := cTotal + count
            }
            if (cTotal ≠ sizeD) then {
                print "cTotal = {cTotal} but sizeD = {sizeD}"
            }
            each.chiSquared := sum / sizeD
            each.distribution := histogram'
        }
        results
    }
}

method randomStrings(n) {
    def result = list.empty
    (1..n).do { ix ->
        if ((ix % 100) == 0) then {
            result.add(shortRandomString)
        } else {
            result.add(longerRandomString)
        }
    }
    result
}
method shortRandomString {
    def base = "a".ord
    if ((math.random * 27) < 1) then {
        def ch = (math.random * 26).truncated + base
        //                print "single char '{unicode.create(ch)}'"
        unicode.create(ch)
    } else {
        def ch1 = (math.random * 26).truncated + base
        def ch2 = (math.random * 26).truncated + base
        unicode.create(ch1) ++ unicode.create(ch2)
    }
}
method longerRandomString {
    def base = "a".ord
    var s := ""
    repeat ((math.random * 10).truncated + 3) times {
        def ch = (math.random * 26).truncated + base
        s := s ++ unicode.create(ch)
    }
    s
}

method printMetrics (desc) forFun (fn) onData (d) {
    def q = hashQuality(d, fn)
    print "Hash Quality Measurements of {desc}"
    print "    Size of data set: {q.sizeD}"
    print "    Collision Rate = {q.collisionRate}"
    print "    Hash quality = {q.quality}%"
    def chiSq = q.chiSquared
    print "    χ² = {chiSq}; histogram = {q.histogram}"
    q.chiSquaredModP.do { each -> print "    {each}" }
    print ""
}
