package com.ccl.collaborativecomputinglab.Controller;

import com.ccl.collaborativecomputinglab.Model.IceCandidate;
import com.ccl.collaborativecomputinglab.Model.SDP;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
public class SignalingController {

    @MessageMapping("/sdp")
    @SendTo("/signaling/sdp")
    public SDP sendSDP(@Payload SDP sdp) {
        return sdp;
    }

    @MessageMapping("/ice")
    @SendTo("/signaling/ice")
    public IceCandidate sendIceCandidate(@Payload IceCandidate iceCandidate) {
        return iceCandidate;
    }
}
