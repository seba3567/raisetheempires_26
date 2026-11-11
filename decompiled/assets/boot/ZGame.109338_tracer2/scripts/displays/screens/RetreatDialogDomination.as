package displays.screens
{
   import core.ZGlobal;
   import core.managers.domination.DominationModeManager;
   import utils.ZGameUtils;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class RetreatDialogDomination extends RetreatDialogBase
   {
      
      private var m_enemyID:String;
      
      public function RetreatDialogDomination(param1:String)
      {
         this.m_enemyID = param1;
         super();
      }
      
      public static function display(param1:String) : void
      {
         if(param1)
         {
            WindowManager.instance.push(new RetreatDialogDomination(param1));
         }
      }
      
      override protected function determineBattleMode() : void
      {
         m_battleClass = "domination";
         m_battleFamily = "";
      }
      
      override protected function get assetUrl() : String
      {
         return "assets/displays/dialogs/PU_Pvp_Ransom.swf";
      }
      
      override protected function get ransomFailureString() : String
      {
         return "";
      }
      
      override protected function get ransomString() : String
      {
         return ZGameUtils.ZlocT("Dialogs","Ransom_msg_Domination",{"amount":this.ransomAmount});
      }
      
      override protected function get iconUrl() : String
      {
         var _loc1_:String = "assets/game/PvpGeneralAssetGroup_UI.swf/DominanceStar_60.png";
         return ZGlobal.getAssetURL(_loc1_);
      }
      
      override protected function handlePayRansom() : Boolean
      {
         return true;
      }
      
      private function get ransomAmount() : int
      {
         var _loc1_:Object = DominationModeManager.instance.getDominationInfo(this.m_enemyID);
         if(_loc1_)
         {
            return DominationModeManager.instance.getRetreatPenalty(_loc1_);
         }
         return 0;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         dialogMC.generic01_mc.orange_bt.visible = false;
         dialogMC.generic01_mc.red_bt.visible = false;
      }
   }
}

