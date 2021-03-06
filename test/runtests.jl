using Compat
using Base.Test

v = 1
@test_throws AssertionError @assert(v < 1)

d = Dict{Int,Int}()
d[1] = 1
@test Compat.@Dict(1 => 1) == d
@test Compat.@Dict(1 => v) == d

@test typeof(@compat(Dict(1 => 1))) == Dict{Int,Int}
@test @compat(Dict(1 => 1)) == d
@test @compat(Dict(1 => v)) == d

ad = Dict{Any,Any}()
ad[1] = 1
@test Compat.@AnyDict(1 => 1) == ad
@test Compat.@AnyDict(1 => v) == ad

@test typeof(@compat(Dict{Any,Any}(1 => 1))) == Dict{Any,Any}
@test @compat(Dict{Any,Any}(1 => 1)) == ad
@test @compat(Dict{Any,Any}(1 => v)) == ad

td = Dict{Int,Float64}()
td[1] = 1.0

@test typeof(@compat(Dict{Int,Float64}(1 => 1))) == Dict{Int,Float64}
@test @compat(Dict{Int,Float64}(1 => 1)) == td
@test @compat(Dict{Int,Float64}(1 => v)) == td

@test @compat(Dict()) == Dict()
@test @compat(Dict{Any,Any}()) == Dict{Any,Any}()
@test @compat(Dict([(1, 1)])) == d
@test @compat(Dict(:Void => :Nothing)) == Dict([(:Void, :Nothing)])

d2 = Dict{Symbol,Dict{Symbol,Int}}()
d2[:a] = Dict{Symbol,Int}()
d2[:a][:b] = 1
@test @compat(Dict(:a => Dict(:b => 1))) == d2

d = Dict(zip([1, 2], [3, 4]))
@test d == @compat Dict(1=>3, 2=>4)

@compat function f()
    a = :a
    b = Dict(:b => 1)
    Dict(a => b)
end
@test f() == d2

ns = length(d.slots)
@test length(sizehint!(d, ns + 1).slots) > ns

@test @compat split("a,b,,c", ',', limit=2) == ["a", "b,,c"]
@test @compat split("a,b,,c", ',', limit=2,keep=true) == ["a", "b,,c"]
@test @compat split("a,b,,c", ',', keep=false) == ["a", "b", "c"]
@test @compat split("a,b,,c", ',', keep=true) == ["a", "b", "", "c"]

@test @compat rsplit("a,b,,c", ',', limit=2) == ["a,b,", "c"]
@test @compat rsplit("a,b,,c", ',', limit=2,keep=true) == ["a,b,", "c"]
@test @compat rsplit("a,b,,c", ',', keep=false) == ["a", "b", "c"]
@test @compat rsplit("a,b,,c", ',', keep=true) == ["a", "b", "", "c"]

if VERSION < v"0.4.0-dev+1387"
    @test isdefined(Main, :AbstractString)
end

