package ZQuest.Init
{
   import Engine.Init.InitializationAction;
   import ZQuest.Classes.Quest;
   import ZQuest.Classes.QuestComponentOptions;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class QuestSettingsInit extends InitializationAction
   {
      
      private static var m_instance:QuestSettingsInit;
      
      public static const INIT_ID:String = "ZQuestSettingsInit";
      
      private var m_settingsUrl:String;
      
      protected var m_xml:XMLList;
      
      protected var m_quests:Dictionary = new Dictionary();
      
      protected var m_rawXml:XML;
      
      private var m_questOptions:QuestComponentOptions;
      
      public function QuestSettingsInit(param1:String, param2:QuestComponentOptions)
      {
         super(INIT_ID);
         this.m_settingsUrl = param1;
         this.m_questOptions = param2;
         m_instance = this;
      }
      
      public static function getInstance() : QuestSettingsInit
      {
         return m_instance;
      }
      
      override public function execute() : void
      {
         var _loc1_:URLLoader = null;
         if(Boolean(this.m_questOptions.preloaderData) && this.m_questOptions.preloaderData != "0")
         {
            trace("Using Prefetched questsettings");
            this.prepareXML(this.m_questOptions.preloaderData);
         }
         else
         {
            _loc1_ = new URLLoader();
            if(this.m_questOptions.compressedXML)
            {
               _loc1_.dataFormat = URLLoaderDataFormat.BINARY;
            }
            _loc1_.addEventListener(Event.COMPLETE,this.onConfigXmlLoaded);
            _loc1_.load(new URLRequest(this.m_settingsUrl));
         }
      }
      
      protected function onConfigXmlLoaded(param1:Event) : void
      {
         this.prepareXML(param1.target.data);
      }
      
      protected function prepareXML(param1:*) : void
      {
         if(this.m_questOptions.compressedXML)
         {
            trace("Compressed xml");
            param1.uncompress();
         }
         var _loc2_:XML = XML(param1.toString());
         this.m_rawXml = _loc2_;
         this.m_xml = this.m_rawXml..quests;
         if(this.m_xml.length > 0)
         {
            this.m_xml = this.m_xml[0];
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function getItemByName(param1:String) : Quest
      {
         var _loc3_:XML = null;
         var _loc2_:Quest = this.m_quests[param1];
         if(_loc2_ == null)
         {
            _loc3_ = this.getQuestXMLByName(param1);
            if(_loc3_ != null)
            {
               _loc2_ = new this.m_questOptions.questClass(_loc3_);
               this.m_quests[param1] = _loc2_;
            }
         }
         return _loc2_;
      }
      
      protected function getQuestXMLByName(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var nameStr:String = param1;
         if(Config.usingIndexedSettings)
         {
            list = this.m_rawXml[nameStr];
         }
         else
         {
            list = this.m_rawXml.quest.(@name == nameStr);
         }
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function get rawXML() : XML
      {
         return this.m_rawXml;
      }
      
      public function get isClientPredictionEnabled() : Boolean
      {
         return this.m_questOptions.questUtility != null;
      }
      
      public function get getClientPredictionClass() : Class
      {
         return this.m_questOptions.questUtility;
      }
   }
}

