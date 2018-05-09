/**
 * This module contains utilities for TypeInfo implementation.
 *
 * Copyright: Copyright Kenji Hara 2014-.
 * License:   <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors:   Kenji Hara
 */
module rt.util.typeinfo;

private enum isX87Real(T) = (T.mant_dig == 64 && T.max_exp == 16384);

template Floating(T)
if (is(T == float) || is(T == double) || is(T == real))
{
  pure nothrow @safe:

    bool equals(T f1, T f2)
    {
        return f1 == f2;
    }

    int compare(T d1, T d2)
    {
        if (d1 != d1 || d2 != d2) // if either are NaN
        {
            if (d1 != d1)
            {
                if (d2 != d2)
                    return 0;
                return -1;
            }
            return 1;
        }
        return (d1 == d2) ? 0 : ((d1 < d2) ? -1 : 1);
    }

    size_t hashOf(T value) @trusted
    {
        if (value == 0) // +0.0 and -0.0
            value = 0;

        static if (is(T == float))  // special case?
            return *cast(uint*)&value;
        else
        {
            import rt.util.hash;
            static if (isX87Real!T) // Only consider the non-padding bytes.
                return rt.util.hash.hashOf((cast(void*) &value)[0 .. 10], 0);
            else
                return rt.util.hash.hashOf((&value)[0 .. 1], 0);
        }
    }
}
template Floating(T)
if (is(T == cfloat) || is(T == cdouble) || is(T == creal))
{
  pure nothrow @safe:

    bool equals(T f1, T f2)
    {
        return f1 == f2;
    }

    int compare(T f1, T f2)
    {
        int result;

        if (f1.re < f2.re)
            result = -1;
        else if (f1.re > f2.re)
            result = 1;
        else if (f1.im < f2.im)
            result = -1;
        else if (f1.im > f2.im)
            result = 1;
        else
            result = 0;
        return result;
    }

    size_t hashOf(T value) @trusted
    {
        if (value == 0 + 0i)
            value = 0 + 0i;
        import rt.util.hash;
        static if (isX87Real!(typeof(T.init.re))) // Only consider the non-padding bytes.
        {
            real* ptr = cast(real*) &value;
            return rt.util.hash.hashOf((cast(void*) &ptr[0])[0 .. 10],
                rt.util.hash.hashOf((cast(void*) &ptr[1])[0 .. 10], 0));
        }
        else
            return rt.util.hash.hashOf((&value)[0 .. 1], 0);
    }
}

template Array(T)
if (is(T ==  float) || is(T ==  double) || is(T ==  real) ||
    is(T == cfloat) || is(T == cdouble) || is(T == creal))
{
  pure nothrow @safe:

    bool equals(T[] s1, T[] s2)
    {
        size_t len = s1.length;
        if (len != s2.length)
            return false;
        for (size_t u = 0; u < len; u++)
        {
            if (!Floating!T.equals(s1[u], s2[u]))
                return false;
        }
        return true;
    }

    int compare(T[] s1, T[] s2)
    {
        size_t len = s1.length;
        if (s2.length < len)
            len = s2.length;
        for (size_t u = 0; u < len; u++)
        {
            if (int c = Floating!T.compare(s1[u], s2[u]))
                return c;
        }
        if (s1.length < s2.length)
            return -1;
        else if (s1.length > s2.length)
            return 1;
        return 0;
    }

    size_t hashOf(T[] value)
    {
        size_t h = 0;
        foreach (e; value)
            h += Floating!T.hashOf(e);
        return h;
    }
}

