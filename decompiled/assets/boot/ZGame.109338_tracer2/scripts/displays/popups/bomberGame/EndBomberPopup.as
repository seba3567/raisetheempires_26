package displays.popups.bomberGame
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import core.managers.miniGameManager.BomberGameManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericCountdownClock;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import transactions.TBuyBomberFuel;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class EndBomberPopup extends ZGamePopUp
   {
      
      public static const MAX_ANGLE:Number = 135;
      
      public static const MIN_ANGLE:Number = 0;
      
      public static const TRESHOLD_TIME:Number = 300;
      
      private var m_buyPopup:GenericPopup2B;
      
      private var m_loaders:Array = null;
      
      protected var m_clock:GenericCountdownClock;
      
      protected var count:int = 0;
      
      protected var m_exitButton:ZGameButton;
      
      protected var m_acceptButton:ZGameButton;
      
      public function EndBomberPopup(param1:String)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_EndGameBomber.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         m_window = param1.clip.screen_mc;
         this.setupUI();
      }
      
      protected function setupUI() : void
      {
         m_origOffsetX = m_window.x;
         m_origOffsetY = m_window.y;
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         centerWithinStage(Zlab.mainStage);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked);
         var _loc1_:Number = BomberGameManager.instance.Fuel;
         var _loc2_:Number = (MAX_ANGLE - MIN_ANGLE) / BomberGameManager.instance.TotalFuel * BomberGameManager.instance.Fuel;
         if(_loc2_ <= MIN_ANGLE)
         {
            _loc2_ = MIN_ANGLE;
         }
         if(_loc2_ >= MAX_ANGLE)
         {
            _loc2_ = MAX_ANGLE;
         }
         m_window.meter_mc.mask_mc.width = _loc2_;
         if(_loc1_ > 0)
         {
            TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","BomberEndGameTitle2"));
            m_window.clock_mc.visible = false;
            m_window.note_tf.visible = false;
            TextFieldUtil.compactTextField(m_window.popupBox_tf,ZGameUtils.ZlocT("Dialogs","BomberEndGameNote2"));
            m_window.popupBox_tf.visible = true;
            this.setUpContinueButton();
         }
         else
         {
            TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","BomberEndGameTitle"));
            TextFieldUtil.compactTextField(m_window.note_tf,ZGameUtils.ZlocT("Dialogs","BomberEndGameNote"));
            m_window.popupBox_tf.visible = false;
            m_window.note_tf.visible = true;
            this.setUpTimer();
            m_window.clock_mc.visible = true;
            this.setUpBuyButton();
         }
         this.addRewardsToUI();
         addChild(m_window);
      }
      
      private function setUpContinueButton() : void
      {
         this.m_acceptButton = new ZGameButton(m_window.accept_bt,this.onContinueClicked);
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","BomberEndGameAcceptButton2");
         this.m_acceptButton.compactText(_loc1_,{
            "maxLines":1,
            "minScale":0.4,
            "onFail":"return"
         });
         m_window.accept_bt.cashIcon_mc.visible = false;
      }
      
      private function setUpBuyButton() : void
      {
         StatsManager.count("dialog","mini_game","refuel");
         this.m_acceptButton = new ZGameButton(m_window.accept_bt,this.onBuyFuelClicked);
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(BomberGameManager.BOMBER_FUEL_CODE,GameItem) as GameItem;
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","BomberEndGameAcceptButton",{"cost":_loc1_.cash});
         this.m_acceptButton.compactText(_loc2_,{
            "maxLines":1,
            "minScale":0.4,
            "onFail":"return"
         });
         m_window.accept_bt.cashIcon_mc.visible = true;
      }
      
      private function onContinueClicked(param1:MouseEvent = null) : void
      {
         this.close();
         BomberGameManager.instance.startBomberGame();
      }
      
      private function setUpTimer() : void
      {
         var _loc1_:Number = BomberGameManager.instance.lastPlayedTime + Number(BomberGameManager.MINIGAME_COOLDOWN_TIME);
         this.m_clock = new GenericCountdownClock(m_window.clock_mc,_loc1_,null,false,true);
         m_window.clock_mc.num_tf1_red.visible = false;
         m_window.clock_mc.num_tf2_red.visible = false;
         m_window.clock_mc.num_tf1.visible = false;
         m_window.clock_mc.num_tf2.visible = false;
         var _loc2_:Number = GlobalEngine.serverTime / 1000;
         var _loc3_:Number = Math.floor(BomberGameManager.instance.lastPlayedTime + BomberGameManager.MINIGAME_COOLDOWN_TIME - _loc2_);
         if(_loc3_ < TRESHOLD_TIME)
         {
            Zlab.processManager.schedule(_loc3_ * 1000,this,this.onContinueClicked);
         }
      }
      
      private function onUpdate() : void
      {
      }
      
      private function getRewardClips(param1:int) : Array
      {
         var _loc2_:Array = null;
         switch(param1)
         {
            case 0:
               _loc2_ = [];
               m_window.rewards_even.visible = false;
               m_window.rewards_odd.visible = false;
               break;
            case 1:
               _loc2_ = [m_window.rewards_odd.reward2_mc];
               m_window.rewards_even.visible = false;
               m_window.rewards_odd.visible = true;
               m_window.rewards_odd.reward1_mc.visible = false;
               m_window.rewards_odd.reward3_mc.visible = false;
               break;
            case 2:
               _loc2_ = [m_window.rewards_even.reward1_mc,m_window.rewards_even.reward2_mc];
               m_window.rewards_even.visible = true;
               m_window.rewards_odd.visible = false;
               break;
            default:
               _loc2_ = [m_window.rewards_odd.reward2_mc,m_window.rewards_odd.reward1_mc,m_window.rewards_odd.reward3_mc];
               m_window.rewards_even.visible = false;
               m_window.rewards_odd.visible = true;
         }
         return _loc2_;
      }
      
      private function addRewardsToUI() : void
      {
         var _loc6_:ImageLoader = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:GameItem = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc1_:Array = BomberGameManager.instance.rewards;
         var _loc2_:Array = this.getRewardClips(_loc1_.length);
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         this.m_loaders = new Array();
         if(_loc2_.length == 0)
         {
            TextFieldUtil.compactTextField(m_window.title01_tf,ZGameUtils.ZlocT("Dialogs","BomberEndGameSubtitle2"));
         }
         else
         {
            TextFieldUtil.compactTextField(m_window.title01_tf,ZGameUtils.ZlocT("Dialogs","BomberEndGameSubtitle"));
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_.length)
         {
            _loc2_[_loc5_].visible = true;
            _loc2_[_loc5_].buy_bt.visible = false;
            _loc8_ = _loc1_[_loc1_.length - 1 - _loc5_].split(",");
            if(_loc8_[1] == "xp" || _loc8_[1] == "cash")
            {
               if(_loc8_[1] == "xp")
               {
                  _loc7_ = "assets/game/GeneralAssetGroup_UI.swf/Star_60.png";
                  TextFieldUtil.compactTextField(_loc2_[_loc5_].name_tf,ZGameUtils.ZlocT("Main","XP"));
                  TextFieldUtil.compactTextField(_loc2_[_loc5_].qty_tf,"x" + _loc8_[2]);
               }
               else
               {
                  _loc7_ = "assets/game/GeneralAssetGroup_UI.swf/EmpirePoints_60.png";
                  TextFieldUtil.compactTextField(_loc2_[_loc5_].name_tf,ZGameUtils.ZlocT("Main","Cash"));
                  TextFieldUtil.compactTextField(_loc2_[_loc5_].qty_tf,"x" + _loc8_[2]);
               }
               _loc6_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc7_),_loc2_[_loc5_].uiloader_mc);
               _loc6_.smooth = true;
               this.m_loaders.push(_loc6_);
            }
            else
            {
               _loc9_ = ZGlobal.gameSettings.getItemByCode(_loc8_[1],GameItem) as GameItem;
               if(_loc9_ == null)
               {
                  _loc7_ = WorldResourceManager.instance.getResourceImageURLByType(_loc8_[1],WorldResourceManager.XTRA_LARGE_ICON);
                  _loc11_ = WorldResourceManager.instance.getResourceFriendlyNameFromType(_loc8_[1],GameItem.MENU_FRIENDLYNAME);
                  TextFieldUtil.compactTextField(_loc2_[_loc5_].name_tf,_loc11_);
                  TextFieldUtil.compactTextField(_loc2_[_loc5_].qty_tf,"x" + _loc8_[2]);
                  _loc6_ = ImageLoaderFactory.CreateImageLoader(_loc7_,_loc2_[_loc5_].uiloader_mc);
                  _loc6_.smooth = true;
                  this.m_loaders.push(_loc6_);
               }
               else
               {
                  TextFieldUtil.compactTextField(_loc2_[_loc5_].name_tf,_loc9_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
                  TextFieldUtil.compactTextField(_loc2_[_loc5_].qty_tf,"x" + _loc8_[2]);
                  _loc10_ = ZGlobal.gameSettings.getImageByName(_loc9_.name,"icon");
                  _loc6_ = ImageLoaderFactory.CreateImageLoader(_loc10_,_loc2_[_loc5_].uiloader_mc);
                  _loc6_.smooth = true;
                  this.m_loaders.push(_loc6_);
               }
            }
            _loc5_++;
         }
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      protected function onBuyFuelClicked(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(BomberGameManager.BOMBER_FUEL_CODE,GameItem) as GameItem;
         var _loc3_:Number = _loc2_.cash;
         if(ZGlobal.player.canBuyCash(_loc3_,true,"",false))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc3_))
            {
               _loc4_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
               _loc5_ = ZGameUtils.CashTokenReplacements(_loc3_);
               _loc6_ = ZGameUtils.ZlocT("Dialogs","BuyFuel",_loc5_);
               this.m_buyPopup = GenericPopup2B.NewYesNo(_loc6_,_loc4_,this.buyItemConfirmed);
               this.m_buyPopup.userData = {
                  "item":_loc2_.code,
                  "amount":_loc3_
               };
               PopupManager.instance.push(this.m_buyPopup,0,false);
            }
            else
            {
               this.buyItem(BomberGameManager.BOMBER_FUEL_CODE);
            }
         }
      }
      
      private function buyItem(param1:String, param2:int = 1) : void
      {
         var _loc3_:Boolean = true;
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         ZGlobal.player.buyItem(_loc4_,_loc3_,param2);
         BomberGameManager.instance.reset(false);
         TransactionManager.addTransaction(new TBuyBomberFuel());
         this.close();
         BomberGameManager.instance.startBomberGame();
      }
      
      private function buyItemConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.buyItem(BomberGameManager.BOMBER_FUEL_CODE);
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         var _loc2_:ImageLoader = null;
         super.close();
         for each(_loc2_ in this.m_loaders)
         {
            _loc2_.destroy();
         }
         this.m_loaders = null;
         if(this.m_clock)
         {
            this.m_clock.dispose();
            this.m_clock = null;
         }
         if(this.m_acceptButton)
         {
            this.m_acceptButton.dispose();
            this.m_acceptButton = null;
         }
         if(this.m_exitButton)
         {
            this.m_exitButton.dispose();
            this.m_exitButton = null;
         }
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         Zlab.processManager.removeScheduledObject(this);
         removeChild(m_window);
      }
   }
}

