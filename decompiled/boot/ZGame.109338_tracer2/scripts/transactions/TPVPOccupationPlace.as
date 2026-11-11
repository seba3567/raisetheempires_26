package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   import flash.geom.Point;
   
   public class TPVPOccupationPlace extends Transaction
   {
      
      private var m_pos:Point;
      
      public function TPVPOccupationPlace(param1:Point)
      {
         super();
         this.m_pos = param1;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.occupationPlace",ZGlobal.hostPlayer.uid,this.m_pos.x,this.m_pos.y);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:Object = null;
         super.onComplete(param1);
         if(param1 == ChallengeModeManager.ERR_CANT_INVADE_IMMUNITY_ON)
         {
            ChallengeModeManager.instance.cantInvadeImmunityPopup();
            _loc2_ = new Object();
            _loc2_.immunity = {"expTS":ChallengeModeManager.ERR_CANT_INVADE_IMMUNITY_ON};
            _loc2_.victim = ZGlobal.hostPlayer.uid;
            _loc2_.status = PVPManager.INVASION_COMPLETE_IMMUNE;
            _loc2_.dontShowError = true;
            PVPManager.instance.performLastMinuteImmunity(_loc2_);
         }
         else if(param1 == ChallengeModeManager.ERR_CANT_INVADE_AREA_IMMUNE)
         {
            ChallengeModeManager.instance.cantInvadeAreaImmunePopup();
            PVPManager.instance.performLastMinuteAreaImmune();
         }
      }
   }
}

