module api.arch.riscv.hal.board.com.com_memory;
/**
 * Authors: initkfs
 */
import ldc.llvmasm;

extern (C):

size_t _heap_start;
size_t _heap_end;

size_t get_heap_start()
{
    return _heap_start;
}

size_t get_heap_end()
{
    return _heap_end;
}
