package displays.popups
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.deathMatchManager.DeathMatchManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.genericPopup.NotEnoughCashPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class DeathMatchRewardPopup extends ZGamePopUp
   {
      
      private static const FEED_STAGE_REWARD:String = "DM_StageReward";
      
      private static const FEED_GRAND_REWARD:String = "DM_GrandReward";
      
      private var assetUrl:String = "assets/displays/dialogs/PU_WarZone_Rewards.swf";
      
      private var m_roomId:String;
      
      private var m_rewards:Array;
      
      private var m_rewardType:int;
      
      private var m_loaders:Array = new Array();
      
      private var m_rewardButtons:Array = new Array();
      
      private var m_exitBt:ZGameButton = null;
      
      private var m_okBt:ZGameButton = null;
      
      private var m_shareBt:ZGameButton = null;
      
      private var m_buyPopup:GenericPopup;
      
      public function DeathMatchRewardPopup(param1:String, param2:Array, param3:int)
      {
         this.m_roomId = param1;
         this.m_rewards = param2;
         this.m_rewardType = param3;
         super(ZGlobal.getAssetURL(this.assetUrl));
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.setupText();
         this.setupRewards();
         this.screen.exit_bt.generic_tf = new TextField();
         this.m_exitBt = new ZGameButton(this.screen.exit_bt,this.onClickExit);
         this.m_okBt = new ZGameButton(this.screen.accept_bt,this.onClickOK);
         this.m_okBt.text = ZGameUtils.ZlocT("Dialogs","DM_RewardBt_Ok");
         this.m_shareBt = new ZGameButton(this.screen.viral_bt,this.onClickShare);
         this.m_shareBt.text = ZGameUtils.ZlocT("Dialogs","DM_RewardBt_Share");
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.initDialog();
         addChild(m_window);
      }
      
      protected function setupUI() : void
      {
         this.setupText();
         this.setupRewards();
         this.screen.exit_bt.generic_tf = new TextField();
         this.m_exitBt = new ZGameButton(this.screen.exit_bt,this.onClickExit);
         this.m_okBt = new ZGameButton(this.screen.accept_bt,this.onClickOK);
         this.m_okBt.text = ZGameUtils.ZlocT("Dialogs","DM_RewardBt_Ok");
         this.m_shareBt = new ZGameButton(this.screen.viral_bt,this.onClickShare);
         this.m_shareBt.text = ZGameUtils.ZlocT("Dialogs","DM_RewardBt_Share");
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function setupText() : void
      {
         var _loc3_:String = null;
         var _loc1_:String = "";
         var _loc2_:String = "";
         switch(this.m_rewardType)
         {
            case DeathMatchManager.GRAND_REWARD:
               _loc1_ = ZGameUtils.ZlocT("Dialogs","DM_GrandReward_Header");
               break;
            case DeathMatchManager.STAGE_REWARD:
               _loc1_ = ZGameUtils.ZlocT("Dialogs","DM_StageReward_Header");
               _loc2_ = ZGameUtils.ZlocT("Dialogs","DM_StageReward_Body");
               break;
            default:
               _loc1_ = "";
         }
         if(this.m_rewardType == DeathMatchManager.GRAND_REWARD)
         {
            _loc3_ = this.m_roomId.charAt(2);
            switch(_loc3_)
            {
               case "1":
                  _loc2_ = ZGameUtils.ZlocT("Dialogs","DM_GrandReward_Body_Veteran");
                  break;
               case "2":
                  _loc2_ = ZGameUtils.ZlocT("Dialogs","DM_GrandReward_Body_Elite");
                  break;
               case "3":
                  _loc2_ = ZGameUtils.ZlocT("Dialogs","DM_GrandReward_Body_Master");
            }
         }
         TextFieldUtil.compactTextField(this.screen.title_tf,_loc1_);
         TextFieldUtil.compactTextField(this.screen.generic_tf,_loc2_);
      }
      
      private function setupRewards() : void
      {
         if(this.m_rewardType == DeathMatchManager.STAGE_REWARD || this.m_rewards.length == 1)
         {
            this.screen.rewardsEven_mc.visible = false;
            this.screen.rewardsOdd_mc.visible = true;
            this.screen.rewardsAll_mc.visible = false;
            this.setupRewardSlot(this.screen.rewardsOdd_mc.reward1,this.m_rewards[0]);
         }
         else if(this.m_rewardType == DeathMatchManager.GRAND_REWARD)
         {
            if(this.m_rewards.length == 2)
            {
               this.screen.rewardsOdd_mc.visible = false;
               this.screen.rewardsEven_mc.visible = true;
               this.screen.rewardsAll_mc.visible = false;
               this.setupRewardSlot(this.screen.rewardsEven_mc.reward1,this.m_rewards[0]);
               this.setupRewardSlot(this.screen.rewardsEven_mc.reward2,this.m_rewards[1]);
            }
            else if(this.m_rewards.length == 3)
            {
               this.screen.rewardsOdd_mc.visible = false;
               this.screen.rewardsEven_mc.visible = false;
               this.screen.rewardsAll_mc.visible = true;
               this.setupRewardSlot(this.screen.rewardsAll_mc.reward1,this.m_rewards[0]);
               this.setupRewardSlot(this.screen.rewardsAll_mc.reward2,this.m_rewards[1]);
               this.setupRewardSlot(this.screen.rewardsAll_mc.reward3,this.m_rewards[2]);
            }
         }
      }
      
      private function setupRewardSlot(param1:MovieClip, param2:Array) : void
      {
         var _loc11_:UnitItem = null;
         var _loc3_:String = param2[0];
         var _loc4_:int = int(param2[1]);
         var _loc5_:int = int(param2[2]);
         var _loc6_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
         var _loc7_:String = ZGlobal.gameSettings.getImageByName(_loc6_.name,"icon");
         var _loc8_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc7_,param1.icon);
         this.m_loaders.push(_loc8_);
         TextFieldUtil.compactTextField(param1.rewardName_tf,_loc6_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         TextFieldUtil.compactTextField(param1.qty_tf,"x" + _loc4_.toString());
         if(_loc6_.isUnit())
         {
            _loc11_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UnitItem) as UnitItem;
            TextFieldUtil.compactTextField(param1.tier_mc.tier_tf,_loc11_.tier.toString());
            TextFieldUtil.compactTextField(param1.strength_mc.strength_tf,_loc11_.getStrength(null).toString());
         }
         else
         {
            param1.tier_mc.visible = false;
            param1.strength_mc.visible = false;
         }
         var _loc9_:ZGameButton = new ZGameButton(param1.buy_bt,this.onClickBuy);
         _loc9_.text = ZGameUtils.ZlocT("Dialogs","DM_RewardBt_Buy",{"x":_loc6_.cash});
         var _loc10_:Object = new Object();
         _loc10_.item = _loc6_;
         _loc10_.button = _loc9_;
         this.m_rewardButtons.push(_loc10_);
      }
      
      private function onClickBuy(param1:MouseEvent) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         for each(_loc4_ in this.m_rewardButtons)
         {
            if(param1.target.buttonPointer == _loc4_.button)
            {
               _loc2_ = _loc4_.item;
               _loc3_ = _loc2_.cash;
               if(ZGlobal.player.canBuyCash(_loc2_.cash,false))
               {
                  if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_.cash))
                  {
                     _loc5_ = ZGameUtils.ZlocT("Dialogs","QuestTaskBuyConfirmMsg",ZGameUtils.CashTokenReplacements(_loc2_.cash));
                     _loc6_ = new Array("EmpirePointsConfirm","","","");
                     this.m_buyPopup = GenericPopup2B.NewYesNo(_loc5_,null,this.onBuyConfirmed,_loc6_);
                     this.m_buyPopup.userData = _loc2_;
                     PopupManager.instance.push(this.m_buyPopup,0,false);
                  }
                  else
                  {
                     _loc7_ = "deathmatch_reward|";
                     if(_loc2_.isUnit())
                     {
                        _loc7_ += "unit|";
                     }
                     else
                     {
                        _loc7_ += "consumable|";
                     }
                     _loc7_ += _loc2_.name;
                     ZGlobal.player.buyGameItem(_loc2_,true,1,{"buyType":_loc7_});
                     _loc8_ = _loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                     if(null == _loc8_)
                     {
                        _loc8_ = "";
                     }
                     PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","PurchasedItem",{
                        "num":1,
                        "item":_loc8_
                     })),0,false);
                  }
               }
               else
               {
                  PopupManager.instance.push(new NotEnoughCashPopup(ZGameUtils.ZlocT("Dialogs","ImpulseCash")),0,false);
               }
            }
         }
      }
      
      private function onBuyConfirmed(param1:GenericPopupEvent) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = param1.userData as GameItem;
            _loc3_ = _loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
            if(null == _loc3_)
            {
               _loc3_ = "";
            }
            _loc4_ = "deathmatch_reward|";
            if(_loc2_.isUnit())
            {
               _loc4_ += "unit|";
            }
            else
            {
               _loc4_ += "consumable|";
            }
            _loc4_ += _loc2_.name;
            ZGlobal.player.buyGameItem(_loc2_,true,1,{"buyType":_loc4_});
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","PurchasedItem",{
               "num":1,
               "item":_loc3_
            })),0,false);
         }
         this.m_buyPopup = null;
      }
      
      private function onClickExit(param1:MouseEvent) : void
      {
         this.exit();
      }
      
      private function onClickOK(param1:MouseEvent) : void
      {
         this.exit();
      }
      
      private function onClickShare(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         if(this.m_rewardType == DeathMatchManager.STAGE_REWARD)
         {
            _loc3_ = this.m_rewards[0][0];
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
            _loc2_ = FEED_STAGE_REWARD;
            ViralsManager.instance.sendFeed(_loc2_,{
               "itemCode":_loc3_,
               "ITEMTOKitem":_loc4_.name + "|"
            });
         }
         else if(this.m_rewardType == DeathMatchManager.GRAND_REWARD)
         {
            _loc2_ = FEED_GRAND_REWARD;
            ViralsManager.instance.sendFeed(_loc2_,{});
         }
         this.exit();
      }
      
      private function cleanUp() : void
      {
         var _loc1_:int = 0;
         var _loc2_:ImageLoader = null;
         if(this.m_exitBt)
         {
            this.m_exitBt.dispose();
            this.m_exitBt = null;
         }
         if(this.m_okBt)
         {
            this.m_okBt.dispose();
            this.m_okBt = null;
         }
         if(this.m_shareBt)
         {
            this.m_shareBt.dispose();
            this.m_shareBt = null;
         }
         _loc1_ = 0;
         while(_loc1_ < this.m_rewardButtons.length)
         {
            this.m_rewardButtons[_loc1_].button.dispose();
            _loc1_++;
         }
         this.m_rewardButtons = null;
         for each(_loc2_ in this.m_loaders)
         {
            _loc2_.destroy();
            _loc2_ = null;
         }
      }
      
      private function exit() : void
      {
         this.cleanUp();
         super.close();
         DeathMatchManager.instance.dispatchEvent(new Event(DeathMatchManager.REWARD_POPUP_VIEWED));
      }
   }
}

