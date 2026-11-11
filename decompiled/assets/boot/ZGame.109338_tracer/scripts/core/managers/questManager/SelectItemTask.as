package core.managers.questManager
{
   import Engine.Managers.TransactionManager;
   import core.managers.WorldObjectManager;
   import core.managers.tutorialManager.TutorialManager;
   import entity.GameDataComponent;
   import flash.events.Event;
   import transactions.TSelect;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class SelectItemTask extends ZGameTask
   {
      
      public function SelectItemTask(param1:int, param2:XML, param3:String, param4:Number)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function onSetActive(param1:Boolean) : void
      {
         if(param1)
         {
            WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_SELECTED,this.onObjectSelected,false,0,true);
         }
         else
         {
            WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_SELECTED,this.onObjectSelected);
         }
      }
      
      private function onObjectSelected(param1:WorldEvent) : void
      {
         var _loc4_:TSelect = null;
         var _loc2_:IEntity = IEntity(param1.eventData);
         var _loc3_:GameDataComponent = GameDataComponent(_loc2_.lookupComponentByType(GameDataComponent));
         if(_loc3_)
         {
            if(gameItemMatches(_loc3_.gameData,m_xml.@item.toString()))
            {
               TutorialManager.instance.dispatchEvent(new Event(TutorialManager.SELECT_CONTINUE));
               _loc4_ = new TSelect(_loc3_.gameData.code);
               TransactionManager.addTransaction(_loc4_);
               _loc4_ = null;
            }
         }
      }
   }
}

