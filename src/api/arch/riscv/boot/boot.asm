.section ".text.boot"
/**
 * Author: initkfs
 */

.macro context_save base
.ifdef rv32
    sw ra, 0(\base)      # 0
    sw sp, 4(\base)      # 4
    sw gp, 8(\base)      # 8
    sw tp, 12(\base)     # 12
    
    sw s0, 16(\base)     # 16
    sw s1, 20(\base)     # 20
    sw s2, 24(\base)     # 24
    sw s3, 28(\base)     # 28
    sw s4, 32(\base)     # 32
    sw s5, 36(\base)     # 36
    sw s6, 40(\base)     # 40
    sw s7, 44(\base)     # 44
    sw s8, 48(\base)     # 48
    sw s9, 52(\base)     # 52
    sw s10, 56(\base)    # 56
    sw s11, 60(\base)    # 60
.elseif rv64
    sd ra, 0(\base)      # 0
    sd sp, 8(\base)      # 8
    sd gp, 16(\base)     # 16
    sd tp, 24(\base)     # 24
    
    sd s0, 32(\base)     # 32
    sd s1, 40(\base)     # 40
    sd s2, 48(\base)     # 48
    sd s3, 56(\base)     # 56
    sd s4, 64(\base)     # 64
    sd s5, 72(\base)     # 72
    sd s6, 80(\base)     # 80
    sd s7, 88(\base)     # 88
    sd s8, 96(\base)     # 96
    sd s9, 104(\base)    # 104
    sd s10, 112(\base)   # 112
    sd s11, 120(\base)   # 120
.endif  
.endm

.macro context_load base
.ifdef rv32
    lw ra, 0(\base)      # 0
    lw sp, 4(\base)      # 4
    lw gp, 8(\base)      # 8
    lw tp, 12(\base)     # 12
    
    lw s0, 16(\base)     # 16
    lw s1, 20(\base)     # 20
    lw s2, 24(\base)     # 24
    lw s3, 28(\base)     # 28
    lw s4, 32(\base)     # 32
    lw s5, 36(\base)     # 36
    lw s6, 40(\base)     # 40
    lw s7, 44(\base)     # 44
    lw s8, 48(\base)     # 48
    lw s9, 52(\base)     # 52
    lw s10, 56(\base)    # 56
    lw s11, 60(\base)    # 60
.elseif rv64
    ld ra, 0(\base)      # 0
    ld sp, 8(\base)      # 8
    ld gp, 16(\base)     # 16
    ld tp, 24(\base)     # 24
    
    ld s0, 32(\base)     # 32
    ld s1, 40(\base)     # 40
    ld s2, 48(\base)     # 48
    ld s3, 56(\base)     # 56
    ld s4, 64(\base)     # 64
    ld s5, 72(\base)     # 72
    ld s6, 80(\base)     # 80
    ld s7, 88(\base)     # 88
    ld s8, 96(\base)     # 96
    ld s9, 104(\base)    # 104
    ld s10, 112(\base)   # 112
    ld s11, 120(\base)   # 120
.endif
.endm

.macro fpu_save_32 base
    fsw f0,  0(\base)
    fsw f1,  4(\base)
    fsw f2,  8(\base)
    fsw f3,  12(\base)
    fsw f4,  16(\base)
    fsw f5,  20(\base)
    fsw f6,  24(\base)
    fsw f7,  28(\base)
    fsw f8,  32(\base)
    fsw f9,  36(\base)
    fsw f10, 40(\base)
    fsw f11, 44(\base)
    fsw f12, 48(\base)
    fsw f13, 52(\base)
    fsw f14, 56(\base)
    fsw f15, 60(\base)
    fsw f16, 64(\base)
    fsw f17, 68(\base)
    fsw f18, 72(\base)
    fsw f19, 76(\base)
    fsw f20, 80(\base)
    fsw f21, 84(\base)
    fsw f22, 88(\base)
    fsw f23, 92(\base)
    fsw f24, 96(\base)
    fsw f25, 100(\base)
    fsw f26, 104(\base)
    fsw f27, 108(\base)
    fsw f28, 112(\base)
    fsw f29, 116(\base)
    fsw f30, 120(\base)
    fsw f31, 124(\base)
.endm

.macro fpu_save_64 base
    fsd f0,  0(\base)
    fsd f1,  8(\base)
    fsd f2,  16(\base)
    fsd f3,  24(\base)
    fsd f4,  32(\base)
    fsd f5,  40(\base)
    fsd f6,  48(\base)
    fsd f7,  56(\base)
    fsd f8,  64(\base)
    fsd f9,  72(\base)
    fsd f10, 80(\base)
    fsd f11, 88(\base)
    fsd f12, 96(\base)
    fsd f13, 104(\base)
    fsd f14, 112(\base)
    fsd f15, 120(\base)
    fsd f16, 128(\base)
    fsd f17, 136(\base)
    fsd f18, 144(\base)
    fsd f19, 152(\base)
    fsd f20, 160(\base)
    fsd f21, 168(\base)
    fsd f22, 176(\base)
    fsd f23, 184(\base)
    fsd f24, 192(\base)
    fsd f25, 200(\base)
    fsd f26, 208(\base)
    fsd f27, 216(\base)
    fsd f28, 224(\base)
    fsd f29, 232(\base)
    fsd f30, 240(\base)
    fsd f31, 248(\base)
