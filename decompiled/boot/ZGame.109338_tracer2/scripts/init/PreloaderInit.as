package init
{
   import Engine.Init.InitializationAction;
   import ZQuest.Classes.QuestComponentOptions;
   import ZQuest.Init.QuestInit;
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import flash.events.Event;
   import zlabs.ZConfig;
   
   public class PreloaderInit extends InitializationAction
   {
      
      public static var INIT_ID:String = "PreloaderInit";
      
      public static const QUEST_DATA_RECEIVED:String = "quest_data_received";
      
      public static const SETTINGS_DATA_RECEIVED:String = "settings_data_received";
      
      public static const LOCALE_DATA_RECEIVED:String = "locale_data_received";
      
      public static const TINIT_COMPLETE:String = "tinit_complete";
      
      private var m_questOptions:QuestComponentOptions;
      
      private var m_localeInit:Boolean = false;
      
      private var m_settingsInit:Boolean = false;
      
      private var m_questInit:Object = false;
      
      private var m_initData:Boolean = false;
      
      private var m_parameters:Object;
      
      private var questSettingsInit:QuestSettingsInit;
      
      public function PreloaderInit(param1:QuestComponentOptions, param2:Object)
      {
         super(INIT_ID);
         this.m_questOptions = param1;
         this.m_parameters = param2;
      }
      
      override public function execute() : void
      {
         if(ZGlobal.initUserData)
         {
            this.initTInit(null);
         }
         else
         {
            addEventListener(TINIT_COMPLETE,this.initTInit);
         }
      }
      
      private function initQuest(param1:Event) : void
      {
         var _loc2_:String = Config.BASE_PATH + "questSettings.xml";
         if(GlobalEngine.getFlashVar("quest_url"))
         {
            _loc2_ = this.m_parameters.quest_url as String;
         }
         this.m_questOptions.preloaderData = ZGlobal.questData;
         ZGlobal.questData = null;
         this.questSettingsInit = new QuestSettingsInit(_loc2_,this.m_questOptions);
         this.questSettingsInit.addEventListener(Event.COMPLETE,this.onQuestSettingsInit);
         this.questSettingsInit.execute();
      }
      
      protected function onQuestSettingsInit(param1:Event) : void
      {
         GlobalEngine.initializationManager.addToCompleted(this.questSettingsInit.getActionId());
         var _loc2_:QuestInit = new QuestInit(this.m_questOptions.questManager);
         _loc2_.addEventListener(Event.COMPLETE,this.onActionComplete);
         _loc2_.execute();
         this.m_questInit = true;
         this.checkCompletion();
      }
      
      protected function onActionComplete(param1:Event) : void
      {
         GlobalEngine.initializationManager.addToCompleted((param1.target as InitializationAction).getActionId());
      }
      
      private function initLocale(param1:Event) : void
      {
         var _loc2_:LocalizationInit = new LocalizationInit(this.m_parameters.localization_url);
         _loc2_.addEventListener(Event.COMPLETE,this.onActionComplete);
         _loc2_.execute();
         this.m_localeInit = true;
         this.checkCompletion();
      }
      
      private function initSettings(param1:Event) : void
      {
         var _loc2_:String = ZConfig.GAME_SETTINGS_PATH + "gameSettings.xml";
         if(this.m_parameters.game_config_url)
         {
            _loc2_ = this.m_parameters.game_config_url;
         }
         var _loc3_:GameSettingsInit = new GameSettingsInit(_loc2_);
         _loc3_.addEventListener(Event.COMPLETE,this.onActionComplete);
         _loc3_.execute();
         this.m_settingsInit = true;
         this.checkCompletion();
      }
      
      private function initTInit(param1:Event) : void
      {
         this.m_initData = true;
         this.checkCompletion();
      }
      
      private function checkCompletion() : void
      {
         if(this.m_initData)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
   }
}

