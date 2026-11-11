package core.player
{
   import ZLocalization.LocalizationName;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.VillainItem;
   import core.managers.PVPManager;
   import utils.ZGameUtils;
   
   public class PlayerVillain implements IPVPPlayer
   {
      
      private var m_villainItem:VillainItem;
      
      public function PlayerVillain(param1:String)
      {
         super();
         var _loc2_:String = param1;
         this.m_villainItem = ZGlobal.gameSettings.getItemByCode(_loc2_,VillainItem) as VillainItem;
      }
      
      public function get firstName() : String
      {
         return this.m_villainItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
      }
      
      public function get name() : String
      {
         return this.m_villainItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
      }
      
      public function get portraitURL() : String
      {
         return this.m_villainItem.getCachedImage("portrait").url;
      }
      
      public function get uid() : String
      {
         return PVPManager.PVE_MARKER_KEY;
      }
      
      public function get genderTag() : String
      {
         return this.m_villainItem.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC;
      }
      
      public function get empireName() : String
      {
         var _loc1_:LocalizationName = ZLoc.tn(this.firstName,this.genderTag);
         return ZGameUtils.ZlocT("Main","WorldName",{"player":_loc1_});
      }
   }
}

