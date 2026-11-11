package displays.screens.requests
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.MatchMakingManager;
   import core.ui.PlayerFeedbackManager;
   import displays.screens.PlayerCardEPGiftSend;
   import displays.screens.RequestDialogCardInterface;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import transactions.TEPGiftSelectRecipients;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.WindowManager;
   
   public class EPGiftSendFriendSelectDialog extends RequestDialog
   {
      
      private static const ICON_PATH:String = "assets/game/quests/Quests_Icons_0.swf/Ep_Gift_96.png";
      
      private var m_amounts:Dictionary = new Dictionary();
      
      public function EPGiftSendFriendSelectDialog()
      {
         var _loc4_:Array = null;
         StatsManager.count("dialog","multi_friend_gifter","view");
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","EPGiftSendFriendSelectTitle");
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","EPGiftSendFriendSelectBody");
         var _loc3_:String = ZGlobal.getAssetURL(ICON_PATH);
         if(MatchMakingManager.instance.isActive())
         {
            _loc4_ = this.getMatchmadeNeighbors().concat(ZGlobal.player.empireFriends);
         }
         else
         {
            _loc4_ = ZGlobal.player.empireFriends;
         }
         super(_loc4_,_loc1_,_loc2_,"",_loc3_,"friendflash",SUBTYPE_NONE);
      }
      
      public static function show() : void
      {
         var _loc1_:EPGiftSendFriendSelectDialog = new EPGiftSendFriendSelectDialog();
         WindowManager.instance.push(_loc1_,0,true);
      }
      
      override public function isNewMFSDialog() : Boolean
      {
         return false;
      }
      
      override public function get _mfsp2() : Boolean
      {
         return false;
      }
      
      override protected function createCard(param1:Object) : RequestDialogCardInterface
      {
         var _loc2_:int = param1 ? int(this.m_amounts[param1.uid]) : 0;
         return new PlayerCardEPGiftSend(param1,this.amountUpdatedCallback,this.canAddCallback,_loc2_);
      }
      
      private function canAddCallback() : Boolean
      {
         var _loc1_:int = this.amountAllocated;
         var _loc2_:int = ZGlobal.player.friendFlashEPBank;
         return _loc1_ < _loc2_;
      }
      
      private function amountUpdatedCallback(param1:String, param2:int) : void
      {
         this.m_amounts[param1] = param2;
         updateSendButton();
         this.updateProgressBar();
      }
      
      override protected function sortFriends() : void
      {
         sortArrayAlphabetically(friends,0,friends.length - 1);
      }
      
      override protected function calculateMaxFriends() : uint
      {
         return int.MAX_VALUE;
      }
      
      override protected function initSelectAllButton() : void
      {
         mc.selectAll_btn.selectAll_mc.visible = false;
      }
      
      override protected function get sendButtonString() : String
      {
         return ZGameUtils.ZlocT("Dialogs","EPGiftSendSendButtonString");
      }
      
      override protected function initPlaceholders() : void
      {
         mc.key_mc.visible = false;
         mc.tipbkgd_mc.visible = false;
         mc.placeholder_tf.visible = false;
         mc.placeholder_tf2.visible = false;
      }
      
      override protected function onSendClicked(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:TEPGiftSelectRecipients = null;
         var _loc2_:Object = this.transactionData;
         if(Boolean(_loc2_.data) && Boolean(_loc2_.data.length))
         {
            _loc3_ = ZGameUtils.ZlocT("Main","FriendFlashEPGiftSendFeedback");
            PlayerFeedbackManager.instance.displayToaster(_loc3_);
            _loc4_ = new TEPGiftSelectRecipients(_loc2_.data,_loc2_.total);
            TransactionManager.addTransaction(_loc4_,true);
         }
         close();
      }
      
      private function get transactionData() : Object
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc1_:Array = new Array();
         for(_loc3_ in this.m_amounts)
         {
            _loc4_ = int(this.m_amounts[_loc3_]);
            if(_loc4_)
            {
               _loc1_.push(_loc3_ + ":" + _loc4_);
               _loc2_ += _loc4_;
            }
         }
         return {
            "data":_loc1_,
            "total":_loc2_
         };
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
      }
      
      override protected function updateProgressBar(param1:Boolean = true) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = ZGlobal.player.friendFlashEPBank;
         var _loc4_:int = this.amountAllocated;
         var _loc5_:int = 0;
         if(_loc3_ < 1)
         {
            _loc2_ = 0;
         }
         else
         {
            _loc5_ = _loc3_ - this.amountAllocated;
            _loc2_ = Number(_loc5_ / _loc3_);
            _loc2_ = Math.max(0,Math.min(1,_loc2_));
         }
         var _loc6_:int = mc.progressBar_mc.base_mc.width * _loc2_;
         if(param1)
         {
            TweenLite.to(this.meterMC,0.5,{"width":_loc6_});
         }
         else
         {
            this.meterMC.width = _loc6_;
         }
         var _loc7_:Object = {
            "remaining":_loc5_,
            "available":_loc3_
         };
         var _loc8_:String = ZGameUtils.ZlocT("Dialogs","EPGiftSendProgressBarString",_loc7_);
         TextFieldUtil.compactTextField(mc.progressBar_mc.counter_tf,_loc8_);
      }
      
      private function get amountAllocated() : int
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         for(_loc2_ in this.m_amounts)
         {
            _loc1_ += this.m_amounts[_loc2_];
         }
         return _loc1_;
      }
      
      override protected function get shouldEnableSendButton() : Boolean
      {
         return this.amountAllocated > 0;
      }
      
      override protected function get meterMC() : MovieClip
      {
         return mc.progressBar_mc.meter_ep_mc;
      }
      
      private function getMatchmadeNeighbors() : Array
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc1_:Dictionary = ZGlobal.player.neighbors;
         var _loc2_:Array = new Array();
         for each(_loc3_ in _loc1_)
         {
            if(MatchMakingManager.instance.isMatchMadeNeighbor(_loc3_.uid))
            {
               _loc4_ = new Object();
               _loc4_.zid = _loc4_.uid = _loc3_.uid;
               _loc4_.name = _loc4_.first_name = _loc3_.name;
               _loc4_.last_name = "";
               _loc4_.picture = _loc3_.matchMakingData.image;
               _loc4_.is_app_user = true;
               _loc2_.push(_loc4_);
            }
         }
         return _loc2_;
      }
   }
}

