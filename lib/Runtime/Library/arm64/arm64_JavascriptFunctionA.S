//-------------------------------------------------------------------------------------------------------
// Copyright (C) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
//-------------------------------------------------------------------------------------------------------

//Var arm64_CallFunction(JavascriptFunction* function, CallInfo info, uint argCount, Var* values, JavascriptMethod entryPoint)
//
//   This method should be called as follows
//       varResult = arm64_CallFunction((JavascriptFunction*)function, args.Info, argCount, args.Values, entryPoint)//
//
//   and makes the following call
//           return entryPoint(function, info, values[0], values[1], ..., values[n-2], values[n-1])//
//   where n = info.Count >= 6 (so we know we'll need to pass 6 values in registers).
//
//   ARM64 calling convention is:
//       x0        parameter 1 = function
//       x1        parameter 2 = info
//       x2        values[0]
//       x3        values[1]
//       x4        values[2]
//       x5        values[3]
//       x6        values[4]
//       x7        values[5]
//       [sp+0]    values[6]
//       [sp+8]    values[7]
//       ...
//
//       (8 bytes) return values are passed in x0.
//
//   Since the 1st two parameters are the same for this method and the entry point, we don't need to touch them.
//

#include "unixasmmacros.inc"

.global C_FUNC(_ZN2Js18JavascriptFunction24DeferredDeserializeThunkEPNS_16RecyclableObjectENS_8CallInfoEz)
.global C_FUNC(_ZN2Js18JavascriptFunction20DeferredParsingThunkEPNS_16RecyclableObjectENS_8CallInfoEz)
.global C_FUNC(arm64_CallFunction)
.global C_FUNC(arm64_CallEhFrame)
.global C_FUNC(arm64_CallCatch)


    NESTED_ENTRY _ZN2Js18JavascriptFunction24DeferredDeserializeThunkEPNS_16RecyclableObjectENS_8CallInfoEz, _TEXT, NoHandler

    sub     fp, lr, #80
    PROLOG_SAVE_REG_PAIR fp, lr, 0              // save parameter registers

    stp     x0, x1, [sp, #16]
    stp     x2, x3, [sp, #32]
    stp     x4, x5, [sp, #48]
    stp     x6, x7, [sp, #64]

    bl      _ZN2Js18JavascriptFunction19DeferredDeserializeEPNS_14ScriptFunctionE
    mov     x16, x0                             // back up entryPoint in x16

    ldp     x6, x7, [sp, #64]
    ldp     x4, x5, [sp, #48]
    ldp     x2, x3, [sp, #32]
    ldp     x0, x1, [sp, #16]

    EPILOG_RESTORE_REG_PAIR fp, lr, 0
    add     sp, sp, #80

    br x16                           // tail call to new entryPoint

    NESTED_END _ZN2Js18JavascriptFunction24DeferredDeserializeThunkEPNS_16RecyclableObjectENS_8CallInfoEz, _TEXT


    NESTED_ENTRY _ZN2Js18JavascriptFunction20DeferredParsingThunkEPNS_16RecyclableObjectENS_8CallInfoEz, _TEXT, NoHandler

    sub     sp, sp, #80
    PROLOG_SAVE_REG_PAIR fp, lr, 0

    stp     x0, x1, [sp, #16]
    stp     x2, x3, [sp, #32]
    stp     x4, x5, [sp, #48]
    stp     x6, x7, [sp, #64]

    mov     x0, sp                              // pass the address of the function at the saved x0
    add     x0, x0, #16                         // 16 is subtracted from the stack pointer when the a function is called, add it back here
    bl      _ZN2Js18JavascriptFunction13DeferredParseEPPNS_14ScriptFunctionE
    mov     x16, x0                             // back up entryPoint in x16

    ldp     x6, x7, [sp, #64]
    ldp     x4, x5, [sp, #48]
    ldp     x2, x3, [sp, #32]
    ldp     x0, x1, [sp, #16]

    EPILOG_RESTORE_REG_PAIR fp, lr, 0
    add     sp, sp, #80

    br x16                           // tail call to new entryPoint

    NESTED_END _ZN2Js18JavascriptFunction20DeferredParsingThunkEPNS_16RecyclableObjectENS_8CallInfoEz, _TEXT


    NESTED_ENTRY arm64_CallFunction, _TEXT, NoHandler

    sub     sp, sp, #16
    PROLOG_SAVE_REG_PAIR fp, lr, 0              // save fp/lr (implicitly saves SP in FP)

    mov     x8, x4                              // copy entry point to x8
    mov     x9, x3                              // copy values pointer to x9

#if _CONTROL_FLOW_GUARD
    mov     x15, x4                             // __guard_check_icall_fptr requires the call target in x15
    adrp    x16, __guard_check_icall_fptr       //
    ldr     x16, [x16, __guard_check_icall_fptr]// fetch address of guard check handler
    blr     x16                                 // call it
#endif

    subs    x5, x2, #6                          // more than 6 parameters?
    bgt     LOCAL_LABEL(StackAlloc)             // if so, allocate necessary stack

    adr     x5, LOCAL_LABEL(CopyZero)           // get bottom of parameter copy loop
    sub     x5, x5, x2, lsl #2                  // compute address of where to start
    br      x5                                  // branch there
LOCAL_LABEL(CopyAll):
    ldr     x7, [x9, #40]                       // load remaining 6 registers here
    ldr     x6, [x9, #32]                       //
    ldr     x5, [x9, #24]                       //
    ldr     x4, [x9, #16]                       //
    ldr     x3, [x9, #8]                        //
    ldr     x2, [x9, #0]                        //
LOCAL_LABEL(CopyZero):
    stp     x0, x1, [sp, #-64]!                 // put register parameters to stack
    stp     x2, x3, [sp, #16]
    stp     x4, x5, [sp, #32]
    stp     x6, x7, [sp, #48]
    blr     x8                                  // call saved entry point

    mov     sp, fp                              // explicitly restore sp
    EPILOG_RESTORE_REG_PAIR fp, lr, 0           // restore fp/lr
    add     sp, sp, #16
    EPILOG_RETURN                               // return

LOCAL_LABEL(StackAlloc):
    add     x15, x5, #1                         // round (param_count - 6) up by 1
    lsr     x15, x15, #1                        // divide by 2
    //bl      __chkstk                            // ensure stack is allocated
    sub     sp, sp, x15, lsl #4                 // then allocate the space
    // add     x3, x3, #48                         // use x3 = source
    add     x3, x3, #48                         // use x3 = source
    mov     x4, sp                              // use x4 = dest
LOCAL_LABEL(CopyLoop):
    subs    x5, x5, #1                          // decrement param count by 1
    ldr     x7, [x3], #8                        // read param from source
    str     x7, [x4], #8                        // store param to dest
    bne     LOCAL_LABEL(CopyLoop)               // loop until all copied
    b       LOCAL_LABEL(CopyAll)                // jump ahead to copy all 6 remaining parameters

    NESTED_END arm64_CallFunction, _TEXT

    NESTED_ENTRY BreakSpeculation, _TEXT, NoHandler
    cmp x0, x0
    csel x0, x0, x0, eq
    ret
    NESTED_END BreakSpeculation, _TEXT


    NESTED_ENTRY arm64_CallEhFrame, _TEXT, NoHandler

    // setup the locals pointer and frame pointer
    mov    x28, x2
    mov    fp, x1

    // thunk to the jitted code (and don't return)
    br     x0

    NESTED_END arm64_CallEhFrame, _TEXT


    NESTED_ENTRY arm64_CallCatch, _TEXT, NoHandler

    // params
    // x0 -- thunk target
    // x1 -- frame pointer
    // x2 -- locals pointer
    // x3 -- size of stacks args area
    // x4 -- exception object

    // setup the locals pointer and frame pointer and catch object handler
    mov    x28, x2
    mov    fp, x1
    mov    x1, x4

    // thunk to the jitted code (and don't return)
    br     x0

    NESTED_END arm64_CallCatch, _TEXT

