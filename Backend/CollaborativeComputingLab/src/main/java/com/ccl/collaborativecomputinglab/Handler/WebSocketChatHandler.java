package com.ccl.collaborativecomputinglab.Handler;

import com.ccl.collaborativecomputinglab.Model.ChatDTO;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

@Slf4j
@RequiredArgsConstructor
@Component
public class WebSocketChatHandler extends TextWebSocketHandler {

    private Set<WebSocketSession> sessionSet = new HashSet<>();
    private final ObjectMapper objectMapper;

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        super.handleTextMessage(session, message);

        sessionSet.add(session);

        String id = session.getId();
        String payload = message.getPayload();

        ChatDTO chatDTO = objectMapper.readValue(payload, ChatDTO.class);
        sendMessageToAll(new TextMessage(objectMapper.writeValueAsString(chatDTO)));
    }

    private void sendMessageToAll(TextMessage message) throws Exception {
        sessionSet.parallelStream().forEach(session -> {
            try {
                sendMessage(session, message);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        });
    }

    private void sendMessage(WebSocketSession session, TextMessage message) throws Exception {
        try {
            if (session.isOpen()) {
                session.sendMessage(message);
            }
        } catch (IOException e) {
            log.error(e.getMessage(), e);
        }
    }
}
