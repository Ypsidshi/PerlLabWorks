#!/usr/bin/env escript
main([A]) ->
    N = list_to_integer(A),
    F = fib(N),
    io:format("fibonacci ~w = ~w~n", [N, F]).

fib(0) -> 0;
fib(1) -> 1;
fib(N) when N > 1 ->
    fib(N - 1) + fib(N - 2).
