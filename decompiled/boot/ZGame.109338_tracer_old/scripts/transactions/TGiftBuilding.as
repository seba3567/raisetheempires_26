package transactions
{
   import core.ZGlobal;
   import displays.popups.SpeechPopup;
   import zlabs.entity.IEntity;
   import zlabs.managers.PopupManager;
   
   public class TGiftBuilding extends TWorldState
   {
      
      public static const HORTEN_BOMBER:String = "UB90";
      
      public static const BULL_TANK:String = "UN13";
      
      public static const VARUN_SUBMARINE:String = "UT94";
      
      public static const WORLDGAMES_GOLDMEDAL:String = "WGM";
      
      private var m_item:Object;
      
      public function TGiftBuilding(param1:IEntity, param2:Object = null)
      {
         this.m_item = param2;
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("GiftBuilding",this.m_item);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:String = null;
         super.onComplete(param1);
         if(Boolean(param1.item) && this.m_item != null)
         {
            if(ZGlobal.player.getNumberOfInventoryItems(WORLDGAMES_GOLDMEDAL) >= 5)
            {
               ZGlobal.player.removeInventoryItem(WORLDGAMES_GOLDMEDAL,5);
               ZGlobal.player.addToInventory(BULL_TANK,1,true);
            }
            if(ZGlobal.player.getNumberOfInventoryItems(WORLDGAMES_GOLDMEDAL) >= 5)
            {
               ZGlobal.player.removeInventoryItem(WORLDGAMES_GOLDMEDAL,5);
               ZGlobal.player.addToInventory(VARUN_SUBMARINE,1,true);
            }
            if(ZGlobal.player.getNumberOfInventoryItems(WORLDGAMES_GOLDMEDAL) >= 5)
            {
               ZGlobal.player.removeInventoryItem(WORLDGAMES_GOLDMEDAL,5);
               ZGlobal.player.addToInventory(HORTEN_BOMBER,1,true);
            }
            for(_loc2_ in param1.item)
            {
               if(_loc2_ == "WGS2")
               {
                  if(param1.item[_loc2_] > 0)
                  {
                     ZGlobal.player.addToInventory(_loc2_,param1.item[_loc2_],true);
                     PopupManager.instance.push(new SpeechPopup("Speech_WorldGames_03"),0,true,false);
                  }
                  else
                  {
                     PopupManager.instance.push(new SpeechPopup("Speech_WorldGames_04"),0,true,false);
                  }
               }
            }
         }
      }
   }
}