@test round(Int, 3//4) == 1
@test round(Int, 1) == 1
@test round(Int, 1.1) == 1
@test round(Int, [1, 1]) == [1, 1]
@test round(Int, [1.1, 1.1]) == [1, 1]
@test round(Int, [1 1]) == [1 1]
@test round(Int, [1.1 1.1]) == [1 1]
@test round(Int, fill(1.1, 2, 3, 4)) == fill(1, 2, 3, 4)
@test ceil(Int, 1) == 1
@test ceil(Int, 1.1) == 2
@test ceil(Int, [1, 1]) == [1, 1]
@test ceil(Int, [1.1, 1.1]) == [2, 2]
@test ceil(Int, [1 1]) == [1 1]
@test ceil(Int, [1.1 1.1]) == [2 2]
@test ceil(Int, fill(1.1, 2, 3, 4)) == fill(2, 2, 3, 4)
@test floor(Int, 1) == 1
@test floor(Int, 1.1) == 1
@test floor(Int, [1, 1]) == [1, 1]
@test floor(Int, [1.1, 1.1]) == [1, 1]
@test floor(Int, [1 1]) == [1 1]
@test floor(Int, [1.1 1.1]) == [1 1]
@test floor(Int, fill(1.1, 2, 3, 4)) == fill(1, 2, 3, 4)
@test trunc(Int, 1) == 1
@test trunc(Int, 1.1) == 1
@test trunc(Int, [1, 1]) == [1, 1]
@test trunc(Int, [1.1, 1.1]) == [1, 1]
@test trunc(Int, [1 1]) == [1 1]
@test trunc(Int, [1.1 1.1]) == [1 1]
@test trunc(Int, fill(1.1, 2, 3, 4)) == fill(1, 2, 3, 4)

# n % Type
for T in Any[Int16, Int32, UInt32, Int64, UInt64]
    if !(T <: Unsigned)
        @test convert(T, -200) %  Int8 === @compat Int8(56)
        @test convert(T, -200) % UInt8 === 0x38
        @test convert(T, -300) %  Int8 === @compat Int8(-44)
        @test convert(T, -300) % UInt8 === 0xd4
        @test convert(T, -128) %  Int8 === @compat Int8(-128)
        @test convert(T, -128) % UInt8 === 0x80
    end
    @test convert(T,  127) %  Int8 === @compat Int8(127)
    @test convert(T,  127) % UInt8 === 0x7f
    @test convert(T,  128) %  Int8 === @compat Int8(-128)
    @test convert(T,  128) % UInt8 === 0x80
    @test convert(T,  200) %  Int8 === @compat Int8(-56)
    @test convert(T,  300) % UInt8 === 0x2c
end

@test IPv4("1.2.3.4") == ip"1.2.3.4"
@test IPv6("2001:1:2:3::1") == ip"2001:1:2:3::1"
@test isless(ip"1.2.3.4", ip"1.2.3.5")

@test startswith("abcdef","abc") == true
@test startswith("abcdef","def") == false

@test size(bitrand(3, 4)) == (3, 4)
@test size(bitrand((3, 4))) == (3, 4)
@test size(bitrand(MersenneTwister(), 3, 4)) == (3, 4)
@test size(bitrand(MersenneTwister(), (3, 4))) == (3, 4)
@test rand(Bool) in [false, true]

rng = MersenneTwister()
srand()
srand(rng, UInt32[0,0])
srand(rng)
for Tr in (Int8,UInt8,Int32,UInt32,Int64,UInt64,Int128,UInt128,Float16,Float32,Float64)
    for T in (Tr, Complex{Tr})
        @test isa(rand(rng, T), T)
        let x = rand(rng, T, 3,4)
            @test isa(x, Array{T,2})
            @test size(x) == (3,4)
            rand!(rng, x)
        end
    end
end
srand(rng, 0)
let x = rand(rng, Int64, 3,4)
    srand(rng, 0)
    @test x == rand(rng, Int64, (3,4))
end

module CartesianTest
    using Base.Cartesian, Compat
    @ngenerate N NTuple{N,Int} function f(X::NTuple{N,Int}...)
        @ncall N tuple X
    end
end

@test CartesianTest.f(1) == (1,)
@test CartesianTest.f(1,2) == (1,2)
@test CartesianTest.f(1,2,3) == (1,2,3)
@test CartesianTest.f(1,2,3,4) == (1,2,3,4)
@test CartesianTest.f(1,2,3,4,5) == (1,2,3,4,5)

extrapath = @windows? joinpath(JULIA_HOME,"..","Git","usr","bin")*";" : ""
@compat withenv("PATH" => extrapath * ENV["PATH"]) do
    @test readstring(pipeline(`echo hello`, `sort`)) == "hello\n"
    @test success(pipeline(`true`, `true`))
end

let convert_funcs_and_types =
    ((integer, :Integer), (signed, :Signed), (unsigned, :Unsigned),
     (int, :Int), (int8, :Int8), (int16, :Int16), (int32, :Int32),
     (int64, :Int64), (int128, :Int128), (uint, :UInt),
     (uint8, :UInt8), (uint16, :UInt16), (uint32, :UInt32),
     (uint64, :UInt64), (uint128, :UInt128),
     (float16, :Float16), (float32, :Float32), (float64, :Float64),
     (complex32,:Complex32), (complex64,:Complex64),(complex128,:Complex128),
     (char,:Char))

    for (df,t) in convert_funcs_and_types
        x = @compat UInt8(10)
        r1 = eval(:(@compat($t($x))))
        ty = eval(t)
        if ty.abstract
            @test issubtype(typeof(r1),ty)
        else
            @test typeof(r1) === ty
        end
        if VERSION <  v"0.4.0-dev+3732"
            r2 = df(x)
            @test r1 === r2
            if t === :Signed || t === :Complex32
                continue
            end
            x = fill(x, 10)
            r1 = eval(:(@compat map($t, $x)))
            r2 = df(x)
            @test r1 == r2
            @test typeof(r1) === typeof(r2)
        end
    end
    @test (@compat Bool(1))
    @test !(@compat Bool(0))

    # issue #54
    c = @compat Complex128(1)
    @test c.re == 1
    @test c.im == 0

    c = @compat Complex128(1,2)
    @test c.re == 1
    @test c.im == 2

    c = @compat Complex128(1+2im)
    @test c.re == 1
    @test c.im == 2
end

type Test3609
    a
    b
end

if VERSION < v"0.4.0-dev+3609"
    let v = Test3609(1,2)
        @test fieldnames(Test3609) == fieldnames(v) == Symbol[:a, :b]
    end
end

@test parse(Int8, '9') == convert(Int8, 9)
@test parse(Int, 'a', 16) == 10
@test parse(Int, "200") == 200
@test parse(Int16, "1101", 2) == convert(Int16, 13)
@test parse(Float64, "222") == 222.0
@test parse(Float32, "1.1") == convert(Float32, 1.1)
@test parse(BigFloat, "1.125") == convert(BigFloat, 1.125)
@test isa(tryparse(Float32, "1.1"), Nullable)
@test get(tryparse(Float32, "1.1")) == 1.1f0
@test isa(tryparse(Float32, "a"), Nullable{Float32})
@test isa(tryparse(Float64, "1.1"), Nullable)
@test get(tryparse(Float64, "1.1")) == 1.1
@test isa(tryparse(Float64, "a"), Nullable{Float64})
@test get(tryparse(Int32, "1")) == 1
@test isa(tryparse(Int32, "a"), Nullable{Int32})
@test get(tryparse(Int64, "1")) == 1
@test isa(tryparse(Int64, "a"), Nullable{Int64})

# Make sure exports from Libc and Libdl are defined
for x in [:strftime,:systemsleep,:getpid,:FILE,:malloc,:flush_cstdio,:realloc,:strptime,:Libc,:errno,:msync,:TmStruct,:calloc,:time,:strerror,:gethostname,:free]
    Libc.(x)
end
for x in [:RTLD_LOCAL,:RTLD_GLOBAL,:find_library,:dlsym,:RTLD_LAZY,:RTLD_NODELETE,:DL_LOAD_PATH,:RTLD_NOW,:Libdl,:dlext,:dlsym_e,:RTLD_FIRST,:dlopen,:dllist,:dlpath,:RTLD_NOLOAD,:dlclose,:dlopen_e,:RTLD_DEEPBIND]
    Libdl.(x)
end

# Test unsafe_convert
type A; end
x = "abc"
@test bytestring(Compat.unsafe_convert(Ptr{UInt8}, x)) == x
Compat.unsafe_convert(::Ptr{A}, x) = x
@test Compat.unsafe_convert(pointer([A()]), 1) == 1

# Test Ptr{T}(0)
@test @compat(Ptr{Int}(0)) == C_NULL

# Test Tuple{} syntax
if VERSION < v"0.4.0-dev+4319"
    @test @compat Tuple{1} == (1,)
    @test @compat Tuple{:a, :b} == (:a, :b)
    @test @compat Tuple{:a, Tuple{:b}} == (:a, (:b,))
    @test @compat Tuple{:a, Tuple{:b, :c}} == (:a, (:b, :c))
    @test @compat Tuple{Int} == (Int,)
    @test @compat Tuple{Int, Float64} == (Int, Float64)
    @test @compat Tuple{Int, Tuple{Float64}} == (Int, (Float64,))
    @test @compat Tuple{Int, Tuple{Float64, Char}} == (Int, (Float64, Char))
    @test @compat Tuple{Int, Vararg{Float64}} == (Int, Float64...)
    # Issue 81
    a81 = [Int, Int]
    b81 = (Int, Int)
    @test @compat Tuple{a81..., Vararg{Float64}} == (Int, Int, Float64...)
    @test @compat Tuple{b81..., Vararg{Float64}} == (Int, Int, Float64...)
end

# Ensure eachindex iterates over the whole array
let A, B, s
    A = reshape(1:20,4,5)
    s = 0
    for i in eachindex(A)
        s += A[i]
    end
    @test s == 210
    B = sparse(A)
    s = 0
    for i in eachindex(B)
        s += B[i]
    end
    @test s == 210
end

let
    d = @compat Dict(1=>2, 3=>4)
    d[5] = 6
    val = 0
    for I in eachindex(d)
        val += d[I]
    end
    @test val == 12
    empty!(d)
    for I in eachindex(d)
        val += d[I]
    end
    @test val == 12
end

# findlast, findprev
let a = [0,1,2,3,0,1,2,3]
    @test findlast(a) == 8
    @test findlast(a.==0) == 5
    @test findlast(a.==5) == 0
    @test findlast([1,2,4,1,2,3,4], 3) == 6
    @test findlast(isodd, [2,4,6,3,9,2,0]) == 5
    @test findlast(isodd, [2,4,6,2,0]) == 0
    @test findprev(a,4) == 4
    @test findprev(a,5) == 4
    @test findprev(a,1) == 0
    @test findprev(a,1,4) == 2
    @test findprev(a,1,8) == 6
    @test findprev(isodd, [2,4,5,3,9,2,0], 7) == 5
    @test findprev(isodd, [2,4,5,3,9,2,0], 2) == 0
end

# isdiag
@test isdiag(diagm([1,2,3,4]))
@test !isdiag([1 2; 3 4])
@test isdiag(5)

# keytype & valtype
if VERSION < v"0.4.0-dev+4502"
    @test keytype(@compat(Dict(1 => 1.))) == Int
    @test valtype(@compat(Dict(1 => 1.))) == Float64
end

# Val
begin
    local firstlast
    firstlast(::Type{Val{true}}) = "First"
    firstlast(::Type{Val{false}}) = "Last"

    @test firstlast(Val{true}) == "First"
    @test firstlast(Val{false}) == "Last"
end

# qr, qrfact, qrfact!
let A = [1.0 2.0; 3.0 4.0]
    Q, R = qr(A, Val{false})
    @test_approx_eq Q*R A
    Q, R, p = qr(A, Val{true})
    @test_approx_eq Q*R A[:,p]
    F = qrfact(A, Val{false})
    @test_approx_eq F[:Q]*F[:R] A
    F = qrfact(A, Val{true})
    @test_approx_eq F[:Q]*F[:R] A[:,F[:p]]
    A_copy = copy(A)
    F = qrfact!(A_copy, Val{false})
    @test_approx_eq F[:Q]*F[:R] A
    A_copy = copy(A)
    F = qrfact!(A_copy, Val{true})
    @test_approx_eq F[:Q]*F[:R] A[:,F[:p]]
end

# Cstring
let s = "foo", w = wstring("foo")
    @test reinterpret(Ptr{Cchar}, Compat.unsafe_convert(Cstring, s)) == pointer(s)
    @test reinterpret(Ptr{Cwchar_t}, Compat.unsafe_convert(Cwstring, w)) == pointer(w)
end

# fma and muladd
@test fma(3,4,5) == 3*4+5 == muladd(3,4,5)

# is_valid_utf32
s = utf32("abc")
@test isvalid(s)
s = utf32(UInt32[65,0x110000])
@test !isvalid(s)

# isvalid
let s = "abcdef", u8 = "abcdef\uff", u16 = utf16(u8), u32 = utf32(u8),
    bad32 = utf32(UInt32[65,0x110000]), badch = Char[0x110000][1]

    @test !isvalid(bad32)
    @test !isvalid(badch)
    @test isvalid(s)
    @test isvalid(u8)
    @test isvalid(u16)
    @test isvalid(u32)
    @test isvalid(ASCIIString, s)
    @test isvalid(UTF8String,  u8)
    @test isvalid(UTF16String, u16)
    @test isvalid(UTF32String, u32)
end

# chol
let A = rand(2,2)
    B = A'*A
    U = @compat chol(B, Val{:U})
    @test_approx_eq U'*U B
end

# @generated
if VERSION > v"0.3.99"
    let
        @compat @generated function foo(x)
            T = x
            :(return $T)
        end
        @test foo(5) == Int
    end
end

# Timer
let c = 0, f, t
    @compat f(t::Timer) = (c += 1)
    t = Timer(f, 0.0, 0.05)
    sleep(0.05)
    @test c >= 1
    sleep(0.1)
    @test c >= 3
    close(t)
    sleep(0.1)
    val = c
    sleep(0.1)
    @test val == c
end

# MathConst -> Irrational
f(::Irrational) = true
@test f(π)
Compat.@irrational mathconst_one 1.0 big(1.)
@test f(mathconst_one)

# gc_enable(::Bool)
@test gc_enable(false)
@test !gc_enable(true)

# Vector{Int}(), Array{Int}

@test @compat typeof(Vector{Int}()) == Array{Int,1}
@test @compat length(Vector{Int}()) == 0

@test @compat typeof(Vector{Int8}(10)) == Array{Int8,1}
@test @compat length(Vector{Int8}(10)) == 10

@test @compat typeof(Array{UInt16}()) == Array{UInt16,0}
@test @compat length(Array{UInt16}()) == 1

@test @compat typeof(Array{UInt16}(0)) == Array{UInt16,1}
@test @compat length(Array{UInt16}(0)) == 0

@test @compat typeof(Array{Float16}(5)) == Array{Float16,1}
@test @compat length(Array{Float16}(5)) == 5

@test @compat typeof(Array{AbstractString}(2,2)) == Array{AbstractString,2}
@test @compat size(Array{AbstractString}(2,2)) == (2,2)

@test @compat typeof(Array{Rational{Int}}(2,2,2,2,2)) == Array{Rational{Int},5}
@test @compat size(Array{Rational{Int}}(2,2,2,2,2)) == (2,2,2,2,2)

@compat utf8(Mmap.mmap(@__FILE__(),Vector{UInt8},11,1)) == "sing Compat"

@test base64encode("hello world") == "aGVsbG8gd29ybGQ="

@test nothing === __precompile__(false) # tests should never be precompiled
@test nothing === __precompile__()
@test nothing === include_dependency("foo")

@test real(Int) == real(Complex{Int}) == Int

@test isa(1.2, AbstractFloat)

@test [1,2,3] ≈ [1,2,3+1e-9]
@test [0,1] ≈ [1e-9, 1]
@test [0,1] ≉ [1e-3, 1]

# linspace (some of the julia 0.4 tests)
@test [Compat.linspace(0.1,0.3,3);]     == [1:3;]./10
@test [Compat.linspace(0.0,0.3,4);]     == [0:3;]./10
@test [Compat.linspace(0.3,-0.1,5);]    == [3:-1:-1;]./10
@test [Compat.linspace(0.1,-0.3,5);]    == [1:-1:-3;]./10
@test [Compat.linspace(0.0,1.0,11);]    == [0:10;]./10
@test [Compat.linspace(0.0,1.0,0);]     == []
@test [Compat.linspace(0.0,-1.0,0);]    == []
@test [Compat.linspace(0.0,-1.0,11);]   == [0:-1:-10;]./10
@test [Compat.linspace(1.0,27.0,1275);] == [49:1323;]./49
@test [Compat.linspace(0.0,2.1,4);]     == [0:7:21;]./10
@test [Compat.linspace(0.0,3.3,4);]     == [0:11:33;]./10
@test [Compat.linspace(0.1,3.4,4);]     == [1:11:34;]./10
@test [Compat.linspace(0.0,3.9,4);]     == [0:13:39;]./10
@test [Compat.linspace(0.1,4.0,4);]     == [1:13:40;]./10
@test [Compat.linspace(1.1,3.3,3);]     == [11:11:33;]./10
@test [Compat.linspace(0.3,1.1,9);]     == [3:1:11;]./10
@test [Compat.linspace(0.0,0.0,1);]     == [0.0]
@test [Compat.linspace(0.0,0.0,1);]     == [0.0]

for T = (Float32, Float64)
    z = zero(T)
    u = eps(z)
    @test first(Compat.linspace(u,u,0)) == u
    @test last(Compat.linspace(u,u,0)) == u
    @test first(Compat.linspace(-u,u,0)) == -u
    @test last(Compat.linspace(-u,u,0)) == u
    @test [Compat.linspace(-u,u,0);] == []
    @test [Compat.linspace(-u,-u,1);] == [-u]
    @test [Compat.linspace(-u,u,2);] == [-u,u]
    @test [Compat.linspace(-u,u,3);] == [-u,0,u]
    @test [Compat.linspace(-u,u,4);] == [-u,0,0,u]
    @test [Compat.linspace(-u,u,4);][2] === -z
    @test [Compat.linspace(-u,u,4);][3] === z
    @test first(Compat.linspace(-u,-u,0)) == -u
    @test last(Compat.linspace(-u,-u,0)) == -u
    @test first(Compat.linspace(u,-u,0)) == u
    @test last(Compat.linspace(u,-u,0)) == -u
    @test [Compat.linspace(u,-u,0);] == []
    @test [Compat.linspace(u,u,1);] == [u]
    @test [Compat.linspace(u,-u,2);] == [u,-u]
    @test [Compat.linspace(u,-u,3);] == [u,0,-u]
    @test [Compat.linspace(u,-u,4);] == [u,0,0,-u]
    @test [Compat.linspace(u,-u,4);][2] === z
    @test [Compat.linspace(u,-u,4);][3] === -z
    v = [Compat.linspace(-u,u,12);]
    @test length(v) == 12
    @test issorted(v) && unique(v) == [-u,0,0,u]
    @test [-3u:u:3u;] == [Compat.linspace(-3u,3u,7);] == [-3:3;].*u
    @test [3u:-u:-3u;] == [Compat.linspace(3u,-3u,7);] == [3:-1:-3;].*u
end

if VERSION < v"0.4.0-dev+768"
    @test @compat(Void) === Nothing
else
    @test @compat(Void) === Void
end
@test Ptr{Void} == @compat(Ptr{Void})

# MemoryError -> OutOfMemoryError
# Base64Pipe -> Base64EncodePipe
# UdpSocket -> UDPSocket
f141(::Type{OutOfMemoryError}) = true
f141(::Type{Base64EncodePipe}) = true
f141(::Type{UDPSocket}) = true
f141(::Type{TCPSocket}) = true

@test f141(OutOfMemoryError)
@test f141(Base64EncodePipe)
@test f141(UDPSocket)
@test f141(TCPSocket)

# Union syntax
if VERSION < v"0.4.0-dev+5379"
    @test @compat(Union{}) == None
    @test @compat(Union{Int,Float64}) == Union(Int,Float64)
    @test @compat(:(Union{})) == :(Union())
end

@test fetch(remotecall(() -> true, 1))
@test remotecall_fetch(() -> true, 1)
@test fetch(remotecall_wait(() -> true, 1))
Base.remote_do(() -> true, 1) # Doesn't return anything so cannot be `@test`ed but should print some output if it fails

# JuliaLang/julia#13440
@test isa(SparseArrays, Module)

# JuliaLang/julia#12819
@test Compat.Filesystem.JL_O_RDWR == Compat.Filesystem.JL_O_RDWR

# JuliaLang/julia#14338
@test supertype(Int) == Signed

# withenv
@test "1234" == @compat withenv(() -> ENV["_TESTVAR"], "_TESTVAR" => 1234)
@test "1234" == @compat withenv("_TESTVAR" => 1234) do
    return ENV["_TESTVAR"]
end

# Test functional form of mktemp and mktempdir
let
    tmp_path = mktemp() do p, io
        @test isfile(p)
        print(io, "鴨かも？")
        p
    end
    @test tmp_path != ""
    @test !isfile(tmp_path)
end

let
    tmpdir = mktempdir() do d
        @test isdir(d)
        d
    end
    @test tmpdir != ""
    @test !isdir(tmpdir)
end

# https://github.com/JuliaLang/julia/pull/14660
mktempdir() do dir

    verbose = false

    # Create test file...
    filename = joinpath(dir, "file.txt")
    text = "C1,C2\n1,2\na,b\n"

    # List of IO producers...
    l = [
        ("IOStream", (text) -> begin
            write(filename, text)
            open(filename)
        end),
        ("IOBuffer", (text)->IOBuffer(text))
    ]

    open_streams = Any[]
    function cleanup()
        for s in open_streams
            try close(s) end
        end
    end

    for (name, f) in l

        io = ()->(s=f(text); push!(open_streams, s); s)

        write(filename, text)

        verbose && println("$name read...")
        @test read(io(), UInt8) == read(IOBuffer(text), UInt8)
        @test read(io(), UInt8) == read(filename, UInt8)
        @test read(io(), Int) == read(IOBuffer(text), Int)
        @test read(io(), Int) == read(filename,Int)
        s1 = io()
        s2 = IOBuffer(text)
        @test read(s1, UInt32, 2) == read(s2, UInt32, 2)
        @test !eof(s1)
        @test read(s1, UInt8, 5) == read(s2, UInt8, 5)
        @test !eof(s1)
        @test read(s1, UInt8, 1) == read(s2, UInt8, 1)
        @test eof(s1)
        @test_throws EOFError read(s1, UInt8)
        @test eof(s1)
        close(s1)
        close(s2)

        verbose && println("$name eof...")
        n = length(text) - 1
        @test @compat read!(io(), Vector{UInt8}(n)) ==
              read!(IOBuffer(text), Vector{UInt8}(n))
        @test @compat (s = io(); read!(s, Vector{UInt8}(n)); !eof(s))
        n = length(text)
        @test @compat read!(io(), Vector{UInt8}(n)) ==
              read!(IOBuffer(text), Vector{UInt8}(n))
        @test @compat (s = io(); read!(s, Vector{UInt8}(n)); eof(s))
        n = length(text) + 1
        @test_throws EOFError @compat read!(io(), Vector{UInt8}(n))
        @test_throws EOFError @compat read!(io(), Vector{UInt8}(n))

        old_text = text
        cleanup()
        const SZ_UNBUFFERED_IO = 65536

        for text in [
            old_text,
            convert(UTF8String, Char['A' + i % 52 for i in 1:(div(SZ_UNBUFFERED_IO,2))]),
            convert(UTF8String, Char['A' + i % 52 for i in 1:(    SZ_UNBUFFERED_IO -1)]),
            convert(UTF8String, Char['A' + i % 52 for i in 1:(    SZ_UNBUFFERED_IO   )]),
            convert(UTF8String, Char['A' + i % 52 for i in 1:(    SZ_UNBUFFERED_IO +1)])
        ]

            write(filename, text)

            verbose && println("$name readstring...")
            @test readstring(io()) == text

            @test readstring(io()) == readstring(filename)


            verbose && println("$name read...")
            @test @compat read(io()) == UInt8[convert(UInt8, _) for _ in text]

            @test read(io()) == read(filename)

            cleanup()


            verbose && println("$name readbytes!...")
            l = length(text)
            for n = [1, 2, l-2, l-1, l, l+1, l+2]
                @compat a1 = Vector{UInt8}(n);
                @compat a2 = Vector{UInt8}(n)
                s1 = io()
                s2 = IOBuffer(text)
                n1 = readbytes!(s1, a1)
                n2 = readbytes!(s2, a2)
                @test n1 == n2
                @test length(a1) == length(a2)
                @test a1[1:n1] == a2[1:n2]
                @test n <= length(text) || eof(s1)
                @test n <= length(text) || eof(s2)

                cleanup()
            end

            verbose && println("$name read!...")
            l = length(text)
            for n = [1, 2, l-2, l-1, l]
                @test @compat  read!(io(), Vector{UInt8}(n)) ==
                      read!(IOBuffer(text), Vector{UInt8}(n))
                @test @compat read!(io(), Vector{UInt8}(n)) ==
                      read!(filename, Vector{UInt8}(n))

                cleanup()
            end
            @test_throws EOFError @compat read!(io(), Vector{UInt8}(length(text)+1))


            verbose && println("$name readuntil...")
            @test readuntil(io(), '\n') == readuntil(IOBuffer(text),'\n')
            @test readuntil(io(), '\n') == readuntil(filename,'\n')
            @test readuntil(io(), "\n") == readuntil(IOBuffer(text),"\n")
            @test readuntil(io(), "\n") == readuntil(filename,"\n")
            @test readuntil(io(), ',')  == readuntil(IOBuffer(text),',')
            @test readuntil(io(), ',')  == readuntil(filename,',')

            cleanup()

            verbose && println("$name readline...")
            @test readline(io()) == readline(IOBuffer(text))
            @test readline(io()) == readline(filename)

            verbose && println("$name readlines...")
            @test readlines(io()) == readlines(IOBuffer(text))
            @test readlines(io()) == readlines(filename)
            @test collect(eachline(io())) == collect(eachline(IOBuffer(text)))
            @test collect(eachline(io())) == collect(eachline(filename))

            cleanup()

            verbose && println("$name countlines...")
            @test countlines(io()) == countlines(IOBuffer(text))

            # verbose && println("$name readcsv...")
            # @test readcsv(io()) == readcsv(IOBuffer(text))
            # @test readcsv(io()) == readcsv(filename)

            cleanup()
        end

        text = old_text
        write(filename, text)

        verbose && println("$name position...")
        @test @compat (s = io(); read!(s, Vector{UInt8}(4)); position(s))  == 4

        verbose && println("$name seek...")
        for n = 0:length(text)-1
            @test readlines(seek(io(), n)) == readlines(seek(IOBuffer(text), n))
            cleanup()
        end
        verbose && println("$name skip...")
        for n = 0:length(text)-1
            @test readlines(seek(io(), n)) == readlines(seek(IOBuffer(text), n))
            @test readlines(skip(io(), n)) == readlines(skip(IOBuffer(text), n))
            cleanup()
        end
        verbose && println("$name seekend...")
        @test readstring(seekend(io())) == ""

        verbose && println("$name write(::IOStream, ...)")
        to = open("$filename.to", "w")
        write(to, io())
        close(to)
        @test readstring("$filename.to") == text

        verbose && println("$name write(filename, ...)")
        write("$filename.to", io())
        @test readstring("$filename.to") == text

        verbose && println("$name write(::IOBuffer, ...)")
        @compat to = IOBuffer(UInt8[convert(UInt8, _) for _ in text], false, true)
        write(to, io())
        @test takebuf_string(to) == text

        cleanup()
    end


# https://github.com/JuliaLang/julia/pull/13232

setprecision(BigFloat, 100)
@test precision(BigFloat) == 100
setprecision(256)
@test precision(BigFloat) == 256

setprecision(BigFloat, 100) do
    a = big(pi)
    @test precision(a) == 100
end

setprecision(130) do
    a = big(pi)
    @test precision(a) == 130
end

for T in (BigFloat, Float64)
    setrounding(T, RoundDown)
    @test rounding(T) == RoundDown

    setrounding(T, RoundUp) do
        @test rounding(T) == RoundUp
    end
end

end

@test typeof(displaysize()) == @compat(Tuple{Int, Int})

@test Compat.LinAlg.checksquare(randn(4,4)) == 4
@test Compat.LinAlg.checksquare(randn(4,4), randn(3,3)) == [4,3]
@test_throws DimensionMismatch Compat.LinAlg.checksquare(randn(4,3))
