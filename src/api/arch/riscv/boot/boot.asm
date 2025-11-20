.section ".text.boot"
/**
 * Author: initkfs
 */
.globl _start
_start:
    csrr a0, mhartid
    bnez a0, _hlt
    la t0, _interrupt_stack_top
    csrw mscratch, t0

    la sp, _stack_start
    call dstart
_hlt:
    wfi
    j _hlt

# .macro reg_save base
# .set offset, 0
# .rept 32
#     sd x\offset, (\base + offset * 8)(x0)
#     .set offset, offset + 1
# .endr
# .endm

.macro context_save base
.ifdef rv32
    sw ra, 0(\base)
    sw sp, 4(\base)
    sw s0, 8(\base)
    sw s1, 12(\base)
    sw s2, 16(\base)
    sw s3, 20(\base)
    sw s4, 24(\base)
    sw s5, 28(\base)
    sw s6, 32(\base)
    sw s7, 36(\base)
    sw s8, 40(\base)
    sw s9, 44(\base)
    sw s10, 48(\base)
    sw s11, 52(\base)    
.elseif rv64
    sd ra, 0(\base)
    sd sp, 8(\base)
    sd s0, 16(\base)
    sd s1, 24(\base)
    sd s2, 32(\base)
    sd s3, 40(\base)
    sd s4, 48(\base)
    sd s5, 56(\base)
    sd s6, 64(\base)
    sd s7, 72(\base)
    sd s8, 80(\base)
    sd s9, 88(\base)
    sd s10, 96(\base)
    sd s11, 104(\base)
.endif  
.endm

.macro context_load base
.ifdef rv32
    lw ra, 0(\base)
    lw sp, 4(\base)
    lw s0, 8(\base)
    lw s1, 12(\base)
    lw s2, 16(\base)
    lw s3, 20(\base)
    lw s4, 24(\base)
    lw s5, 28(\base)
    lw s6, 32(\base)
    lw s7, 36(\base)
    lw s8, 40(\base)
    lw s9, 44(\base)
    lw s10, 48(\base)
    lw s11, 52(\base)
.elseif rv64
    ld ra, 0(\base)
    ld sp, 8(\base)
    ld s0, 16(\base)
    ld s1, 24(\base)
    ld s2, 32(\base)
    ld s3, 40(\base)
    ld s4, 48(\base)
    ld s5, 56(\base)
    ld s6, 64(\base)
    ld s7, 72(\base)
    ld s8, 80(\base)
    ld s9, 88(\base)
    ld s10, 96(\base)
    ld s11, 104(\base)
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

.macro reg_save base
.ifdef rv32
    sw ra, 0(\base)
    sw sp, 4(\base)
    sw gp, 8(\base)
    sw tp, 12(\base)
    sw t0, 16(\base)
    sw t1, 20(\base)
    sw t2, 24(\base)
    sw s0, 28(\base)
    sw s1, 32(\base)
    sw a0, 36(\base)
    sw a1, 40(\base)
    sw a2, 44(\base)
    sw a3, 48(\base)
    sw a4, 52(\base)
    sw a5, 56(\base)
    sw a6, 60(\base)
    sw a7, 64(\base)
    sw s2, 68(\base)
    sw s3, 72(\base)
    sw s4, 76(\base)
    sw s5, 80(\base)
    sw s6, 84(\base)
    sw s7, 88(\base)
    sw s8, 92(\base)
    sw s9, 96(\base)
    sw s10, 100(\base)
    sw s11, 104(\base)
    sw t3, 108(\base)
    sw t4, 112(\base)
    sw t5, 116(\base)
    sw t6, 120(\base)
.elseif rv64
    sd ra, 0(\base)
    sd sp, 8(\base)
    sd gp, 16(\base)
    sd tp, 24(\base)
    sd t0, 32(\base)
    sd t1, 40(\base)
    sd t2, 48(\base)
    sd s0, 56(\base)
    sd s1, 64(\base)
    sd a0, 72(\base)
    sd a1, 80(\base)
    sd a2, 88(\base)
    sd a3, 96(\base)
    sd a4, 104(\base)
    sd a5, 112(\base)
    sd a6, 120(\base)
    sd a7, 128(\base)
    sd s2, 136(\base)
    sd s3, 144(\base)
    sd s4, 152(\base)
    sd s5, 160(\base)
    sd s6, 168(\base)
    sd s7, 176(\base)
    sd s8, 184(\base)
    sd s9, 192(\base)
    sd s10, 200(\base)
    sd s11, 208(\base)
    sd t3, 216(\base)
    sd t4, 224(\base)
    sd t5, 232(\base)
    sd t6, 240(\base)
.endif  
.endm

