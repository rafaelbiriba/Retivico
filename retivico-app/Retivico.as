﻿package {	import flash.external.*;	import flash.utils.*;	import flash.text.*;			//Graphics Imports	import flash.display.MovieClip;	import flash.display.Sprite;	import fl.controls.Button;	import fl.controls.TextArea;	import flash.media.Video;	import flash.media.Camera;	import flash.media.Sound;	import flash.media.Microphone;	import fl.transitions.Tween;	import fl.transitions.easing.*;	//import fl.transitions.TweenEvent;		//Network Imports	import flash.net.NetConnection;	import flash.net.NetStream;	import flash.net.Responder;		//Events Imports	import flash.events.*;				public class Retivico extends MovieClip {		//Variable declarations		public var nc:NetConnection;		public var ns:NetStream;		public var nsPlay:NetStream;		public var recordBtn:Button;		public var stopBtn:Button;		public var playBtn:Button;		public var cam:Camera = Camera.getCamera();		public var pointer:MovieClip;		public var videoWindow:Video;		public var logField:TextArea;		public var bandwidthValue:TextField;		public var isRecording:Boolean = false;		public var mic:Microphone;		public var sound:Sound;		public var videoName:String;		public var bandwidth:Number;				public var coeficiente:Number = 0;		public var maxBandwidth:Number = 0;				public var checkBandwidthInterval:uint;		public var medidorBandaInterval:uint;				public function logger(mensagem:String):void{			  logField.appendText(mensagem+"\n");			  logField.verticalScrollPosition = logField.maxVerticalScrollPosition;		}	//#############################// Buttons functions //#############################//				public function recordClick(event:MouseEvent):void{			logger ("Record !");			mic = Microphone.getMicrophone();			ns.attachAudio( mic );			ns.publish( getUniqueStreamName(), "record" );			isRecording = true;			recordBtn.enabled = false;			stopBtn.enabled = true;		}				public function stopClick(event:MouseEvent):void{			if(isRecording){				isRecording = false;				stopBtn.enabled = false;				playBtn.enabled = true;				logger ("Stop !");				ns.close();				ns.attachAudio( null );					ns = null;				ns = new NetStream( nc ); 				ns.attachCamera( cam );			}		}				public function disableAllButtons():void{			recordBtn.enabled = false;			playBtn.enabled = false;			stopBtn.enabled = false;		}				public function setAllButtonsEvents():void{			recordBtn.addEventListener(MouseEvent.CLICK, recordClick);			stopBtn.addEventListener(MouseEvent.CLICK, stopClick);			playBtn.addEventListener(MouseEvent.CLICK, playClick);		}				public function playClick(event:MouseEvent):void{			logger ("Play !");			nsPlay = new NetStream( nc );			var customClient:Object = new Object();			ns.client = customClient;			customClient.onMetaData = metaDataHandler;			videoWindow.attachNetStream(nsPlay);			nsPlay.play(videoName);		}	//#############################// Bandwidth functions //#############################//			public function regulaCam():void{			cam.setQuality( bandwidth, 0);			logger("Regulando CAM !");			logger("New bandwidth CAM: " + cam.bandwidth +" bytes");		}				public function checkBandwidth():void{			logger("Calling bandwidth detection and setting deamon...");			bandwidthValue.text = String(maxBandwidth)+" kbps"			nc.call("checkBandwidth", null);			checkBandwidthInterval = setInterval(nc.call, 3000, "checkBandwidth", null);			medidorBandaInterval = setInterval(medidorBanda, 6010);		}			public function medidorBanda(){			var valor:Number = nc.client.getBanda();			//Pointer 0 - 252			var myTween:Tween;			if(valor >= maxBandwidth){				myTween = new Tween(pointer, "x", Strong.easeInOut, pointer.x, 252, 5, true);				bandwidth = Math.round(maxBandwidth*1024/8); //convert kbps in bits and then to bytes			}			else{				myTween = new Tween(pointer, "x", Strong.easeInOut, pointer.x, ((valor*252)/maxBandwidth), 5, true);				bandwidth = Math.round(valor*1024/8);					}			logger("Bandwidth: >> " + valor + " kbps | Maximo: >> "+maxBandwidth+" kbps");			regulaCam();		}			private function metaDataHandler(infoObject:Object):void {			//get video data rate from metadata to use for bw calculation			//var key:String;			//for (key in infoObject){				//if(key == "videodatarate") videoDataRate = infoObject[key];			//}		}	//#############################// Remote FMS functions //#############################//			public function createNetConnection():void{			nc = new NetConnection();			nc.addEventListener(NetStatusEvent.NET_STATUS, networkStatusHandler);			nc.connect( "rtmp://server.localhost/retivico" ); //Remote Flash Media Server			logger(" NC Connect sended !");		}				public function getMaxBandwidthFromServer():void{			nc.call("maxBandwidth", new Responder(function(result){ 				logger("MaxBandwidth: "+result); 				maxBandwidth = parseInt(result);				startCamera();			}));			}				public function getCoeficienteFromServer():void{			nc.call("coeficiente", new Responder(function(result){				logger("Coeficiente: "+result); 				coeficiente = parseInt(result);				startCamera();			}));			}				public function getConfigurationsFromServer():void{			getMaxBandwidthFromServer();			getCoeficienteFromServer();		}//#############################// Retivico functions //#############################//		public function startCamera():void{			if(coeficiente==0 || maxBandwidth==0 ){				logger("Error: Basic settings is blank...");				return;			}			nc.client = new Client();			checkBandwidth();			ns = new NetStream( nc );			ns.attachCamera( cam );			if(cam==null){				logger("Camera NULL !");			}			else{				cam.setQuality( 32000, 0);				cam.setLoopback( true );				logger("Setting camera...");				videoWindow.attachCamera( cam );				videoWindow.smoothing = true;				logger("Width: " + cam.width + " -- Height: " + cam.height + " ----- Quality: " + cam.quality + " ----- FPS: " + cam.fps + " ----- current FPS: " + cam.currentFPS + " ------ bandwidth: " + cam.bandwidth);			}			}		function Retivico() {			sound = new Sound();			logField.visible = true;			disableAllButtons();			setAllButtonsEvents();			recordBtn.enabled = true;			createNetConnection();		}		//#############################// Network events functions //#############################//			private function networkStatusHandler(event:NetStatusEvent):void {			switch (event.info.code) {				case "NetConnection.Connect.Success":					if(event.target == nc){						getConfigurationsFromServer();						logger(event.info.code);					}					else{						logger(event.info.code);					}					break;						}		}	//#############################// Other functions //#############################//		function getUniqueStreamName():String {			// create a random/unique name for each recording			//videoName = "Flash_" + String( Math.random() );			var myDate:Date = new Date();			videoName = "retivico_record";			videoName += "_" + myDate.getDate() + "-" + (myDate.getMonth() + 1) + "-" + myDate.getFullYear();			videoName += "_" + myDate.getHours() + "-" + myDate.getMinutes() + "-" + myDate.getSeconds() + "-" + myDate.getMilliseconds();			return videoName;		}	} // close class Retivico} // close class package