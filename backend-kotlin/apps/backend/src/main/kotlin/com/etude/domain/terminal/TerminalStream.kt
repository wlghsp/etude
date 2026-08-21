package com.etude.domain.terminal

interface TerminalStream {
    fun onOutput(listener: (ByteArray) -> Unit)
    fun write(data: ByteArray)
    fun resize(cols: Int, rows: Int)
    fun close()
}