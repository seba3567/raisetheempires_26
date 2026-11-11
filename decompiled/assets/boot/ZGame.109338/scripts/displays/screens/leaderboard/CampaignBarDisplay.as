package displays.screens.leaderboard
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.IslandGroupItem;
   import core.gameobjects.IslandItem;
   import core.gameobjects.VillainItem;
   import core.managers.leaderboardManager.Leaderboard;
   import utils.ZGameUtils;
   
   public class CampaignBarDisplay extends BarDisplay
   {
      
      public function CampaignBarDisplay()
      {
         super();
      }
      
      override public function getScore(param1:int) : String
      {
         var _loc3_:XML = null;
         var _loc4_:IslandGroupItem = null;
         var _loc5_:IslandItem = null;
         var _loc6_:VillainItem = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc2_:Array = ZGlobal.gameSettings.getArrayOfItemXMLByType("IslandGroup");
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.@leaderboardId == Leaderboard.TYPE_CAMPAIGN)
            {
               _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_.@code,IslandGroupItem) as IslandGroupItem;
               for each(_loc5_ in _loc4_.islands)
               {
                  if(_loc5_.globalIndex == param1)
                  {
                     if(!_loc5_.unlocks && !_loc4_.unlocks)
                     {
                        return ZGameUtils.ZlocT("Leaderboards","Leaderboards_CampaignComplete");
                     }
                     _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc4_.villain,VillainItem) as VillainItem;
                     _loc7_ = _loc6_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                     _loc8_ = _loc4_.getMapNumber();
                     return ZGameUtils.ZlocT("Leaderboards","Leaderboards_Campaign",{
                        "villain":_loc7_,
                        "amount":_loc8_
                     });
                  }
               }
            }
         }
         return super.getScore(param1);
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_Battle",{"amount":param1 + 1});
      }
   }
}

