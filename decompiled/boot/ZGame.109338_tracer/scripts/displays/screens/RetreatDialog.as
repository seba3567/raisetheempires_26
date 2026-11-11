package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.ChallengeModeManager;
   import core.managers.WorldResourceManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import utils.ZGameUtils;
   import zlabs.managers.WindowManager;
   
   public class RetreatDialog extends RetreatDialogBase
   {
      
      private var m_resourceType:String = null;
      
      private var m_resourceAmount:int = 0;
      
      public function RetreatDialog(param1:String, param2:int)
      {
         this.m_resourceType = param1;
         this.m_resourceAmount = param2;
         super();
      }
      
      public static function display(param1:String, param2:int) : void
      {
         WindowManager.instance.push(new RetreatDialog(param1,param2));
      }
      
      override protected function determineBattleMode() : void
      {
         if(SurvivalModeManager.instance.isInSurvivalBattle())
         {
            m_battleClass = "survival";
            m_battleFamily = "";
         }
         else if(ChallengeModeManager.instance.isInChallengeBattle())
         {
            m_battleClass = "pvp";
            if(ChallengeModeManager.instance.currentChallengeHasStatus(ChallengeModeManager.CHALLENGE_FLAG_GLOBAL_PVP))
            {
               m_battleFamily = "gpvp";
            }
            else
            {
               m_battleFamily = "pvp";
            }
         }
         else
         {
            m_battleClass = "pve";
            m_battleFamily = ZGlobal.player.campaign.currentCampaignName;
         }
      }
      
      override protected function get ransomFailureString() : String
      {
         var _loc1_:Object = {"resource_type":WorldResourceManager.instance.getResourceFriendlyNameFromType(this.m_resourceType,GameItem.SENTENCE_FRIENDLYNAME)};
         return ZGameUtils.ZlocT("Dialogs","Ransom_InsufficientResources",_loc1_);
      }
      
      override protected function get ransomString() : String
      {
         return ZGameUtils.ZlocT("Dialogs","Ransom_RetreatCostWarning",{
            "amount":this.m_resourceAmount,
            "resource_type":WorldResourceManager.instance.getResourceFriendlyNameFromType(this.m_resourceType,GameItem.SENTENCE_FRIENDLYNAME)
         }) + "\n\n" + ZGameUtils.ZlocT("Dialogs","Ransom_AmountAtBase",{"amount":ZGlobal.player.resources.resourceAmounts[this.m_resourceType]});
      }
      
      override protected function get iconUrl() : String
      {
         return WorldResourceManager.instance.getResourceImageURLByType(this.m_resourceType);
      }
      
      override protected function handlePayRansom() : Boolean
      {
         return ZGlobal.player.payRansom(this.m_resourceType,this.m_resourceAmount);
      }
   }
}

