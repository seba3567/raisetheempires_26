package core
{
   import Engine.Managers.TransactionManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.Socket;
   import flash.system.Security;
   import flash.utils.Timer;
   import transactions.TMessageFetch;
   import transactions.TMessagePresence;
   import transactions.TZoom;
   
   public class Zlingshot extends EventDispatcher
   {
      
      public static var fetchTimer:Timer;
      
      public static var presenceTimer:Timer;
      
      private static var m_instance:Zlingshot;
      
      private static var m_messages:Array;
      
      protected static var m_zoomServer:String;
      
      private static var m_retryDelaySeconds:Number;
      
      public static var firstStamp:Number = 0;
      
      private static const DEFAULT_RETRY_DELAY:Number = 1;
      
      private static const MAX_RETRY_DELAY:Number = 30;
      
      private static const MESSAGE_FETCH_INTERVAL:Number = 60;
      
      private static const PRESENCE_INTERVAL:Number = 275;
      
      protected static var m_zoomPort:Number = 8890;
      
      private static var m_zoomPolicyOK:Boolean = false;
      
      private static var m_namespace:String = null;
      
      private static var m_lastStamp:Number = 0;
      
      private static var m_socket:Socket = null;
      
      private static var m_socketBuffer:String = "";
      
      private static var m_fetchTransaction:TMessageFetch = null;
      
      public function Zlingshot(param1:Boolean = true, param2:Boolean = true)
      {
         super();
         if(param1)
         {
            m_namespace = this.namespace;
            m_retryDelaySeconds = DEFAULT_RETRY_DELAY;
            TransactionManager.addTransaction(new TZoom());
         }
         if(param2)
         {
            presenceTimer = new Timer(PRESENCE_INTERVAL * 1000,1);
            presenceTimer.addEventListener(TimerEvent.TIMER,this.presence);
            this.presence();
         }
         m_instance = this;
      }
      
      public static function get instance() : Zlingshot
      {
         return m_instance;
      }
      
      protected function debugLog(param1:String) : void
      {
         trace(param1);
      }
      
      protected function get namespace() : String
      {
         return GlobalEngine.getFlashVar("sn_app_url").toString().split("/")[3];
      }
      
      protected function get playerUid() : String
      {
         return "0";
      }
      
      protected function get hostPlayerUid() : String
      {
         return "0";
      }
      
      protected function handle(param1:Object, param2:Number) : void
      {
         var _loc3_:String = null;
         this.debugLog("Zlingshot: Received message timestamp=" + param2 + " uid=" + this.playerUid);
         for(_loc3_ in param1)
         {
            this.debugLog("  " + _loc3_ + ": " + param1[_loc3_]);
         }
      }
      
      protected function zoomConnect(param1:Event = null) : void
      {
         this.zoomPolicy();
         if(m_socket == null || !m_socket.connected)
         {
            m_socket = new Socket(m_zoomServer,m_zoomPort);
            m_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.zoomError);
            m_socket.addEventListener(ProgressEvent.SOCKET_DATA,this.zoomRead);
            m_socket.addEventListener(Event.CONNECT,this.zoomConnected);
            m_socket.addEventListener(IOErrorEvent.IO_ERROR,this.zoomError);
            m_socket.addEventListener(Event.CLOSE,this.zoomError);
         }
         else
         {
            this.debugLog("Zlingshot: Zoom already connected?");
         }
      }
      
      protected function setZoomPort(param1:Number) : void
      {
         m_zoomPort = param1;
      }
      
      public function setZoomServer(param1:String) : void
      {
         this.debugLog("Zlingshot: Setting zoom server to " + param1 + ":" + m_zoomPort);
         m_zoomServer = param1;
         m_zoomPolicyOK = false;
         m_retryDelaySeconds = DEFAULT_RETRY_DELAY;
         if(m_socket != null && m_socket.connected)
         {
            m_socket.close();
         }
         else
         {
            this.zoomConnect();
            fetchTimer = new Timer(MESSAGE_FETCH_INTERVAL * 1000,1);
            fetchTimer.addEventListener(TimerEvent.TIMER,this.fetch);
            this.fetch();
         }
      }
      
      protected function zoomConnected(param1:Event) : void
      {
         m_zoomPolicyOK = true;
         this.debugLog("Zlingshot: Zoom connected to " + m_zoomServer + ":" + m_zoomPort);
         m_socket.writeUTFBytes("3 session " + this.hostPlayerUid + " 81 0 0 0\n");
         m_socket.flush();
      }
      
      protected function zoomRead(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:String = null;
         m_socketBuffer += m_socket.readUTFBytes(m_socket.bytesAvailable);
         while(true)
         {
            _loc2_ = m_socketBuffer.indexOf("\n");
            if(_loc2_ <= 0)
            {
               break;
            }
            _loc3_ = m_socketBuffer.substr(0,_loc2_);
            m_socketBuffer = m_socketBuffer.substr(_loc2_ + 1);
            this.zoomHandle(_loc3_);
         }
      }
      
      protected function zoomHandle(param1:String) : void
      {
         var _loc2_:Array = param1.split(" ");
         if(_loc2_[2] == m_namespace)
         {
            this.debugLog("Zlingshot: Zoom notification! New data to fetch!");
            this.fetch();
            m_socketBuffer = "";
         }
      }
      
      protected function zoomError(param1:Event) : void
      {
         this.debugLog("Zlingshot: Zoom I/O error!  Closing connection and retrying...");
         if(m_socket != null)
         {
            m_socket.close();
            m_socket = null;
         }
         this.zoomRetry();
      }
      
      protected function zoomRetry(param1:Event = null) : void
      {
         var _loc2_:Timer = null;
         m_retryDelaySeconds *= 2;
         if(m_retryDelaySeconds >= MAX_RETRY_DELAY)
         {
            TransactionManager.addTransaction(new TZoom());
         }
         else
         {
            this.debugLog("Zlingshot: Zoom retrying in " + m_retryDelaySeconds + "s.");
            _loc2_ = new Timer(m_retryDelaySeconds * 1000,1);
            _loc2_.addEventListener(TimerEvent.TIMER,this.zoomConnect);
            _loc2_.start();
         }
      }
      
      protected function zoomPolicy() : void
      {
         var _loc1_:Socket = null;
         if(!m_zoomPolicyOK)
         {
            Security.allowDomain("*");
            Security.allowInsecureDomain("*");
            _loc1_ = new Socket();
            _loc1_.addEventListener(IOErrorEvent.IO_ERROR,this.zoomPolicyError);
            _loc1_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.zoomPolicyError);
            _loc1_.connect(m_zoomServer,843);
            _loc1_.close();
         }
      }
      
      protected function zoomPolicyError(param1:Event) : void
      {
         this.debugLog("Zlingshot: Could not fetch socket policy file from " + m_zoomServer + ":843");
         m_zoomPolicyOK = false;
      }
      
      protected function fetch(param1:Event = null) : void
      {
         if(m_fetchTransaction == null || !m_fetchTransaction.inQueue)
         {
            m_fetchTransaction = new TMessageFetch(m_lastStamp);
            TransactionManager.addTransaction(m_fetchTransaction);
         }
      }
      
      public function set messages(param1:Array) : void
      {
         var _loc3_:* = undefined;
         m_messages = param1;
         var _loc2_:Number = 0;
         if(Boolean(param1) && param1.length > 0)
         {
            for each(_loc3_ in param1)
            {
               if(_loc3_.timestamp > m_lastStamp || m_lastStamp <= 0)
               {
                  if(_loc3_.timestamp > _loc2_)
                  {
                     _loc2_ = Number(_loc3_.timestamp);
                  }
                  if(_loc3_.timestamp > firstStamp)
                  {
                     this.handle(_loc3_.hash,_loc3_.timestamp);
                  }
               }
            }
            if(_loc2_ > 0)
            {
               m_lastStamp = _loc2_;
            }
         }
      }
      
      protected function presence(param1:Event = null) : void
      {
         TransactionManager.addTransaction(new TMessagePresence(this.hostPlayerUid));
      }
   }
}

