/**
 * Authors: initkfs
 */
module api.arch.riscv.hal.externs;

extern (C) @trusted:

size_t m_get_misa();
int m_get_mvendorid();
size_t m_get_marchid();
size_t m_get_mimpid();

void m_set_global_interrupt_enable();
void m_set_global_interrupt_disable();
size_t m_check_global_interrupt_is_enable();

size_t m_get_hart_id();
size_t m_get_status();
void m_set_status(size_t status);
size_t m_get_exception_counter();
void m_set_exception_counter(size_t c);
void m_set_scratch(size_t s);
size_t m_get_scratch();

size_t m_get_local_interrupt_enable();
void m_set_local_interrupt_enable(size_t v);
void m_clear_local_interrupt_enable(size_t v);
size_t m_replace_local_interrupt_enable(size_t v);

void m_set_interrupt_vector(size_t v);