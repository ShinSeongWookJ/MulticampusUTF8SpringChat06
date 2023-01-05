package com.multi.chatapp;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker //WebSocket�޽��� ó���� Ȱ��ȭ ��Ŵ
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer{
	
	@Override
	public void configureMessageBroker(MessageBrokerRegistry config) {
		config.enableSimpleBroker("/topic","queue");
		config.setApplicationDestinationPrefixes("/app");//���ξ� ����
		//�޽��� ������ �ٿ��� �ϴ� prefix�� /app���� ����
	}
	
	@Override
	public void registerStompEndpoints(StompEndpointRegistry registry) {
		registry.addEndpoint("/chat").withSockJS();//sockjs �� �̿��Ͽ� ������ ����ϵ��� ����
	}

}
