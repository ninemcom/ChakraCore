// -------------------------------------------------------------------------------------------------------
// Copyright (C) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
// -------------------------------------------------------------------------------------------------------

#include "unixasmmacros.inc"

.global C_FUNC(_ZN2Js13ScriptContext31ProfileModeDeferredParsingThunkEPNS_16RecyclableObjectENS_8CallInfoEz)
.global C_FUNC(_ZN2Js13ScriptContext35ProfileModeDeferredDeserializeThunkEPNS_16RecyclableObjectENS_8CallInfoEz)

NESTED_ENTRY _ZN2Js13ScriptContext31ProfileModeDeferredParsingThunkEPNS_16RecyclableObjectENS_8CallInfoEz, _TEXT, NoHandler

    mov  x28, sp
    sub  sp, x28, #80                 // allocate stack for push registers
    stp  x6, x7,  [x28, #-16]!
    stp  x4, x5,  [x28, #-16]!
    stp  x2, x3,  [x28, #-16]!
    stp  x0, x1,  [x28, #-16]!
    stp  lr, x11, [x28, #-16]!         // save volatile registers

    mov  x0, sp                       // Pass the address of the function at the saved r0 in case it need to be boxed
    bl   C_FUNC(_ZN2Js13ScriptContext24ProfileModeDeferredParseEPPNS_14ScriptFunctionE)
    mov  x16, x0                      // back up entry point

    ldp  lr, x11, [x28], #16          // pop registers
    ldp  x0, x1,  [x28], #16
    ldp  x2, x3,  [x28], #16
    ldp  x4, x5,  [x28], #16
    ldp  x6, x7,  [x28], #16
    mov  sp, x28

    br   x16                          // jump (tail call) to new entryPoint

NESTED_END _ZN2Js13ScriptContext31ProfileModeDeferredParsingThunkEPNS_16RecyclableObjectENS_8CallInfoEz, _TEXT

NESTED_ENTRY _ZN2Js13ScriptContext35ProfileModeDeferredDeserializeThunkEPNS_16RecyclableObjectENS_8CallInfoEz, _TEXT, NoHandler
    mov  x28, sp
    sub  sp, x28, #80                 // allocate stack for push registers
    stp  x6, x7,  [x28, #-16]!
    stp  x4, x5,  [x28, #-16]!
    stp  x2, x3,  [x28, #-16]!
    stp  x0, x1,  [x28, #-16]!
    stp  lr, x11, [x28, #-16]!         // save volatile registers


    bl C_FUNC(_ZN2Js13ScriptContext30ProfileModeDeferredDeserializeEPNS_14ScriptFunctionE)
    mov  x16, x0                      // backup entry point

    ldp  lr, x11, [x28], #16          // pop registers
    ldp  x0, x1,  [x28], #16
    ldp  x2, x3,  [x28], #16
    ldp  x4, x5,  [x28], #16
    ldp  x6, x7,  [x28], #16
    mov  sp, x28

    br   x16                          // jump (tail call) to new entryPoint
NESTED_END _ZN2Js13ScriptContext35ProfileModeDeferredDeserializeThunkEPNS_16RecyclableObjectENS_8CallInfoEz, _TEXT

