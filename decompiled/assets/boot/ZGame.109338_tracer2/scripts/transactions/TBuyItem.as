package transactions
{
   public class TBuyItem extends TZGameTransaction
   {
      
      private var m_combatType:String = "";
      
      private var m_buyType:String = "";
      
      private var m_itemCode:String = null;
      
      private var m_genus:String = null;
      
      private var m_family:String = null;
      
      private var m_useCash:Boolean = false;
      
      private var m_amount:int = 1;
      
      private var m_combatPhase:int = 0;
      
      private var m_deathmatch:Boolean = false;
      
      private var m_inCampaign:Boolean = false;
      
      private var m_isQuestSurvival:Boolean = false;
      
      private var m_energyDialogOpen:Boolean = false;
      
      private var m_gpvp:Boolean = false;
      
      private var m_questTreeBattle:Boolean = false;
      
      private var m_dominanceBattle:Boolean = false;
      
      private var m_energyToasterClicked:Boolean = false;
      
      private var m_screen:String = "";
      
      private var m_additionalPricetestType:String = null;
      
      private var m_needResources:Boolean = false;
      
      private var m_bundleItems:String = null;
      
      private var m_unitCode:String = "";
      
      private var m_energyMultiRequirement:Boolean = false;
      
      private var m_questId:String;
      
      public function TBuyItem(param1:String, param2:Boolean, param3:int = 1, param4:Object = null, param5:String = null, param6:String = null)
      {
         super();
         this.m_itemCode = param1;
         this.m_genus = Boolean(param4) && Boolean(param4.genus) ? param4.genus : null;
         this.m_family = Boolean(param4) && Boolean(param4.family) ? param4.family : null;
         this.m_useCash = param2;
         this.m_amount = param3;
         this.m_energyDialogOpen = false;
         this.m_energyToasterClicked = false;
         this.m_combatPhase = Boolean(param4) && param4.combatPhase != null ? int(param4.combatPhase) : 0;
         this.m_deathmatch = Boolean(param4) && param4.deathmatch != null ? Boolean(param4.deathmatch) : false;
         this.m_inCampaign = Boolean(param4) && param4.inCampaign != null ? Boolean(param4.inCampaign) : false;
         this.m_isQuestSurvival = Boolean(param4) && param4.isQuestSurvival != null ? Boolean(param4.isQuestSurvival) : false;
         this.m_unitCode = Boolean(param4) && param4.unitCode != null ? param4.unitCode : "";
         this.m_energyDialogOpen = Boolean(param4) && param4.energyDialog != null ? Boolean(param4.energyDialog) : false;
         this.m_gpvp = Boolean(param4) && param4.gpvp != null ? Boolean(param4.gpvp) : false;
         this.m_questTreeBattle = Boolean(param4) && param4.questTree != null ? Boolean(param4.questTree) : false;
         this.m_dominanceBattle = Boolean(param4) && param4.dominance != null ? Boolean(param4.dominance) : false;
         this.m_energyToasterClicked = Boolean(param4) && param4.toasterClicked != null ? Boolean(param4.toasterClicked) : false;
         this.m_combatType = Boolean(param4) && param4.combatType != null ? param4.combatType : "";
         this.m_buyType = Boolean(param4) && param4.buyType != null ? param4.buyType : "";
         this.m_screen = Boolean(param4) && param4.screen != null ? param4.screen : "";
         this.m_additionalPricetestType = param5;
         this.m_needResources = Boolean(param4) && param4.needResources != null ? Boolean(param4.needResources) : false;
         this.m_bundleItems = param6;
         this.m_energyMultiRequirement = Boolean(param4) && param4.energyMultiRequirement != null ? Boolean(param4.energyMultiRequirement) : false;
         if(this.m_questTreeBattle)
         {
            this.m_questId = Boolean(param4) && param4.questId != null ? param4.questId : "";
         }
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyItem",modifiedData(this.data));
      }
      
      protected function get data() : Object
      {
         var _loc1_:Object = {
            "code":this.m_itemCode,
            "useCash":this.m_useCash,
            "amount":this.m_amount,
            "combatPhase":this.m_combatPhase,
            "deathmatch":this.m_deathmatch,
            "campaign":this.m_inCampaign,
            "isQuestSurvival":this.m_isQuestSurvival,
            "unitCode":this.m_unitCode,
            "energyDialog":this.m_energyDialogOpen,
            "gpvp":this.m_gpvp,
            "questTree":this.m_questTreeBattle,
            "dominance":this.m_dominanceBattle,
            "toasterClicked":this.m_energyToasterClicked,
            "screen":this.m_screen,
            "pricetestType":this.m_additionalPricetestType,
            "needResources":this.m_needResources,
            "buyType":this.m_buyType,
            "combatType":this.m_combatType,
            "bundleItems":this.m_bundleItems,
            "energyMultiRequirement":this.m_energyMultiRequirement,
            "questId":this.m_questId
         };
         if(this.m_genus)
         {
            _loc1_.genus = this.m_genus;
         }
         if(this.m_family)
         {
            _loc1_.family = this.m_family;
         }
         return _loc1_;
      }
   }
}

