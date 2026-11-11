package core.managers
{
   import core.managers.autoActionsManager.AutoActionPanToEntity;
   import core.managers.autoActionsManager.AutoActionShowSpeechPopup;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   
   public class QuestBuildableManager extends EventDispatcher
   {
      
      public static const DIVE_SITE:String = "BB31";
      
      public static const GOLDEN_STATUE:String = "BB32";
      
      public static const REMOVE_SITE:String = "remove_site";
      
      private static var m_instance:QuestBuildableManager = null;
      
      public function QuestBuildableManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function get instance() : QuestBuildableManager
      {
         if(!m_instance)
         {
            m_instance = new QuestBuildableManager();
         }
         return m_instance;
      }
      
      public function onStart() : void
      {
         var _loc2_:AutoActionPanToEntity = null;
         var _loc3_:AutoActionShowSpeechPopup = null;
         var _loc1_:IEntity = ZGameUtils.getBuildingByCode(DIVE_SITE);
         if(!_loc1_)
         {
            return;
         }
         _loc3_ = new AutoActionShowSpeechPopup();
         _loc3_.data = {"speechId":"Speech_QuestBuildable_01"};
         _loc2_ = new AutoActionPanToEntity();
         _loc2_.data = {"target":_loc1_};
         _loc2_.setNextAction(_loc3_);
         _loc2_.nextActionTimeDelay = 3000;
         _loc2_.startAction();
      }
   }
}

