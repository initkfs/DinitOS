.section ".text.boot"

.globl _start
_start:
    la sp, _stack_start
    call dstart
_hlt:
    j _hlt

.macro contextSave base
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

.macro contextLoad base
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

.globl contextSwitch
contextSwitch:
    contextSave a0  # a0 old context ptr
    contextLoad a1  # a1 new context ptr
    ret


    