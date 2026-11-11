package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.MatchMakingManager;
   import core.player.Player;
   import displays.popups.genericPopup.ModalPopup;
   import flash.utils.Dictionary;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   
   public class TMatchMaking extends Transaction
   {
      
      private var m_model:ModalPopup = null;
      
      public function TMatchMaking()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("DataServicesService.getMatchmakingUsersData");
      }
      
      override public function preAddTransaction() : void
      {
         var _loc1_:String = "WorldParliamentSuggestions";
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs",_loc1_);
         this.m_model = new ModalPopup(_loc2_);
         PopupManager.instance.push(this.m_model,0,false,false);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Dictionary = null;
         if(this.m_model)
         {
            this.m_model.pop();
            this.m_model = null;
         }
         if(param1)
         {
            _loc2_ = Boolean(param1.MatchMakingOptIn);
            if(_loc2_ != MatchMakingManager.instance.optIn)
            {
               MatchMakingManager.instance.optFlag = _loc2_;
            }
         }
         if(!param1 || !param1.matchMakingData)
         {
            MatchMakingManager.instance.initialized = true;
            MatchMakingManager.instance.showDialog();
            return;
         }
         if(param1.matchMakingData)
         {
            _loc3_ = this.getMatchMakingData(param1.matchMakingData);
            MatchMakingManager.instance.init(_loc3_);
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
      }
      
      protected function getMatchMakingData(param1:Object) : Dictionary
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc2_:Dictionary = new Dictionary();
         if(param1)
         {
            _loc3_ = [];
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc2_[param1[_loc4_].uid] = param1[_loc4_];
               _loc3_.push(param1[_loc4_].uid);
               _loc4_++;
            }
            ZGlobal.player.setCategorizedFriends(_loc3_,Player.FRIENDS_MATCHMAKING);
         }
         return _loc2_;
      }
   }
}

