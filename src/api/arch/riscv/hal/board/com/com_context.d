module api.arch.riscv.hal.board.com.com_context;

import ldc.llvmasm;
import ldc.attributes;

version (Riscv32)
{
    align(16) void switchInterruptContext() @naked @optStrategy("none") @section(".text.init")
    {
        __asm("
    addi sp, sp, -16
    
    sw t0, 0(sp)
    sw t1, 4(sp)

com_trap_check_cause:
    csrr t0, mcause
    bge t0, zero, com_trap_vector_start

    li t1, 0x7FFFFFFF
    and t0, t0, t1

    li t1, 7                        # timer
    bne t0, t1, com_trap_vector_start

com_trap_save_context:
    la t0, currentTask
    lw t0, 0(t0)
    beqz t0, com_trap_vector_start

    la t1, osTask
    beq t0, t1, com_trap_vector_start

    sw ra, 0(t0)       # 0
    
    addi t1, sp, 16
    sw t1, 4(t0)       # 4
    
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
    sw t1, 96(t0)      # 96 - save t0

    lw t1, 4(sp)       # Restore t1 
    sw t1, 100(t0)     # 100 - save t1
    
    sw t2, 104(t0)     # 104
    sw t3, 108(t0)     # 108
    sw t4, 112(t0)     # 112
    sw t5, 116(t0)     # 116
    sw t6, 120(t0)     # 120

    csrr t1, mepc
    sw t1, 124(t0)     # 124

com_trap_vector_start:  
    lw t1, 4(sp) 
    lw t0, 0(sp)
    addi sp, sp, 16

	csrr	a0, mepc
	csrr	a1, mcause
    csrr    a2, mtval
	call	trap_handler #TODO from arguments
	csrw	mepc, a0
    
    la t0, currentTask

    lw t0, 0(t0)
    beqz t0, com_trap_vector_ret

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
    
    lw t0, 96(t0)      # 96

com_trap_vector_ret:
	mret
    ", "~{memory},~{all}");
    }
}
else version (Riscv64)
{
    align(16) void switchInterruptContext() @naked @optStrategy("none") @section(".text.init")
    {
        __asm("
    addi sp, sp, -16
    sd t0, 0(sp)
    sd t1, 8(sp)

trap_check_cause:
    csrr t0, mcause
    bge t0, zero, com_trap_vector_start

    li t1, 0x7FFFFFFF
    and t0, t0, t1

    li t1, 7                        # timer
    bne t0, t1, com_trap_vector_start

trap_save_context:
    la t0, currentTask
    ld t0, 0(t0)
    beqz t0, com_trap_vector_start

    la t1, osTask
    beq t0, t1, com_trap_vector_start

    sd ra, 0(t0)       # 0/0
    
    addi t1, sp, 16
    sd t1, 8(t0)       # 4/8
    
    sd gp, 16(t0)      # 8/16
    sd tp, 24(t0)      # 12/24

    sd s0, 32(t0)      # 16/32
    sd s1, 40(t0)      # 20/40  
    sd s2, 48(t0)      # 24/48
    sd s3, 56(t0)      # 28/56
    sd s4, 64(t0)      # 32/64
    sd s5, 72(t0)      # 36/72
    sd s6, 80(t0)      # 40/80
    sd s7, 88(t0)      # 44/88
    sd s8, 96(t0)      # 48/96
    sd s9, 104(t0)     # 52/104
    sd s10, 112(t0)    # 56/112
    sd s11, 120(t0)    # 60/120
    
    sd a0, 128(t0)     # 64/128
    sd a1, 136(t0)     # 68/136
    sd a2, 144(t0)     # 72/144
    sd a3, 152(t0)     # 76/152
    sd a4, 160(t0)     # 80/160
    sd a5, 168(t0)     # 84/168
    sd a6, 176(t0)     # 88/176
    sd a7, 184(t0)     # 92/184

    ld t1, 0(sp)       # Restore t0
    sd t1, 192(t0)     # 96/192 - save t0

    ld t1, 8(sp)       # Restore t1 
    sd t1, 200(t0)     # 100/200 - save t1
    
    sd t2, 208(t0)     # 104/208
    sd t3, 216(t0)     # 108/216
    sd t4, 224(t0)     # 112/224
    sd t5, 232(t0)     # 116/232
    sd t6, 240(t0)     # 120/240

    csrr t1, mepc
    sd t1, 248(t0)     # 124/248

com_trap_vector_start:  
    ld t1, 8(sp) 
    ld t0, 0(sp)
    addi sp, sp, 16

	csrr	a0, mepc
	csrr	a1, mcause
    csrr    a2, mtval
	call	trap_handler
	csrw	mepc, a0
    
    la t0, currentTask
    ld t0, 0(t0)
    beqz t0, com_trap_vector_ret

    ld t1, 248(t0)     # 124/248 - mepc
    csrw mepc, t1

    ld s0, 32(t0)      # 16/32
    ld s1, 40(t0)      # 20/40
    ld s2, 48(t0)      # 24/48
    ld s3, 56(t0)      # 28/56
    ld s4, 64(t0)      # 32/64
    ld s5, 72(t0)      # 36/72
    ld s6, 80(t0)      # 40/80
    ld s7, 88(t0)      # 44/88
    ld s8, 96(t0)      # 48/96
    ld s9, 104(t0)     # 52/104
    ld s10, 112(t0)    # 56/112
    ld s11, 120(t0)    # 60/120
    
    ld a0, 128(t0)     # 64/128
    ld a1, 136(t0)     # 68/136
    ld a2, 144(t0)     # 72/144
    ld a3, 152(t0)     # 76/152
    ld a4, 160(t0)     # 80/160
    ld a5, 168(t0)     # 84/168
    ld a6, 176(t0)     # 88/176
    ld a7, 184(t0)     # 92/184
    
    ld t1, 200(t0)     # 100/200
    ld t2, 208(t0)     # 104/208
    ld t3, 216(t0)     # 108/216
    ld t4, 224(t0)     # 112/224
    ld t5, 232(t0)     # 116/232
    ld t6, 240(t0)     # 120/240
    
    ld ra, 0(t0)       # 0/0
    ld sp, 8(t0)       # 4/8
    ld gp, 16(t0)      # 8/16
    ld tp, 24(t0)      # 12/24
    
    ld t0, 192(t0)     # 96/192

com_trap_vector_ret:
	mret
    ", "");
    }
}
