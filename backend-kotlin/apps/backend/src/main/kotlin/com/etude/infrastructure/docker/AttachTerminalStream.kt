package com.etude.infrastructure.docker

import com.etude.domain.terminal.TerminalStream
import com.github.dockerjava.api.DockerClient
import com.github.dockerjava.api.async.ResultCallback
import com.github.dockerjava.api.model.Frame
import java.io.PipedInputStream
import java.io.PipedOutputStream

class AttachTerminalStream(
    private val dockerClient: DockerClient,
    private val containerId: String,
) : TerminalStream {
    private val stdinPipeOut = PipedOutputStream()
    private val stdoutPipeIn = PipedInputStream(stdinPipeOut)
    private var outputListener: ((ByteArray) -> Unit)? = null

    init {
        dockerClient.attachContainerCmd(containerId)
            .withStdIn(stdoutPipeIn)
            .withStdOut(true)
            .withStdErr(true)
            .withFollowStream(true)
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
        dockerClient.resizeContainerCmd(containerId).withSize(rows, cols).exec()
    }

    override fun close() {
        stdoutPipeIn.close()
    }
}