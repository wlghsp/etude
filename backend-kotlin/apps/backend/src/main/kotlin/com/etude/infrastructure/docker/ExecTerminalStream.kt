package com.etude.infrastructure.docker

import com.etude.domain.terminal.TerminalStream
import com.github.dockerjava.api.DockerClient
import com.github.dockerjava.api.async.ResultCallback
import com.github.dockerjava.api.model.Frame
import java.io.PipedInputStream
import java.io.PipedOutputStream

class ExecTerminalStream(
    private val dockerClient: DockerClient,
    containerId: String,
    command: List<String>,
): TerminalStream {
    private val execId: String
    private val stdinPipeOut = PipedOutputStream()
    private val stdinPipeIn = PipedInputStream(stdinPipeOut)
    private var outputListener: ((ByteArray) -> Unit)? = null

    init {
        execId = dockerClient.execCreateCmd(containerId)
            .withCmd(*command.toTypedArray())
            .withAttachStdin(true).withAttachStdout(true).withAttachStderr(true)
            .withTty(true)
            .exec()
            .id

        dockerClient.execStartCmd(execId)
            .withStdIn(stdinPipeIn)
            .withTty(true)
            .exec(object : ResultCallback.Adapter<Frame>() {
                override fun onNext(frame: Frame) {
                    outputListener?.invoke(frame.payload)
                }
            })
    }

    override fun onOutput(listener: (ByteArray) -> Unit) {
        outputListener = listener
    }

    override fun write(data: ByteArray) {
        stdinPipeOut.write(data)
        stdinPipeOut.flush()
    }

    override fun resize(cols: Int, rows: Int) {
        dockerClient.resizeExecCmd(execId).withSize(rows, cols).exec()
    }

    override fun close() {
        stdinPipeOut.close()
    }
}