﻿package
{
	import com.aupeo.as3icy.data.MPEGFrame;
	import com.aupeo.as3icy.ICYStream;
	import com.aupeo.as3icy.events.ICYFrameEvent;
	import com.aupeo.as3icy.events.ICYMetaDataEvent;
	
	import flash.display.Sprite;
	import flash.net.*;
	import flash.events.*;
	
	public class AS3ICYTest extends Sprite
	{
		private var icyStream:ICYStream;
		
		public function AS3ICYTest() 
		{
			//var req:URLRequest = new URLRequest("http://stream.m945.mwn.de/m945-hq.mp3");
			//var req:URLRequest = new URLRequest("http://stream.m945.mwn.de/m945-lq.mp3");
			var req:URLRequest = new URLRequest("http://72.233.14.70/hype");
			//var req:URLRequest = new URLRequest("http://gffstream.ic.llnwd.net/stream/gffstream_mp3_w49a");
			//var req:URLRequest = new URLRequest("http://gffstream.ic.llnwd.net/stream/gffstream_stream_wdr_einslive_a");
			req.requestHeaders = [ new URLRequestHeader("Icy-Metadata", "1") ];
			icyStream = new ICYStream();
			icyStream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusHandler);
			icyStream.addEventListener(ICYMetaDataEvent.METADATA, metaDataHandler);
			icyStream.addEventListener(ICYFrameEvent.FRAME, frameHandler);
			icyStream.load(req);
		}
		
		protected function httpResponseStatusHandler(e:HTTPStatusEvent):void {
			tfStationName.text = icyStream.icyName.toUpperCase();
			tfStationDescription.text = (icyStream.icyDescription.length > 0) ? icyStream.icyDescription : "No description";
			tfStationUrl.htmlText = "<a href='" + icyStream.icyUrl + "'>" + icyStream.icyUrl + "</a>";
			tfServer.htmlText = "Server: <font color='#444444'>" + icyStream.icyServer + "</font>";
			tfMetaInterval.htmlText = "Metadata interval: <font color='#444444'>" + icyStream.icyMetaInterval + "</font>";
		}
		
		protected function metaDataHandler(e:ICYMetaDataEvent):void {
			tfMetaReceived.htmlText = "Metadata received: <font color='#444444'>" + icyStream.metaDataLoaded + "</font> blocks, <font color='#444444'>" + icyStream.metaDataBytesLoaded + "</font> bytes";
			if (e.metaData.length > 0) {
				tfNowPlayingHeadline.text = "Now playing:";
				tfTitle.text = e.metaData.slice(13, -2).toUpperCase();
			}
		}
		
		protected function frameHandler(e:ICYFrameEvent):void {
			tfFramesReceived.htmlText = "MPEG frames received: <font color='#444444'>" + icyStream.framesLoaded + "</font>";
			var encoding:String = "unknown";
			switch(icyStream.mpegFrame.version) {
				case MPEGFrame.MPEG_VERSION_1_0: encoding = "1.0 "; break;
				case MPEGFrame.MPEG_VERSION_2_0: encoding = "2.0 "; break;
				case MPEGFrame.MPEG_VERSION_2_5: encoding = "2.5 "; break;
			}
			switch(icyStream.mpegFrame.layer) {
				case MPEGFrame.MPEG_LAYER_I: encoding += "Layer I"; break;
				case MPEGFrame.MPEG_LAYER_II: encoding += "Layer II"; break;
				case MPEGFrame.MPEG_LAYER_III: encoding += "Layer III"; break;
			}
			tfMPEGEncoding.htmlText = "Encoding: <font color='#444444'>MPEG " + encoding + "</font>";
			tfMPEGBitrate.htmlText = "Bitrate: <font color='#444444'>" + icyStream.mpegFrame.bitrate + "</font> kbit/s";
			tfMPEGSamplingrate.htmlText = "Samplingrate: <font color='#444444'>" + icyStream.mpegFrame.samplingrate + "</font> Hz";
			var channelMode:String = "unknown";
			switch(icyStream.mpegFrame.channelMode) {
				case 0: channelMode = "Stereo"; break;
				case 1: channelMode = "Joint stereo"; break;
				case 2: channelMode = "Dual channel"; break;
				case 3: channelMode = "Mono"; break;
			}
			tfMPEGChannelMode.htmlText = "Channel mode: <font color='#444444'>" + channelMode + "</font>";
			//
			e.preventDefault();
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function enterFrameHandler(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			icyStream.resume();
		}
	}
}
