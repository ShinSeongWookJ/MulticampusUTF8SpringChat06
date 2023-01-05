<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Swan's Chat</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<link
	href="http://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.3.0/css/font-awesome.min.css"
	rel="stylesheet" type="text/css">
<style type="text/css">
.discussion {
		  	list-style: none;
		  	background: #ededed;
		  	margin: 0;
		  	padding: 0 0 50px 0;
		}
		
		.discussion li {
		  	padding: 0.5em;
		  	overflow: hidden;
		  	display: flex;
		}
		
		.discussion .avatar {
		  	width: 40px;
		  	position: relative;
		}
		
		.discussion .avatar img {
		  	display: block;
		  	width: 100%;
		}
		
		.other .avatar:after {
		  	content: "";
		  	position: absolute;
		  	top: 0;
		  	right: 0;
		  	width: 0;
		  	height: 0;
		  	border: 5px solid white;
		  	border-left-color: transparent;
		  	border-bottom-color: transparent;
		}
		
		.self {
		  	justify-content: flex-end;
		  	align-items: flex-end;
		}
		
		.self .messages {
		  	order: 1;
		  	border-bottom-right-radius: 0;
		}
		
		.self .avatar {
		  	order: 2;
		}
		
		.self .avatar:after {
		  	content: "";
		  	position: absolute;
		  	bottom: 0;
		  	left: 0;
		  	width: 0;
		  	height: 0;
		  	border: 5px solid white;
		  	border-right-color: transparent;
		  	border-top-color: transparent;
		  	box-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
		}
		
		.messages {
		  	background: white;
		  	padding: 10px;
		  	border-radius: 2px;
		  	box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
		}
		
		.messages p {
		  	font-size: 0.8em;
		  	margin: 0 0 0.2em 0;
		}
		
		.messages time {
		  	font-size: 0.7em;
		  	color: #ccc;
		}

</style>	
	
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
<!-- socketjs/stomp참조-------------------------------------------------  -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.4.0/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<!-- -------------------------------------------------------------- -->
<script type="text/javascript">
	let socket=null;
	let stompClient=null;
	let mynick;
	$(function(){
		disableChat();
		showStatus('Welcome to MyChat');
		
		//1. 채팅 서버 연결하기
		$('#btnConnect').click(function(){
			//닉네임 얻기
			mynick=$('#nickname').val();
			if(!mynick){
				alert('닉네임을 입력하세요');
				$('#nickname').focus();
				return;
			}
			//채팅서버 접속////
			connect();	
			///////////////
			
			////////////////////////
			enableChat();
		})
		//2. 채팅 서버 연결끊기
		$('#btnDisconnect').click(function(){
			let str={
				from:mynick,
				to:'all',
				text:mynick+'님이 퇴장하였습니다'
			}
			sendMessage(str);//서버에 퇴장 메시지 전송
			showStatus("채팅서버 연결이 끊어졌습니다.");
			
			if(stompClient!=null){
				stompClient.disconnect();
				stompClient=null;
				print('Disconnected....');
				setConnected(false);
			}
			disableChat();
		})//-----------
		$('#inputMsg').keypress(function(evt){
			//alert(evt.keyCode)
			if(evt.keyCode==13){//엔터키라면
				let msg=$(this).val();
				let str={
					from:mynick,
					to:'all',
					text:msg
				}
				let jsonStr=JSON.stringify(str);
				print('서버에 보낼 데이터: '+jsonStr);
				sendMessage(str);
				$(this).val('').focus();
				let mymsg='<label class="label label-danger">'+mynick+"</label>"+msg;
				let d=new Date();
				let time=d.getFullYear()+"-"+(d.getMonth()+1)+"-"+d.getDate()+" "+d.getHours()+":"
						+d.getMinutes()+":"+d.getSeconds();
						
				addToMessage('self', mymsg, time);
				//자기 메시지 보여주기 (스타일줘서 오른쪽에 출력)
			}//-------------------
		})
		
	})//$() end----
	//who : self, other
	function addToMessage(who, msg, time){
		let img='${pageContext.request.contextPath}/resources/me.PNG';
		if(who=='other'){
			img='${pageContext.request.contextPath}/resources/other.PNG';
		}
		let str='<li class="'+who+'">';
			str+='<div class="avatar">';
			str+="<img src='"+img+"'>";
			str+="</div>";
			str+="<div class='messages'>";
			str+="<p>"+msg+"</p>";
			str+="<time datetime='"+time+"'>"+time+"</time>";
			str+="</div>";
			str+="</li>";
			$('#taMsg').append(str);
			//스크롤바 따라다니기
			$('#taMsg').scrollTop($('#taMsg')[0].scrollHeight);
	}//------------------------------
	
	function sendMessage(str){
		let jsonStr=JSON.stringify(str);
		stompClient.send("/app/chat",{},jsonStr);
	}//--------------------------------
	
	function print(str){
		console.log(str);
	}
	
	function connect(){
		socket=new SockJS('${pageContext.request.contextPath}/chat')
		stompClient=Stomp.over(socket);
		//alert(stompClient)
		stompClient.connect({},function(frame){
			console.log('frame==='+frame);
			console.log('---Connected--------');
			setConnected(true);
			showStatus('채팅 서버에 연결되었습니다');
			let str={
					from:mynick,
					to:'all',
					text:mynick+"님이 접속했어요"	
				}
				let jsonStr=JSON.stringify(str);
				print('서버에 보낼 데이터: '+jsonStr);
				//서버에 데이터 전송////////////////////
				//Stomp send(destination,headers, body)
				stompClient.send("/app/chat",{},jsonStr);
			
			//ChatController가 보내오는 메시지를 듣는 함수
			stompClient.subscribe('/topic/messages',function(msg){
				print('msg: '+msg);
				print('msg.body: '+msg.body)
				let jsonObj=JSON.parse(msg.body)
				showChatMessage(jsonObj);
			})
			
		})//stompClient.connect()----		
	}//connect()-------------------------
	
	function showChatMessage(data){
		if(data.from!=mynick){
			//메시지를 보낸 사람이 다른 사람이라면
			let str="<p><label class='label label-success'>"+data.from+"</label>"+data.text+"</p>";
			let time=data.time;
			addToMessage('other',str,time);
		}
		//$('#taMsg').append(data.from+">>>"+data.text+"<br>")
	}//----------------------
	
	//버튼의 활성화 여부를 설정하는 함수
	function setConnected(flag){
		$('#btnConnect').prop('disabled', flag);
		$('#btnDisconnect').prop('disabled', !flag);
	}
	
	//채팅창 비활성화
	function disableChat(){
		$('#inputMsg').prop('readonly',true);
		$('#taMsg').text("").prop('readonly', true);
	}
	//채팅창 활성화
	function enableChat(){
		$('#inputMsg').prop('readonly',false);
		$('#taMsg').text("").prop('readonly', false);
	}
	function showStatus(str){
		$('#status').html(str).css('color','blue').css('font-weight','bold')
	}
