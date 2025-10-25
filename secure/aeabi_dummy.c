/*
 * This file provides a dummy implementation for the C++ exception handling
 * personality routine. This is needed to resolve a linker error when
 * building with -nostdlib, as some parts of libgcc may still reference it.
 * This dummy implementation does nothing and allows the linker to succeed.
 * The 'weak' attribute allows it to be overridden if a real implementation
 * is ever linked.
 */
__attribute__((weak))
void __aeabi_unwind_cpp_pr0(void)
{
    // This function should not be called in this application.
    // If it is, it's an indication of an unexpected exception path.
    while(1);
}