package com.multi.chatapp;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker //WebSocket메시지 처리를 활성화 시킴
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer{
	
	@Override
	public void configureMessageBroker(MessageBrokerRegistry config) {
		config.enableSimpleBroker("/topic","queue");
		config.setApplicationDestinationPrefixes("/app");//접두어 설정
		//메시지 보낼때 붙여야 하는 prefix를 /app으로 지정
	}
	
	@Override
	public void registerStompEndpoints(StompEndpointRegistry registry) {
		registry.addEndpoint("/chat").withSockJS();//sockjs 를 이용하여 웹소켓 통신하도록 설정
	}

}