.endm


.globl context_switch
context_switch:
    context_save a0  # a0 old context ptr
    context_load a1  # a1 new context ptr
    ret

.globl context_save_task
context_save_task:
    context_save a0
    ret

.globl context_load_task
context_load_task:
    context_load a0
    ret

.globl trap_vector
.align(16)
trap_vector:
   
    addi sp, sp, -16
    sw t0, 0(sp)
    sw t1, 4(sp)

trap_check_cause:
    csrr t0, mcause
    bge t0, zero, trap_vector_start

    li t1, 0x7FFFFFFF
    and t0, t0, t1

    li t1, 7                        # timer
    bne t0, t1, trap_vector_start

trap_save_context:
    la t0, currentTask
    lw t0, 0(t0)
    beqz t0, trap_vector_start

    la t1, osTask
    beq t0, t1, trap_vector_start

    sw ra, 0(t0)       # 0
    
    addi t1, sp, 16
    sw t1, 4(t0)
    #sw sp, 4(t0)      # 4  
    
    sw gp, 8(t0)       # 8
    sw tp, 12(t0)      # 12

    sw s0, 16(t0)      # 16
    sw s1, 20(t0)      # 20  
    sw s2, 24(t0)      # 24
    sw s3, 28(t0)      # 28
    sw s4, 32(t0)      # 32
    sw s5, 36(t0)      # 36
    sw s6, 40(t0)      # 40
    sw s7, 44(t0)      # 44
    sw s8, 48(t0)      # 48
    sw s9, 52(t0)      # 52
    sw s10, 56(t0)     # 56
    sw s11, 60(t0)     # 60
    
    sw a0, 64(t0)      # 64
    sw a1, 68(t0)      # 68
    sw a2, 72(t0)      # 72
    sw a3, 76(t0)      # 76
    sw a4, 80(t0)      # 80
    sw a5, 84(t0)      # 84
    sw a6, 88(t0)      # 88
    sw a7, 92(t0)      # 92

    lw t1, 0(sp)       # Restore t0
    sw t1, 96(t0)      # save t0
    #sw t0, 96(t0)     # 16

    lw t1, 4(sp)        # Restore t1 
    sw t1, 100(t0)      # 20 - save t1
    #sw t1, 100(t0)     # 20
    
    sw t2, 104(t0)     # 104
    sw t3, 108(t0)     # 108
    sw t4, 112(t0)     # 112
    sw t5, 116(t0)     # 116
    sw t6, 120(t0)     # 120

    csrr t1, mepc
    sw t1, 124(t0)  # 124

 trap_vector_start:  

    lw t1, 4(sp) 
    lw t0, 0(sp)
    addi sp, sp, 16

.ifdef rv32
    #addi sp, sp, -120
    addi sp, sp, -128
.elseif rv64
    addi sp, sp, -240
.endif
	csrr	a0, mepc
	csrr	a1, mcause
    csrr    a2, mtval
	call	trap_handler #from kernel
	csrw	mepc, a0
.ifdef rv32
    addi sp, sp, 128
.elseif rv64
    addi sp, sp, 240
.endif
    
    la t0, currentTask
    lw t0, 0(t0)
    beqz t0, trap_vector_ret

    lw t1, 124(t0)     # 124 - mepc
    csrw mepc, t1

    lw s0, 16(t0)      # 16
    lw s1, 20(t0)      # 20
    lw s2, 24(t0)      # 24
    lw s3, 28(t0)      # 28
    lw s4, 32(t0)      # 32
    lw s5, 36(t0)      # 36
    lw s6, 40(t0)      # 40
    lw s7, 44(t0)      # 44
    lw s8, 48(t0)      # 48
    lw s9, 52(t0)      # 52
    lw s10, 56(t0)     # 56
    lw s11, 60(t0)     # 60
    
    lw a0, 64(t0)      # 64
    lw a1, 68(t0)      # 68
    lw a2, 72(t0)      # 72
    lw a3, 76(t0)      # 76
    lw a4, 80(t0)      # 80
    lw a5, 84(t0)      # 84
    lw a6, 88(t0)      # 88
    lw a7, 92(t0)      # 92
    
    lw t1, 100(t0)     # 100
    lw t2, 104(t0)     # 104
    lw t3, 108(t0)     # 108
    lw t4, 112(t0)     # 112
    lw t5, 116(t0)     # 116
    lw t6, 120(t0)     # 120
    
    lw ra, 0(t0)       # 0
    lw sp, 4(t0)       # 4
    lw gp, 8(t0)       # 8
    lw tp, 12(t0)      # 12
    
    lw t0, 96(t0)      # 96, destroy context pointer
    
    #csrci mstatus, 0x8    # MIE = 0
    #csrci mstatus, 0x80   # MPIE = 0
trap_vector_ret:
	mret
