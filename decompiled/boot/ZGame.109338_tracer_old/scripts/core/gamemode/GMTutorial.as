package core.gamemode
{
   import core.gamemode.avatar.GMAvatar;
   import core.managers.tutorialManager.TutorialManager;
   import entity.GameDataComponent;
   import flash.events.MouseEvent;
   import zlabs.entity.IEntity;
   
   public class GMTutorial extends GMAvatar
   {
      
      private static var m_quest:String = null;
      
      private static var m_uiHighlighted:String = null;
      
      private static var m_uiStoreTabIndex:String = null;
      
      private static var m_uiStencil:String = null;
      
      public function GMTutorial()
      {
         super();
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
      }
      
      override protected function canBeSelected(param1:IEntity) : Boolean
      {
         var _loc2_:GameDataComponent = null;
         if(param1)
         {
            _loc2_ = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
            if(_loc2_ != null)
            {
               if(TutorialManager.instance.isLocked(_loc2_.gameData.code))
               {
                  return false;
               }
            }
         }
         return super.canBeSelected(param1);
      }
      
      override protected function canBeClicked(param1:MouseEvent) : Boolean
      {
         if(this.canBeSelected(m_highlightedObject))
         {
            return super.canBeClicked(param1);
         }
         return true;
      }
   }
}

