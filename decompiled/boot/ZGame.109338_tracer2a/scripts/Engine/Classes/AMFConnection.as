package Engine.Classes
{
   import flash.events.AsyncErrorEvent;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.NetConnection;
   import flash.net.Responder;
   
   public class AMFConnection
   {
      
      protected var m_netConnection:NetConnection = new NetConnection();
      
      protected var m_responder:Responder;
      
      protected var m_statusCallback:Function = null;
      
      protected var m_resultCallback:Function = null;
      
      protected var m_functionName:String;
      
      private const TRANSPORT_FAILURE_AMF_FAULT:int = 1;
      
      private const TRANSPORT_FAILURE_NET_STATUS:int = 2;
      
      private const TRANSPORT_FAILURE_IO_ERROR:int = 4;
      
      private const TRANSPORT_FAILURE_ASYNC_ERROR:int = 4;
      
      private const TRANSPORT_FAILURE_SECURITY_ERROR:int = 5;
      
      public function AMFConnection(param1:Function, param2:Function)
      {
         super();
         this.m_statusCallback = param2;
         this.m_resultCallback = param1;
         this.m_responder = new Responder(this.onResult,this.onFault);
         this.m_netConnection.connect(Config.SERVICES_GATEWAY_PATH);
         this.m_netConnection.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus,false,0,true);
         this.m_netConnection.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError,false,0,true);
         this.m_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onAsyncError,false,0,true);
         this.m_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError,false,0,true);
      }
      
      protected function onResult(param1:Object) : void
      {
         this.logEvent("Result received.");
         if(this.m_resultCallback != null)
         {
            this.m_resultCallback(param1);
         }
      }
      
      protected function onFault(param1:Object) : void
      {
         var _loc2_:String = null;
         this.logEvent("Fault received.");
         for(_loc2_ in param1)
         {
            this.logEvent(_loc2_ + ": " + param1[_loc2_]);
         }
         if(this.m_statusCallback != null)
         {
            this.m_statusCallback(param1,this.TRANSPORT_FAILURE_AMF_FAULT,"transport failure");
         }
      }
      
      protected function onAsyncError(param1:IOErrorEvent) : void
      {
         this.logEvent("Async error: " + param1.toString());
         if(this.m_statusCallback != null)
         {
            this.m_statusCallback(param1,this.TRANSPORT_FAILURE_ASYNC_ERROR,"async failure");
         }
      }
      
      protected function onIOError(param1:IOErrorEvent) : void
      {
         this.logEvent("IO error: " + param1.toString());
         if(this.m_statusCallback != null)
         {
            this.m_statusCallback(param1,this.TRANSPORT_FAILURE_IO_ERROR,"io failure");
         }
      }
      
      protected function onNetStatus(param1:NetStatusEvent) : void
      {
         this.logEvent("Net status error: " + param1.toString());
         if(this.m_statusCallback != null)
         {
            this.m_statusCallback(param1,this.TRANSPORT_FAILURE_NET_STATUS,"net status failure");
         }
      }
      
      protected function onSecurityError(param1:SecurityErrorEvent) : void
      {
         this.logEvent("Security error: " + param1.toString());
         if(this.m_statusCallback != null)
         {
            this.m_statusCallback(param1,this.TRANSPORT_FAILURE_SECURITY_ERROR,"security failure");
         }
      }
      
      protected function logEvent(param1:String) : void
      {
         GlobalEngine.log("AMFConnection",this.m_functionName + ": " + param1);
      }
      
      public function call(param1:String, ... rest) : void
      {
         var _loc3_:Array = [param1,this.m_responder];
         this.m_functionName = param1;
         _loc3_ = _loc3_.concat(rest);
         this.m_netConnection.call.apply(this.m_netConnection,_loc3_);
         this.logEvent("Call: " + param1);
      }
   }
}

