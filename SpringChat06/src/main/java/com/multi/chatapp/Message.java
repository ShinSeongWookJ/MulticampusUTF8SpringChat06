package com.multi.chatapp;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Message {
	
	private String from;//보내는이
	private String to;//받는이
	private String text;//대화내용

}
