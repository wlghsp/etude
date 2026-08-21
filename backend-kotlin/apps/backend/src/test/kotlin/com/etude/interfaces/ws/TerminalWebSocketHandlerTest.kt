package com.etude.interfaces.ws

import com.etude.support.IntegrationTest
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.web.server.LocalServerPort
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.client.standard.StandardWebSocketClient
import org.springframework.web.socket.handler.TextWebSocketHandler
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class TerminalWebSocketHandlerTest(
    @LocalServerPort private val port: Int,
) : IntegrationTest({

    "linux 타입으로 연결하면" - {
        "connected 메시지를 받는다" {
            val client = StandardWebSocketClient()
            val connectedFuture = CompletableFuture<String>()

            val handler = object : TextWebSocketHandler() {
                override fun handleTextMessage(session: WebSocketSession, message: TextMessage) {
                    connectedFuture.complete(message.payload)
                }
            }

            val session = client.execute(handler, "ws://localhost:$port/ws/terminal?sandboxType=linux").get()
            val received = connectedFuture.get(10, TimeUnit.SECONDS)

            assert(received.contains("\"type\":\"connected\""))
            session.close()
        }
    }
})