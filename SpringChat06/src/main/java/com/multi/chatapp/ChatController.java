package com.multi.chatapp;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import lombok.extern.log4j.Log4j;

@Controller
@Log4j
public class ChatController {
	
	@GetMapping("/chatform")
	public String chatForm() {
		
		return "chatUI";
	}
	
	@MessageMapping("/chat")
	@SendTo("/topic/messages")
	public OutputMessage send(Message msg) throws Exception{
		log.info("msg====>>>"+msg);
		String time=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
		return new OutputMessage(msg.getFrom(),"all",msg.getText(),time);
	}

}
