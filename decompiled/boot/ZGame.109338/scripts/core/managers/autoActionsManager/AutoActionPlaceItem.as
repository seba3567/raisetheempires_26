package core.managers.autoActionsManager
{
   import core.ZGlobal;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import events.MarketEvent;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   
   public class AutoActionPlaceItem extends AutoAction
   {
      
      public function AutoActionPlaceItem(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      override protected function performAction() : void
      {
         var _loc2_:int = 0;
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(data.item,GameItem) as GameItem;
         if(_loc1_)
         {
            _loc2_ = ZGlobal.player.getNumberOfInventoryItems(data.item);
            if(_loc2_ > 0)
            {
               GameModeManager.instance.addGameMode(new GMObjectPlace(_loc1_.name,MarketEvent.SOURCE_INVENTORY,true));
               WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onObjectPlaced);
               WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACE_CANCELLED,this.onObjectPlaced);
            }
         }
         else
         {
            startEndAction();
         }
      }
      
      private function onObjectPlaced(param1:Event) : void
      {
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onObjectPlaced);
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_PLACE_CANCELLED,this.onObjectPlaced);
         startEndAction();
      }
   }
}

