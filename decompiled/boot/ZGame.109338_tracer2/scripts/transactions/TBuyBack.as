package transactions
{
   import core.ZGlobal;
   
   public class TBuyBack extends TZGameTransaction
   {
      
      private var m_code:String = null;
      
      private var m_isSurvivalMode:Boolean = false;
      
      public function TBuyBack(param1:String, param2:Boolean = false)
      {
         super();
         this.m_code = param1;
         this.m_isSurvivalMode = param2;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyBack",modifiedData(this.data));
      }
      
      protected function get data() : Object
      {
         return {
            "uic":this.m_code,
            "isSurvivalMode":this.m_isSurvivalMode,
            "questId":ZGlobal.player.m_currentQuestBattleId
         };
      }
   }
}