version(unittest)
{
    alias TypeTuple(T...) = T;
}
unittest
{
    // Bugzilla 13052

    static struct SX(F) { F f; }
    TypeInfo ti;

    // real types
    foreach (F; TypeTuple!(float, double, real))
    (){ // workaround #2396
        alias S = SX!F;
        F f1 = +0.0,
          f2 = -0.0;

        assert(f1  == f2);
        assert(f1 !is f2);
        ti = typeid(F);
        assert(ti.getHash(&f1) == ti.getHash(&f2));

        F[] a1 = [f1, f1, f1];
        F[] a2 = [f2, f2, f2];
        assert(a1  == a2);
        assert(a1 !is a2);
        ti = typeid(F[]);
        assert(ti.getHash(&a1) == ti.getHash(&a2));

        F[][] aa1 = [a1, a1, a1];
        F[][] aa2 = [a2, a2, a2];
        assert(aa1  == aa2);
        assert(aa1 !is aa2);
        ti = typeid(F[][]);
        assert(ti.getHash(&aa1) == ti.getHash(&aa2));

        S s1 = {f1},
          s2 = {f2};
        assert(s1  == s2);
        assert(s1 !is s2);
        ti = typeid(S);
        assert(ti.getHash(&s1) == ti.getHash(&s2));

        S[] da1 = [S(f1), S(f1), S(f1)],
            da2 = [S(f2), S(f2), S(f2)];
        assert(da1  == da2);
        assert(da1 !is da2);
        ti = typeid(S[]);
        assert(ti.getHash(&da1) == ti.getHash(&da2));

        S[3] sa1 = {f1},
             sa2 = {f2};
        assert(sa1  == sa2);
        assert(sa1[] !is sa2[]);
        ti = typeid(S[3]);
        assert(ti.getHash(&sa1) == ti.getHash(&sa2));
    }();

    // imaginary types
    foreach (F; TypeTuple!(ifloat, idouble, ireal))
    (){ // workaround #2396
        alias S = SX!F;
        F f1 = +0.0i,
          f2 = -0.0i;

        assert(f1  == f2);
        assert(f1 !is f2);
        ti = typeid(F);
        assert(ti.getHash(&f1) == ti.getHash(&f2));

        F[] a1 = [f1, f1, f1];
        F[] a2 = [f2, f2, f2];
        assert(a1  == a2);
        assert(a1 !is a2);
        ti = typeid(F[]);
        assert(ti.getHash(&a1) == ti.getHash(&a2));

        F[][] aa1 = [a1, a1, a1];
        F[][] aa2 = [a2, a2, a2];
        assert(aa1  == aa2);
        assert(aa1 !is aa2);
        ti = typeid(F[][]);
        assert(ti.getHash(&aa1) == ti.getHash(&aa2));

        S s1 = {f1},
          s2 = {f2};
        assert(s1  == s2);
        assert(s1 !is s2);
        ti = typeid(S);
        assert(ti.getHash(&s1) == ti.getHash(&s2));

        S[] da1 = [S(f1), S(f1), S(f1)],
            da2 = [S(f2), S(f2), S(f2)];
        assert(da1  == da2);
        assert(da1 !is da2);
        ti = typeid(S[]);
        assert(ti.getHash(&da1) == ti.getHash(&da2));

        S[3] sa1 = {f1},
             sa2 = {f2};
        assert(sa1  == sa2);
        assert(sa1[] !is sa2[]);
        ti = typeid(S[3]);
        assert(ti.getHash(&sa1) == ti.getHash(&sa2));
    }();

    // complex types
    foreach (F; TypeTuple!(cfloat, cdouble, creal))
    (){ // workaround #2396
        alias S = SX!F;
        F[4] f = [+0.0 + 0.0i,
                  +0.0 - 0.0i,
                  -0.0 + 0.0i,
                  -0.0 - 0.0i];

        foreach (i, f1; f) foreach (j, f2; f) if (i != j)
        {
            assert(f1 == 0 + 0i);

            assert(f1  == f2);
            assert(f1 !is f2);
            ti = typeid(F);
            assert(ti.getHash(&f1) == ti.getHash(&f2));

            F[] a1 = [f1, f1, f1];
            F[] a2 = [f2, f2, f2];
            assert(a1  == a2);
            assert(a1 !is a2);
            ti = typeid(F[]);
            assert(ti.getHash(&a1) == ti.getHash(&a2));

            F[][] aa1 = [a1, a1, a1];
            F[][] aa2 = [a2, a2, a2];
            assert(aa1  == aa2);
            assert(aa1 !is aa2);
            ti = typeid(F[][]);
            assert(ti.getHash(&aa1) == ti.getHash(&aa2));

            S s1 = {f1},
              s2 = {f2};
            assert(s1  == s2);
            assert(s1 !is s2);
            ti = typeid(S);
            assert(ti.getHash(&s1) == ti.getHash(&s2));

            S[] da1 = [S(f1), S(f1), S(f1)],
                da2 = [S(f2), S(f2), S(f2)];
            assert(da1  == da2);
            assert(da1 !is da2);
            ti = typeid(S[]);
            assert(ti.getHash(&da1) == ti.getHash(&da2));

            S[3] sa1 = {f1},
                 sa2 = {f2};
            assert(sa1  == sa2);
            assert(sa1[] !is sa2[]);
            ti = typeid(S[3]);
            assert(ti.getHash(&sa1) == ti.getHash(&sa2));
        }
    }();
}
