package com.etude.interfaces.ws

import com.etude.domain.terminal.TerminalSession
import com.etude.domain.terminal.TerminalSessionService
import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.stereotype.Component
import org.springframework.web.socket.BinaryMessage
import org.springframework.web.socket.CloseStatus
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.handler.BinaryWebSocketHandler
import java.util.concurrent.ConcurrentHashMap

data class ResizeMessage(val type: String, val cols: Int, val rows: Int)

@Component
class TerminalWebSocketHandler(
    private val terminalSessionService: TerminalSessionService,
    private val objectMapper: ObjectMapper,
) : BinaryWebSocketHandler() {
    private val sessions = ConcurrentHashMap<String, TerminalSession>()

    override fun afterConnectionEstablished(session: WebSocketSession) {
        val params = org.springframework.web.util.UriComponentsBuilder.fromUri(session.uri!!).build().queryParams
        val sandboxType = params.getFirst("sandboxType") ?: "linux"
        val questId = params.getFirst("questId")?.toLong()
        val existingContainerId = params.getFirst("containerId")

        val terminalSession = terminalSessionService.open(sandboxType, questId, existingContainerId)
        sessions[session.id] = terminalSession

        synchronized(session) {
            session.sendMessage(TextMessage(
                objectMapper.writeValueAsString(mapOf("type" to "connected", "containerId" to terminalSession.containerId))
            ))
        }

        terminalSession.stream.onOutput { bytes ->
            synchronized(session) { session.sendMessage(BinaryMessage(bytes)) }
        }
    }

    override fun handleBinaryMessage(session: WebSocketSession, message: BinaryMessage) {
        sessions[session.id]?.stream?.write(message.payload.array())
    }

    override fun handleTextMessage(session: WebSocketSession, message: TextMessage) {
        val terminalSession = sessions[session.id] ?: return
        val resize = runCatching { objectMapper.readValue(message.payload, ResizeMessage::class.java) }.getOrNull()
        if (resize?.type == "resize") {
            terminalSession.stream.resize(resize.cols, resize.rows)
        } else {
            terminalSession.stream.write(message.payload.toByteArray())
        }
    }

    override fun afterConnectionClosed(session: WebSocketSession, status: CloseStatus) {
        sessions.remove(session.id)?.close()
    }
}