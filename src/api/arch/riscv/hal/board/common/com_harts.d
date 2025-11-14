module api.arch.riscv.hal.board.common.com_harts;

/**
 * Authors: initkfs
 */
import ldc.llvmasm;

size_t mhartId() @trusted => __asm!size_t("csrr $0, mhartid", "=r");