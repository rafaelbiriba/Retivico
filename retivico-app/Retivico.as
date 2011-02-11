package {
	import flash.external.*;
	import flash.utils.*;
		
	//Graphics Imports
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import fl.controls.Button;
	import fl.controls.TextArea;
	import flash.media.Video;
	import flash.media.Camera;
	import flash.media.Sound;
	import flash.media.Microphone;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	//import fl.transitions.TweenEvent;
	
	//Network Imports
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	
	//Events Imports
	import flash.events.*;
			
	public class Retivico extends MovieClip {

	//Variable declarations
	public var nc:NetConnection;
	public var ns:NetStream;
	public var nsPlay:NetStream;
	public var recordBtn:Button;
	public var stopBtn:Button;
	public var playBtn:Button;
	public var cam:Camera = Camera.getCamera();
	public var pointer:MovieClip;
	public var videoWindow:Video;
	public var logField:TextArea;
	public var isRecording:Boolean = false;
	public var mic:Microphone;
	public var sound:Sound;
	public var videoName:String;
	public var bandwidth:Number;
	
	public var checkBandwidthInterval:uint;
	public var medidorBandaInterval:uint;
		
	public function logger(mensagem:String):void{
 		  logField.appendText(mensagem+"\n");
 		  logField.verticalScrollPosition = logField.maxVerticalScrollPosition;
 	}
	
	public function startCamera():void{
		if(cam==null){
			trace("Camera NULL !");
			logger("Camera NULL !");
		}
		else{
			//camera.setMode( 640, 480, 15 );
			//camera.setQuality( 0 , 65 );
			//logger("ahhhhhhhhhhhhhhh >"+bandwidth);
			cam.setQuality( 32000, 0);
			cam.setLoopback( true );
			trace("Monta Video Window !");
			logger("Monta Video Window !");
			videoWindow.attachCamera( cam );
			videoWindow.smoothing = true;
			trace("Camera OK");
			trace("Width: " + cam.width + " -- Height: " + cam.height + " ----- Quality: " + cam.quality + " ----- FPS: " + cam.fps + " ----- current FPS: " + cam.currentFPS + " ------ bandwidth: " + cam.bandwidth);
			logger("Width: " + cam.width + " -- Height: " + cam.height + " ----- Quality: " + cam.quality + " ----- FPS: " + cam.fps + " ----- current FPS: " + cam.currentFPS + " ------ bandwidth: " + cam.bandwidth);
		}

	}
	
	public function regulaCam():void{
		cam.setQuality( bandwidth, 0);
		logger("Regulando CAM !");
		logger("New bandwidth CAM: " + cam.bandwidth +" bytes");
	}	
	//Contructor
	function Retivico() {
	sound = new Sound();
	trace("Starting Button !");
	logger("Starting Button !");
	logField.visible = true;
	recordBtn.addEventListener(MouseEvent.CLICK, recordClick);
	recordBtn.enabled = true;
	stopBtn.addEventListener(MouseEvent.CLICK, stopClick);
	stopBtn.enabled = false;
	playBtn.addEventListener(MouseEvent.CLICK, playClick);
	playBtn.visible = false;
	playBtn.enabled = false;
	
	trace("Monta Camera em 20s!");
	logger("Monta Camera em 20s!");
	//Monta Camera !
	setTimeout(startCamera, 20000);	
	
	trace("New NC Connection !");
	logger("New NC Connection !");
	nc = new NetConnection();
	nc.addEventListener(NetStatusEvent.NET_STATUS, networkStatusHandler);
	nc.connect( "rtmp://0.0.0.0/app" ); //Remote Flash Media Server
	trace(" NC Connect sended !");
	logger(" NC Connect sended !");
	nc.call("teste", new Responder(function(result){logger(result); trace(result);}));		
	}
	
	public function checkBandwidth():void{
		logger(" Calling bandwidth detection !");
		checkBandwidthInterval = setInterval(nc.call, 3000, "checkBandwidth", null);
		medidorBandaInterval = setInterval(medidorBanda, 6000);
		
	}
	public function medidorBanda(){
		var valor:Number = nc.client.getBanda();
		//Pointer 0 - 252
		var myTween:Tween;
		if(valor >= 2000){
			myTween = new Tween(pointer, "x", Strong.easeInOut, pointer.x, 252, 5, true);
			bandwidth = Math.round(2000*128);
		}
		else{
			myTween = new Tween(pointer, "x", Strong.easeInOut, pointer.x, ((valor*252)/2000), 5, true);
			//pointer.x = 252-((valor*252)/1500);
			bandwidth = Math.round(valor*128);		
		}
		logger("Bandwidth: >> " + valor + " kbps | Maximo: >> 2000 kbps");
		regulaCam();
	}
	
	public function recordClick(event:MouseEvent):void{

		trace ("Record !");
		logger ("Record !");
		mic = Microphone.getMicrophone();
		ns.attachAudio( mic );
		ns.publish( getUniqueStreamName(), "record" );
		//sound.setVolume( 0 );
		isRecording = true;
		recordBtn.enabled = false;
		stopBtn.enabled = true;
	}
	
	public function stopClick(event:MouseEvent):void{

		if(isRecording){
		isRecording = false;
		stopBtn.enabled = false;
		playBtn.enabled = true;
		trace ("Stop !");
		logger ("Stop !");
		//clearInterval(checkBandwidthInterval);
		//clearInterval(medidorBandaInterval);
		//sound.setVolume( 100 );
		ns.close();
		ns.attachAudio( null );	
		ns = null;
		ns = new NetStream( nc ); 
		ns.attachCamera( cam );
		}

	}
	
		//get video data rate from metadata to use for bw calculation
	private function metaDataHandler(infoObject:Object):void {
		//var key:String;
		//for (key in infoObject){
			//if(key == "videodatarate")
				//videoDataRate = infoObject[key];
		//}
	}
	
	public function playClick(event:MouseEvent):void{

		trace ("Play !");
		logger ("Play !");
		nsPlay = new NetStream( nc );
		var customClient:Object = new Object();
		ns.client = customClient;
		customClient.onMetaData = metaDataHandler;
		videoWindow.attachNetStream(nsPlay);
		nsPlay.play(videoName);

	}
	
	//Network status handler processes NetStatus events
	private function networkStatusHandler(event:NetStatusEvent):void {
		trace(event.info.code);
		logger(event.info.code);
		trace(event.target);
		var now:Date = new Date();
		switch (event.info.code) {
			case "NetConnection.Connect.Success":
				if(event.target == nc){
					checkBandwidth();
					logger("uhuulll /o/ IF");
					nc.client = new Client();
					ns = new NetStream( nc );
					ns.attachCamera( cam );
				}
				else{
					logger("uhuulll /o/ ELSE");
				}
				break;
		
		}
	}
	

	function getUniqueStreamName():String {
		// create a random/unique name for each recording
		//videoName = "Flash_" + String( Math.random() );
		var myDate:Date = new Date();
		videoName = "retivico_record";
		videoName += "_" + myDate.getDate() + "-" + (myDate.getMonth() + 1) + "-" + myDate.getFullYear();
		videoName += "_" + myDate.getHours() + "-" + myDate.getMinutes() + "-" + myDate.getSeconds() + "-" + myDate.getMilliseconds();
		return videoName;
	}

}
}