.macro reg_load base
.ifdef rv32
    lw ra, 0(\base)
    lw sp, 4(\base)
    lw gp, 8(\base)
    #lw tp, 12(\base)
    lw tp, 12(\base)
    lw t0, 16(\base)
    lw t1, 20(\base)
    lw t2, 24(\base)
    lw s0, 28(\base)
    lw s1, 32(\base)
    lw a0, 36(\base)
    lw a1, 40(\base)
    lw a2, 44(\base)
    lw a3, 48(\base)
    lw a4, 52(\base)
    lw a5, 56(\base)
    lw a6, 60(\base)
    lw a7, 64(\base)
    lw s2, 68(\base)
    lw s3, 72(\base)
    lw s4, 76(\base)
    lw s5, 80(\base)
    lw s6, 84(\base)
    lw s7, 88(\base)
    lw s8, 92(\base)
    lw s9, 96(\base)
    lw s10, 100(\base)
    lw s11, 104(\base)
    lw t3, 108(\base)
    lw t4, 112(\base)
    lw t5, 116(\base)
    lw t6, 120(\base)
.elseif rv64
    ld ra, 0(\base)
    ld sp, 8(\base)
    ld gp, 16(\base)
    ld tp, 24(\base)
    ld t0, 32(\base)
    ld t1, 40(\base)
    ld t2, 48(\base)
    ld s0, 56(\base)
    ld s1, 64(\base)
    ld a0, 72(\base)
    ld a1, 80(\base)
    ld a2, 88(\base)
    ld a3, 96(\base)
    ld a4, 104(\base)
    ld a5, 112(\base)
    ld a6, 120(\base)
    ld a7, 128(\base)
    ld s2, 136(\base)
    ld s3, 144(\base)
    ld s4, 152(\base)
    ld s5, 160(\base)
    ld s6, 168(\base)
    ld s7, 176(\base)
    ld s8, 184(\base)
    ld s9, 192(\base)
    ld s10, 200(\base)
    ld s11, 208(\base)
    ld t3, 216(\base)
    ld t4, 224(\base)
    ld t5, 232(\base)
    ld t6, 240(\base)
.endif  
.endm

.macro reg_save_isr base
.ifdef rv32
    sw ra, 0(\base)
    # sw sp, 4(\base)
    sw gp, 4(\base)    #  4
    sw tp, 8(\base)    #  8
    sw t0, 12(\base)   #  12
    sw t1, 16(\base)   #  16
    sw t2, 20(\base)   #  20
    sw s0, 24(\base)   #  24
    sw s1, 28(\base)   #  28
    sw a0, 32(\base)   #  32
    sw a1, 36(\base)   #  36
    sw a2, 40(\base)   #  40
    sw a3, 44(\base)   #  44
    sw a4, 48(\base)   #  48
    sw a5, 52(\base)   #  52
    sw a6, 56(\base)   #  56
    sw a7, 60(\base)   #  60
    sw s2, 64(\base)   #  64
    sw s3, 68(\base)   #  68
    sw s4, 72(\base)   #  72
    sw s5, 76(\base)   #  76
    sw s6, 80(\base)   #  80
    sw s7, 84(\base)   #  84
    sw s8, 88(\base)   #  88
    sw s9, 92(\base)   #  92
    sw s10, 96(\base)  #  96
    sw s11, 100(\base) #  100
    sw t3, 104(\base)  #  104
    sw t4, 108(\base)  #  108
    sw t5, 112(\base)  #  112
    sw t6, 116(\base)  #  116
.elseif rv64
    sd ra, 0(\base)
    # sd sp, 8(\base)
    sd gp, 8(\base)    #  8
    sd tp, 16(\base)   #  16
    sd t0, 24(\base)   #  24
    sd t1, 32(\base)   #  32
    sd t2, 40(\base)   #  40
    sd s0, 48(\base)   #  48
    sd s1, 56(\base)   #  56
    sd a0, 64(\base)   #  64
    sd a1, 72(\base)   #  72
    sd a2, 80(\base)   #  80
    sd a3, 88(\base)   #  88
    sd a4, 96(\base)   #  96
    sd a5, 104(\base)  #  104
    sd a6, 112(\base)  #  112
    sd a7, 120(\base)  #  120
    sd s2, 128(\base)  #  128
    sd s3, 136(\base)  #  136
    sd s4, 144(\base)  #  144
    sd s5, 152(\base)  #  152
    sd s6, 160(\base)  #  160
    sd s7, 168(\base)  #  168
    sd s8, 176(\base)  #  176
    sd s9, 184(\base)  #  184
    sd s10, 192(\base) #  192
    sd s11, 200(\base) #  200
    sd t3, 208(\base)  #  208
    sd t4, 216(\base)  #  216
    sd t5, 224(\base)  #  224
    sd t6, 232(\base)  #  232
