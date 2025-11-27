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