</script>	
</head>
<body>
	<div class="container">
		<div class="section">
			<div class="row">
				<div class="col-md-12">
					<h1 class="text-center text-primary">
						<a><i class="fa fa-fw fa-heart-o fa-lg hub"></i></a>Swan's
						Chatting<a><i class="fa fa-fw fa-heart-o fa-lg hub"></i></a>
					</h1>
					

					<div class="panel-group" style="margin-top: 30px;">


						<div class="panel panel-danger col-md-11" id="roommake"
							style="height: 250px;">
							<div class="panel-heading">
								<a style="color: #d9534f;"><i
									class="fa fa-2x fa-fw hub fa-home"></i></a>채팅
							</div>
							<div class="panel-body">								
								<div class="row" style="margin-top: 8px; margin-bottom: 10px">
									<label class="col-md-3" for="nickname">닉네임 :</label>
									<div class="col-md-9">
										<input id="nickname" type="text" class="form-control"
											placeholder="닉네임">
									</div>
								</div>
								<div class="row">
									<div class="col-md-12 text-right">

										<input id="btnConnect" type="button" value="채팅서버 연결하기"
											class="btn btn-primary">
										<button class="btn btn-danger" id="btnDisconnect">채팅서버 연결 끊기</button>										
										<button class="btn btn-info" id="btnOne">1:1 채팅</button>
									</div>
								</div>
							</div>
						</div>
						

						<div class="panel panel-info col-md-11" id="chatroom"
							style="margin-top: 13px">
							<div class="panel-heading">
								<a><i class="fa fa-3x fa-fw fa-comments-o"></i></a>:::Chat:::
								<div id="status"></div>
							</div>
							<div class="panel-body">
								<div id="chatmsg" class="col-md-10 col-md-offset-1">
									<div class="row">
										<label class="col-md-3 text-right" for="inputMsg">메시지
											:</label>
										<div class="col-md-9">
											<input id="inputMsg" type="text" class="form-control"
												placeholder="메시지를 입력하세요">
										</div>
									</div>
									<div class="row" style="margin-top: 10px">
										<div class="col-md-3" id="ulist">
										</div>
										<div class="col-md-9">
											<div id="taMsg" class="discussion" style="width:100%;height:400px;overflow: auto" readonly class="form-control"></div>
										</div>
										
									</div>
								</div>
							</div>
						</div>
					</div>
					
					

				</div>
			</div>
		</div>
	</div>
</body>
</html>