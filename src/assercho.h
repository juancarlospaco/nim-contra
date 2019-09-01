#undef __format
#undef __print_arg
#undef __nargs_0
#undef __nargs_1
#undef __eval_0
#undef __eval_1
#undef __eval_2
#undef __print_0
#undef __print_1
#undef __print_2
#undef __print_3
#undef __arg_1
#undef __arg_2
#undef __loop
#undef __loop_helper
#undef __empty_helper
#undef __print_info
#undef __custom_idebug
#undef __idebug_P_1
#undef __idebug_P_2
#undef __idebug_0
#undef __idebug_1
#undef __idebug_arg_1
#undef __idebug_arg_2
#undef internalAssercho

#ifdef NDEBUG
  #define internalAssercho(...) ((void)0) // internalAssercho()
#else
  #if !defined(_STDIO_H_) && !defined(_STDIO_H)
    int printf(const char *restrict format, ...);  // printf()
  #endif
  #define __format(arg) _Generic((arg), char: "%c", signed char: "%hhd", unsigned char: "%hhu", signed short: "%hd", unsigned short: "%hu", signed int: "%d", unsigned int: "%u", long int: "%ld", unsigned long int: "%lu", long long int: "%lld", unsigned long long int: "%llu", _Bool: "%d", float: "%g", double: "%g", long double: "%Lg",  _Complex double: "%g + %gi", char *: "%s", void *: "%p", char[sizeof(arg)]: "%s", default: "<unknown>")
  #define __print_arg(arg) printf(__format(arg), arg)
  #define __nargs_0(...) __nargs_1(__VA_ARGS__, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 0)
  #define __nargs_1(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, ...) q
  #define __eval_0(...) __eval_1(__eval_1(__eval_1(__eval_1(__VA_ARGS__))))
  #define __eval_1(...) __eval_2(__eval_2(__eval_2(__eval_2(__VA_ARGS__))))
  #define __eval_2(...) __VA_ARGS__
  #define __print_0(...) __eval_0(__print_1(__VA_ARGS__))
  #define __print_1(P, ...) __print_2(__nargs_0(__VA_ARGS__), P, __VA_ARGS__)
  #define __print_2(num, ...) __print_3(num, __VA_ARGS__)
  #define __print_3(num, ...) __arg_ ## num (__VA_ARGS__)
  #define __arg_1(P, arg) P ## 1(arg)
  #define __arg_2(P, arg, ...) P ## 2(arg), __loop(P, __VA_ARGS__)
  #define __loop(...) __loop_helper __empty_helper() () (__VA_ARGS__)
  #define __loop_helper() __print_1
  #define __empty_helper()
  #define __print_info(sep) printf("--> %s(%d)\n", __FILE__, __LINE__, sep)
  #define __custom_debug(P, ...) (__print_0(P, __VA_ARGS__), printf(" "))
  #define __custom_idebug(P, sep, ...) (__custom_debug(P, __VA_ARGS__), __print_info(sep))
  #define __debug_P_1(arg) printf("C\t%s = ", #arg), __print_arg(arg)
  #define __debug_P_2(arg) __debug_P_1(arg), printf("\n")
  #define __idebug_P_1(arg) printf("\t%s = ", #arg), __print_arg(arg)
  #define __idebug_P_2(arg) __idebug_P_1(arg), printf("\n")
  #define internalAssercho(...) __idebug_0(__nargs_0(__VA_ARGS__), __VA_ARGS__) // internalAssercho()
  #define __idebug_0(num, ...) __idebug_1(num, __VA_ARGS__)
  #define __idebug_1(num, ...) __idebug_arg_ ## num (__VA_ARGS__)
  #define __idebug_arg_1(...) __custom_idebug(__debug_P_, " ", __VA_ARGS__)
  #define __idebug_arg_2(...) __custom_idebug(__idebug_P_, "\n", __VA_ARGS__)
#endif
