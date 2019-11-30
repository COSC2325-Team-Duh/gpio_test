.global main
.type main, %function

main:
    sub     sp, sp, #16
    str     r5, [sp, #0]
    str     r6, [sp, #4]
    str     lr, [sp, #8]
    str     fp, [sp, #12]
    add     fp, sp, #16

// get the memory address
    bl      getMemAddr
    mov     r1, r0
    mov     r5, r0
    ldr     r0, =msg
    bl      printf

// clean up and exit
    ldr     r5, [sp, #0]
    ldr     r6, [sp, #4]
    ldr     lr, [sp, #8]
    ldr     fp, [sp, #12]
    add     sp, sp, #16
    mov     r0, #0
    bx      lr

.data
msg:
    .asciz "r0 is %p\n"
