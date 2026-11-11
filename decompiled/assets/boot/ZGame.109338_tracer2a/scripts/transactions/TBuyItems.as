package transactions
{
   import flash.utils.Dictionary;
   
   public class TBuyItems extends TZGameTransaction
   {
      
      private var m_itemData:Dictionary = null;
      
      private var m_useCash:Boolean = false;
      
      private var m_combatPhase:int = 0;
      
      private var m_isQuestSurvival:Boolean = false;
      
      private var m_deathmatch:Boolean = false;
      
      private var m_inCampaign:Boolean = false;
      
      private var m_energyDialogOpen:Boolean = false;
      
      private var m_energyToasterClicked:Boolean = false;
      
      private var m_overrideCost:int = 0;
      
      private var m_containingItemCode:String = "";
      
      private var m_screen:String = "";
      
      private var m_needResources:Boolean = false;
      
      private var m_unitCode:String = "";
      
      public function TBuyItems(param1:Dictionary, param2:Boolean, param3:Object = null, param4:int = 0)
      {
         super();
         this.m_itemData = param1;
         this.m_useCash = param2;
         this.m_overrideCost = param4;
         this.m_containingItemCode = Boolean(param3) && param3.containingItemCode != null ? param3.containingItemCode : "";
         this.m_energyDialogOpen = false;
         this.m_energyToasterClicked = false;
         this.m_combatPhase = Boolean(param3) && param3.combatPhase != null ? int(param3.combatPhase) : 0;
         this.m_isQuestSurvival = Boolean(param3) && param3.isQuestSurvival != null ? Boolean(param3.isQuestSurvival) : false;
         this.m_deathmatch = Boolean(param3) && param3.deathmatch != null ? Boolean(param3.deathmatch) : false;
         this.m_inCampaign = Boolean(param3) && param3.inCampaign != null ? Boolean(param3.inCampaign) : false;
         this.m_unitCode = Boolean(param3) && param3.unitCode != null ? param3.unitCode : "";
         this.m_energyDialogOpen = Boolean(param3) && param3.energyDialog != null ? Boolean(param3.energyDialog) : false;
         this.m_energyToasterClicked = Boolean(param3) && param3.toasterClicked != null ? Boolean(param3.toasterClicked) : false;
         this.m_screen = Boolean(param3) && param3.screen != null ? param3.screen : "";
         this.m_needResources = Boolean(param3) && param3.needResources != null ? Boolean(param3.needResources) : false;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyItems",modifiedData(this.data));
      }
      
      protected function get data() : Object
      {
         var _loc2_:String = null;
         var _loc1_:Object = new Object();
         for(_loc2_ in this.m_itemData)
         {
            _loc1_[_loc2_] = this.m_itemData[_loc2_];
         }
         return {
            "itemData":_loc1_,
            "useCash":this.m_useCash,
            "overrideCost":this.m_overrideCost,
            "containingItemCode":this.m_containingItemCode,
            "combatPhase":this.m_combatPhase,
            "deathmatch":this.m_deathmatch,
            "isQuestSurvival":this.m_isQuestSurvival,
            "campaign":this.m_inCampaign,
            "unitCode":this.m_unitCode,
            "energyDialog":this.m_energyDialogOpen,
            "toasterClicked":this.m_energyToasterClicked,
            "screen":this.m_screen,
            "needResources":this.m_needResources
         };
      }
   }
}

