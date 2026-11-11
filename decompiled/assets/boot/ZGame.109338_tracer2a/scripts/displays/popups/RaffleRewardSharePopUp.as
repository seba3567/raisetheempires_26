package displays.popups
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.requests.RequestDialog;
   import displays.screens.requests.RequestGiftDialog;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import transactions.TRequestSendGift;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class RaffleRewardSharePopUp extends ZGamePopUp
   {
      
      private var m_initialised:Boolean = false;
      
      private var m_shareID:String = "-1";
      
      private var m_itemCode:String = "";
      
      private var m_prizeNumber:int = -1;
      
      private var sendButton:ZGameButton = null;
      
      private var cancelButton:ZGameButton = null;
      
      public function RaffleRewardSharePopUp(param1:String = "-1", param2:String = "", param3:int = -1)
      {
         this.m_shareID = param1;
         this.m_itemCode = param2;
         this.m_prizeNumber = param3;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Raffle.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setupWindow();
      }
      
      private function setupWindow() : void
      {
         if(Boolean(m_window) && !this.m_initialised)
         {
            this.m_initialised = true;
            this.initDialog();
            addChild(m_window);
         }
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onClose);
         this.sendButton = new ZGameButton(this.screen.share_bt,this.onSend);
         TextFieldUtil.compactTextField(this.screen.share_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Button_Share"));
         this.cancelButton = new ZGameButton(this.screen.cancel_bt,this.onCancel);
         TextFieldUtil.compactTextField(this.screen.cancel_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Button_Cancel"));
         TextFieldUtil.compactTextField(this.screen.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Won_Share",{"player":ZGlobal.player.findFriendById(this.m_shareID).snUser.firstName}));
         var _loc1_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.player.findFriendById(this.m_shareID).snUser.picture,this.screen.profile_mc.icon);
         _loc1_.smooth = true;
      }
      
      override protected function deinitDialog() : void
      {
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         super.deinitDialog();
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function onClose(param1:Event) : void
      {
         close();
      }
      
      private function onSend(param1:Event) : void
      {
         var _loc2_:Array = new Array();
         _loc2_.push(this.m_shareID);
         var _loc3_:String = (ZGlobal.gameSettings.getItemByCode(this.m_itemCode,GameItem) as GameItem).name;
         TransactionManager.addTransaction(new TRequestSendGift(_loc2_,_loc3_,RequestGiftDialog.RAFFLE_GIFT,RequestDialog.TYPE_GIFT,"RaffleGift"));
         StatsManager.count("game_actions","Raffle","prize_w2w",this.m_prizeNumber.toString());
         close();
      }
      
      private function onCancel(param1:Event) : void
      {
         close();
      }
   }
}