.endif  
.endm

.macro reg_load_isr base
.ifdef rv32
    lw ra, 0(\base)
    # lw sp, 4(\base)
    lw gp, 4(\base)
    lw tp, 8(\base)
    lw t0, 12(\base)
    lw t1, 16(\base)
    lw t2, 20(\base)
    lw s0, 24(\base)
    lw s1, 28(\base)
    lw a0, 32(\base)
    lw a1, 36(\base)
    lw a2, 40(\base)
    lw a3, 44(\base)
    lw a4, 48(\base)
    lw a5, 52(\base)
    lw a6, 56(\base)
    lw a7, 60(\base)
    lw s2, 64(\base)
    lw s3, 68(\base)
    lw s4, 72(\base)
    lw s5, 76(\base)
    lw s6, 80(\base)
    lw s7, 84(\base)
    lw s8, 88(\base)
    lw s9, 92(\base)
    lw s10, 96(\base)
    lw s11, 100(\base)
    lw t3, 104(\base)
    lw t4, 108(\base)
    lw t5, 112(\base)
    lw t6, 116(\base)
.elseif rv64
    ld ra, 0(\base)
    # ld sp, 8(\base)
    ld gp, 8(\base)
    ld tp, 16(\base)
    ld t0, 24(\base)
    ld t1, 32(\base)
    ld t2, 40(\base)
    ld s0, 48(\base)
    ld s1, 56(\base)
    ld a0, 64(\base)
    ld a1, 72(\base)
    ld a2, 80(\base)
    ld a3, 88(\base)
    ld a4, 96(\base)
    ld a5, 104(\base)
    ld a6, 112(\base)
    ld a7, 120(\base)
    ld s2, 128(\base)
    ld s3, 136(\base)
    ld s4, 144(\base)
    ld s5, 152(\base)
    ld s6, 160(\base)
    ld s7, 168(\base)
    ld s8, 176(\base)
    ld s9, 184(\base)
    ld s10, 192(\base)
    ld s11, 200(\base)
    ld t3, 208(\base)
    ld t4, 216(\base)
    ld t5, 224(\base)
    ld t6, 232(\base)
.endif  
.endm

.globl m_set_interrupt_vector
    m_set_interrupt_vector:
    csrw mtvec, a0
ret

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

.globl m_wait
m_wait:
    wfi
    ret

.globl trap_vector
.align(16)
trap_vector:

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

    sw ra, 0(t0)
    sw sp, 4(t0)
    sw s0, 8(t0)
    sw s1, 12(t0)
    sw s2, 16(t0)
    sw s3, 20(t0)
    sw s4, 24(t0)
    sw s5, 28(t0)
    sw s6, 32(t0)
    sw s7, 36(t0)
    sw s8, 40(t0)
    sw s9, 44(t0)
    sw s10, 48(t0)
    sw s11, 52(t0)
    
    csrr t1, mepc
    sw t1, 56(t0)
    
    csrr t1, mstatus
    sw t1, 60(t0) 

    csrr t1, mcause
    sw t1, 64(t0)

 trap_vector_start:   
    csrrw sp, mscratch, sp
.ifdef rv32
    #addi sp, sp, -120
    addi sp, sp, -128
.elseif rv64
    addi sp, sp, -240
.endif
    reg_save_isr sp
	csrr	a0, mepc
	csrr	a1, mcause
    csrr    a2, mtval
	call	trap_handler #from kernel
	csrw	mepc, a0
	reg_load_isr sp
.ifdef rv32
    addi sp, sp, 128
.elseif rv64
    addi sp, sp, 240
.endif
    
    csrrw sp, mscratch, sp

    la t0, currentTask
    lw t0, 0(t0)
    beqz t0, trap_vector_ret

    lw t1, 56(t0)
    csrw mepc, t1 

    lw s11, 52(t0)
    lw s10, 48(t0)
    lw s9, 44(t0)
    lw s8, 40(t0)
    lw s7, 36(t0)
    lw s6, 32(t0)
    lw s5, 28(t0)
    lw s4, 24(t0)
    lw s3, 20(t0)
    lw s2, 16(t0)
    lw s1, 12(t0)
    lw s0, 8(t0)
    lw sp, 4(t0)
    lw ra, 0(t0)

    #csrci mstatus, 0x8    # MIE = 0
    #csrci mstatus, 0x80   # MPIE = 0
trap_vector_ret:
	mret

.globl set_minterrupt_vector_trap
set_minterrupt_vector_trap:
    la a0, trap_vector
    #slli t0, t0, 1
    csrw mtvec, a0
    ret
