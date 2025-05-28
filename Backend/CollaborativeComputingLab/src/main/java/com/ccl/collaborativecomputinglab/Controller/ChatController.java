package com.ccl.collaborativecomputinglab.Controller;

import com.ccl.collaborativecomputinglab.Model.Chat;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
public class ChatController {

    @MessageMapping("/chat")
    @SendTo("/chat/chat")
    public Chat sendChat(@Payload Chat chat) {
        System.out.println(chat);
        return chat;
    }
}
