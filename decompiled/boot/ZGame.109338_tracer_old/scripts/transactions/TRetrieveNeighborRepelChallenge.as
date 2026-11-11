package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   import core.player.IPVPPlayer;
   import displays.popups.PVPCombatStartPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   
   public class TRetrieveNeighborRepelChallenge extends Transaction
   {
      
      private static const CANT_GET_NEIGHBOR_REPEL_CHALLENGE:int = 100;
      
      private var m_neighborID:String;
      
      private var m_invaderID:String;
      
      public function TRetrieveNeighborRepelChallenge(param1:String, param2:String)
      {
         super();
         this.m_neighborID = param1;
         this.m_invaderID = param2;
         var _loc3_:IPVPPlayer = PVPManager.instance.getPVPPlayer(param2);
         var _loc4_:PVPCombatStartPopup = new PVPCombatStartPopup(ZGlobal.player,_loc3_);
         PVPManager.instance.setAndShowCombatPopup(_loc4_);
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.retrieveNeighborRepelChallenge",this.m_neighborID,this.m_invaderID);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         PVPManager.instance.clearCombatPopup();
         if(Boolean(param1.errCode) && param1.errCode == CANT_GET_NEIGHBOR_REPEL_CHALLENGE)
         {
            PopupManager.instance.push(GenericPopup1B.NewOk(ZGameUtils.ZlocT("Dialogs","InvalidFleetChallengeText"),ZGameUtils.ZlocT("Dialogs","InvalidFleetChallengeTitle"),null));
         }
         else
         {
            ChallengeModeManager.instance.onRetrievedNeighborRepelChallenge(param1,this.m_neighborID,this.m_invaderID);
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
         PVPManager.instance.clearCombatPopup();
      }
   }
}

