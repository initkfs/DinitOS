.section ".text.boot"
/**
 * Author: initkfs
 */
.globl _start
_start:
    csrr a0, mhartid
    bnez a0, _hlt
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
    .set offset, 0
    .rept 32
        sw x\offset, (\base + offset * 8)(x0)
       .set offset, offset + 1
    .endr
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

.globl m_get_misa
m_get_misa:
csrr a0, misa
ret

.globl m_get_mvendorid
m_get_mvendorid:
csrr a0, mvendorid
ret

.globl m_get_marchid
m_get_marchid:
csrr a0, marchid
ret

.globl m_get_mimpid
m_get_mimpid:
# Machine Implementation ID (mimpid) Register
csrr a0, mimpid
ret

.globl m_get_hart_id
m_get_hart_id:
csrr a0, mhartid
ret
.globl m_get_status
m_get_status:
csrr a0, mstatus
ret
.globl m_set_status
m_set_status:
csrw mstatus, a0
ret
.globl m_set_exception_counter
m_set_exception_counter:
csrw mepc, a0
ret
.globl m_get_exception_counter
m_get_exception_counter:
csrr a0, mepc
ret
.globl m_set_scratch
m_set_scratch:
csrw mscratch, a0
ret

.equ MSTATUS_MIE_BIT, 3   # 3 - Machine Interrupt Enable
.equ MSTATUS_MIE_MASK, 1 << MSTATUS_MIE_BIT  # 0x8 (1 << 3)

.globl m_set_global_interrupt_enable
m_set_global_interrupt_enable:
    csrsi mstatus, MSTATUS_MIE_MASK  # MIE in mstatus
    ret

.globl m_set_global_interrupt_disable
m_set_global_interrupt_disable:
    csrci mstatus, MSTATUS_MIE_MASK  # reset MIE in mstatus
    ret

.globl m_check_global_interrupt_is_enable
m_check_global_interrupt_is_enable:
    csrr a0, mstatus
    andi a0, a0, MSTATUS_MIE_MASK
    snez a0, a0 # return 1 or 0
    ret

.globl m_get_local_interrupt_enable
m_get_local_interrupt_enable:
    csrr a0, mie
    ret

.globl m_replace_local_interrupt_enable
m_replace_local_interrupt_enable:
    csrw mie, a0
    ret

.globl m_set_interrupt_vector
    m_set_interrupt_vector:
    csrw mtvec, a0
ret

.globl m_set_local_interrupt_enable
m_set_local_interrupt_enable:
    csrs mie, a0
    ret

.globl m_clear_local_interrupt_enable
m_clear_local_interrupt_enable:
    csrc mie, a0
    ret

.globl context_switch
context_switch:
    context_save a0  # a0 old context ptr
    context_load a1  # a1 new context ptr
    ret

.globl trap_vector
.align(4)
trap_vector:
	csrrw	t6, mscratch, t6
    reg_save t6
	csrw	mscratch, t6
	csrr	a0, mepc
	csrr	a1, mcause
    csrr    a2, mtval
	call	trap_handler #from kernel
	csrw	mepc, a0
	csrr	t6, mscratch
	reg_load t6
	mret

.globl swap_acquire
swap_acquire:
    li t0, 1
    lw t1, (a0)                 # Check if lock is held.
    bnez t1, swap_acquire       # Retry if held.
    amoswap.w.aq t1, t0, 0(a0)  # Attempt to acquire lock.
    bnez t1, swap_acquire       # Retry if held.
    mv a0, t0
    ret
.globl swap_release
swap_release:
    amoswap.w.rl x0, x0, 0(a0)
    li a0, 0
    ret
#sw zero, (a0)

.globl cas_lrsc
# TODO check extension
# a0 address of memory location
# a1 expected
# a2 desired
# a0 return value, 1 if successful, 0 otherwise
# TODO sequence sequentially
cas_lrsc:
    .ifdef rvSMP
    fence rw, rw
    .endif

    .ifdef rv32
    lr.w t0, (a0)          # Load original value.
    .elseif rv64
    lr.d t0, (a0)
    .endif  

    bne t0, a1, cas_lrsc_fail
    
    .ifdef rv32
    sc.w t0, a2, (a0)      # try update
    .elseif rv64
    sc.d t0, a2, (a0)
    .endif 
    
    bnez t0, cas_lrsc      # retry if failed
    
    .ifdef rvSMP
    fence rw, rw
    .endif

    li a0, 1               # success
    ret
cas_lrsc_fail:
    li a0, 0
    ret

.globl set_minterrupt_vector_trap
set_minterrupt_vector_trap:
    la a0, trap_vector
    csrw mtvec, a0
    ret

.globl get_bss_start
get_bss_start:
    la a0, _bss_start
    ret

.globl get_bss_end
get_bss_end:
    la a0, _bss_end
    ret

.globl get_heap_start
get_heap_start:
    la a0, _heap_start
    ret

.globl get_heap_end
get_heap_end:
    la a0, _heap_end
    ret
