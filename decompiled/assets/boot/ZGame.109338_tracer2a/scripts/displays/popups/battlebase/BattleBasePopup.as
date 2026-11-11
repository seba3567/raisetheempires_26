package displays.popups.battlebase
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.ItemImage;
   import core.gameobjects.Unit;
   import core.gameobjects.UnitItem;
   import core.managers.BuyBackManager;
   import core.managers.ExperimentsManager;
   import core.managers.LEUnitDiscountManager;
   import core.managers.TierSurfacingManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import rendering.rendering2d.MovieController;
   import sound.SoundEvent;
   import transactions.TBuyBack;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.displays.popups.SWFPopUp;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class BattleBasePopup extends SWFPopUp
   {
      
      public static const EXIT:int = 0;
      
      public static const SHARE:int = 1;
      
      public static const REMATCH:int = 2;
      
      public static const INVITE:int = 3;
      
      public static const INVITE_RETREAT:int = 4;
      
      public static const REQUEST_GIFT:int = 5;
      
      public static const SHARE_VILLAIN:int = 6;
      
      public static const REQUEST_ENERGY:int = 7;
      
      public static const AUTOSHARE_COMMENT:int = 8;
      
      public static const AUTOSHARE_TAUNT:int = 9;
      
      public static const AUTOSHARE_DIRECT:int = 10;
      
      public static const DOMINATION_WIN_NEW:int = 11;
      
      public static const DOMINATION_WIN_REVENGE:int = 12;
      
      public static const ALLIANCE_WIN_NEW:int = 13;
      
      public static const ALLIANCE_WIN_REVENGE:int = 14;
      
      private var m_movieController:MovieController = null;
      
      private var m_movieClip:MovieClip = null;
      
      private var m_lostUnits:Dictionary = null;
      
      private var m_remainingUnits:Array = null;
      
      private var m_loaders:Array = null;
      
      private var m_buyBackUnits:Array = null;
      
      private var m_buyAllButton:ZGameButton = null;
      
      private var m_buyPopup:GenericPopup;
      
      protected var m_isSurvivalMode:Boolean = false;
      
      public function BattleBasePopup(param1:Array, param2:Dictionary, param3:Boolean = false)
      {
         this.m_lostUnits = param2;
         this.m_remainingUnits = param1;
         this.m_isSurvivalMode = param3;
         super(ZGlobal.getAssetURL(this.assetStr()));
      }
      
      protected function assetStr() : String
      {
         return "";
      }
      
      protected function loadVillain() : Boolean
      {
         var _loc3_:ItemImage = null;
         var _loc4_:String = null;
         var _loc1_:String = ZGlobal.player.campaign.currentMap.villain;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc1_,GameItem) as GameItem;
         if(null != _loc2_)
         {
            _loc3_ = _loc2_.getCachedImage(this.villainMovie);
            if(_loc3_)
            {
               _loc4_ = _loc3_.url;
               Zlab.resourceManager.load(_loc4_,SWFResource,this.onVillainLoadComplete);
               return true;
            }
         }
         else
         {
            Logger.error(this,"loadCharacter","no villain set for map " + ZGlobal.player.campaign.currentMap.code);
         }
         return false;
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.m_loaders = new Array();
         this.m_buyBackUnits = new Array();
         if(this.allowUnitBuyBack())
         {
            this.initUnitBuyBackDisplay();
         }
         SoundEvent.getSoundEvent("windowOpen").play();
      }
      
      protected function initUnitBuyBackDisplay() : void
      {
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         this.initUnitBuyBackItems();
         var _loc1_:Array = this.getUnitBuyBackCards();
         var _loc2_:uint = this.numBuyBackCards;
         if(_loc2_ > 0)
         {
            _loc4_ = this.getFirstVisibleCardIndex();
            _loc5_ = 0;
            while(_loc5_ < _loc1_.length)
            {
               if(_loc5_ < _loc4_ || _loc5_ >= _loc4_ + _loc2_)
               {
                  _loc1_[_loc5_].visible = false;
               }
               else
               {
                  _loc1_[_loc5_].visible = true;
                  _loc6_ = _loc5_ - _loc4_;
                  this.m_buyBackUnits[_loc6_]["card"] = _loc1_[_loc5_];
                  this.initCard(_loc6_);
                  this.updateCard(_loc6_);
               }
               _loc5_++;
            }
         }
         this.m_buyAllButton = new ZGameButton(this.screen.emp_bt,this.onBuyAllBack,1.1,true);
         var _loc3_:uint = uint(this.calculateActualBuyAllDiscount());
         if(this.flawlessVictory)
         {
            TextFieldUtil.processTextField(this.screen.title02_tf,ZGameUtils.ZlocT("Dialogs","FlawlessVictory"));
            if(_loc3_ > 0)
            {
               TextFieldUtil.processTextField(this.screen.message_tf,ZGameUtils.ZlocT("Dialogs","BuyBackFlawlessVictoryMessage",{"percent":_loc3_}));
            }
            else
            {
               TextFieldUtil.processTextField(this.screen.message_tf,ZGameUtils.ZlocT("Dialogs","BuyBackFlawlessVictoryNoDiscountMessage"));
            }
            if(this.screen.hasOwnProperty("bg_flawless"))
            {
               this.screen.bg_flawless.visible = true;
            }
         }
         else
         {
            TextFieldUtil.processTextField(this.screen.title02_tf,ZGameUtils.ZlocT("Dialogs","WinUnitsLostText",{
               "lost":this.numLostUnits,
               "total":this.numLostUnits + this.numRemainingUnits
            }));
            if(_loc3_ > 0)
            {
               TextFieldUtil.processTextField(this.screen.message_tf,ZGameUtils.ZlocT("Dialogs","BuyBackMessage"));
            }
            else
            {
               TextFieldUtil.processTextField(this.screen.message_tf,ZGameUtils.ZlocT("Dialogs","BuyBackNoDiscountMessage"));
            }
            if(this.screen.hasOwnProperty("bg_flawless"))
            {
               this.screen.bg_flawless.visible = false;
            }
         }
         this.updateBuyAllDisplay();
         if(!this.usesSecondActionButton && this.screen.hasOwnProperty("orangeButton_02"))
         {
            this.screen.orangeButton_02.visible = false;
         }
      }
      
      protected function get usesSecondActionButton() : Boolean
      {
         return false;
      }
      
      protected function initUnitBuyBackItems() : void
      {
         var _loc1_:String = null;
         var _loc2_:Unit = null;
         var _loc3_:UnitItem = null;
         var _loc4_:String = null;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         if(this.flawlessVictory)
         {
            for(_loc1_ in this.remainingUnits)
            {
               _loc2_ = this.remainingUnits[_loc1_] as Unit;
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_.code,UnitItem) as UnitItem;
               this.m_buyBackUnits.push({
                  "item":_loc3_,
                  "bought":false
               });
            }
         }
         else
         {
            for(_loc4_ in this.lostUnits)
            {
               _loc5_ = uint(this.lostUnits[_loc4_]);
               _loc6_ = 0;
               while(_loc6_ < _loc5_)
               {
                  _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc4_,UnitItem) as UnitItem;
                  this.m_buyBackUnits.push({
                     "item":_loc3_,
                     "bought":false
                  });
                  _loc6_++;
               }
            }
         }
      }
      
      protected function initCard(param1:int) : void
      {
         var _loc2_:Object = this.m_buyBackUnits[param1];
         var _loc3_:MovieClip = _loc2_.card as MovieClip;
         var _loc4_:UnitItem = _loc2_.item;
         var _loc5_:String = _loc4_.getCachedImage("icon").url;
         this.loaders.push(ImageLoaderFactory.CreateImageLoader(_loc5_,_loc3_.uiloader_mc));
         TextFieldUtil.processTextField(_loc3_.name_tf,_loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         var _loc6_:ZGameButton = new ZGameButton(_loc3_.emp_bt,this.onBuyBack,1.1,true);
         _loc6_.buttonValue = String(param1);
         _loc2_["button"] = _loc6_;
      }
      
      protected function updateAllCards() : void
      {
         var _loc1_:uint = 0;
         while(_loc1_ < this.m_buyBackUnits.length)
         {
            this.updateCard(_loc1_);
            _loc1_++;
         }
      }
      
      protected function getCardBuybackButtonText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":param1});
      }
      
      protected function updateCard(param1:uint) : void
      {
         var _loc9_:UnitItem = null;
         var _loc10_:Number = NaN;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc2_:Object = this.m_buyBackUnits[param1];
         var _loc3_:MovieClip = _loc2_.card as MovieClip;
         var _loc4_:UnitItem = _loc2_.item as UnitItem;
         var _loc5_:Dictionary = WorldUnitManager.instance.availableUnits;
         var _loc6_:int = ZGlobal.player.inventory[_loc4_.code] ? int(ZGlobal.player.inventory[_loc4_.code]) : 0;
         var _loc7_:int = _loc5_[_loc4_.code] ? int(_loc5_[_loc4_.code]) : 0;
         if(Boolean(_loc3_.count_mc) && Boolean(_loc3_.count_mc.count_tf))
         {
            TextFieldUtil.processTextField(_loc3_.count_mc.count_tf,(_loc6_ + _loc7_).toString());
         }
         var _loc8_:ZGameButton = _loc2_.button;
         if(_loc2_.bought)
         {
            _loc3_.x_mc.visible = false;
            _loc3_.check_mc.visible = true;
            if(_loc3_.discount_tf)
            {
               _loc3_.discount_tf.visible = false;
            }
            _loc8_.hide();
         }
         else
         {
            _loc3_.x_mc.visible = !this.flawlessVictory;
            _loc3_.check_mc.visible = false;
            _loc9_ = _loc2_.item;
            _loc8_.show();
            param1 = this.flawlessVictory ? 1 : 0;
            _loc10_ = BuyBackManager.instance.costMultiplier("1",param1);
            _loc11_ = _loc9_.getModifiedCash(_loc10_);
            _loc8_.compactText(this.getCardBuybackButtonText(_loc11_),null);
            if(Boolean(_loc3_.tierRating_mc) && Boolean(_loc3_.doubleXP_mc))
            {
               _loc3_.tierRating_mc.visible = _loc3_.doubleXP_mc.visible = false;
               if(TierSurfacingManager.instance.tierSurfacing2Enabled)
               {
                  _loc12_ = (ZGlobal.gameSettings.getItemByCode(_loc4_.code,UnitItem) as UnitItem).tier;
                  TextFieldUtil.compactTextField(_loc3_.tierRating_mc.tier_tf,String(_loc12_));
                  _loc3_.tierRating_mc.visible = true;
                  if(_loc4_.isBlueDevil)
                  {
                     _loc3_.doubleXP_mc.visible = true;
                  }
               }
            }
            if(_loc3_.discount_tf != null)
            {
               _loc3_.discount_tf.visible = false;
               _loc3_.discount_tf.visible = false;
               if(LEUnitDiscountManager.instance.isLEDiscountExpEnabled() && LEUnitDiscountManager.instance.isOverrideLEItem(_loc9_.code))
               {
                  _loc13_ = Math.floor(LEUnitDiscountManager.instance.getLEOverrideDiscount(_loc9_.code) * 100);
                  if(_loc13_ > 0)
                  {
                     if(LEUnitDiscountManager.instance.leDiscountVariant == 3)
                     {
                        TextFieldUtil.compactTextField(_loc3_.discount_tf,ZGameUtils.ZlocT("Dialogs","PercentOffExclaim",{"amount":_loc13_}));
                     }
                     else
                     {
                        TextFieldUtil.compactTextField(_loc3_.discount_tf,ZGameUtils.ZlocT("Promo","promo_RepeatPackHUD_textSale"));
                     }
                     _loc3_.discount_tf.visible = true;
                  }
                  else
                  {
                     _loc3_.discount_tf.visible = false;
                  }
               }
            }
         }
      }
      
      protected function updateBuyAllDisplay() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.numUnitsAvailableToBuyBack < 2)
         {
            this.m_buyAllButton.text = ZGameUtils.ZlocT("Dialogs","BattleSelect_Continue");
            this.m_buyAllButton.callback = this.onExit;
            if(this.screen.discount_tf)
            {
               this.screen.discount_tf.visible = false;
            }
         }
         else
         {
            _loc1_ = this.getBuyAllBackCash();
            this.m_buyAllButton.text = ZGameUtils.ZlocT("Dialogs","BuyAllForAmount",{"amount":_loc1_});
            if(this.screen.discount_tf)
            {
               _loc2_ = this.calculateActualBuyAllDiscount();
               if(_loc2_ > 0)
               {
                  TextFieldUtil.processTextField(this.screen.discount_tf,ZGameUtils.ZlocT("Dialogs","PercentOff",{"amount":_loc2_}));
                  this.screen.discount_tf.visible = true;
               }
               else
               {
                  this.screen.discount_tf.visible = false;
               }
            }
         }
      }
      
      protected function getBuyBackMultiplier(param1:int) : Number
      {
         var _loc2_:uint = this.flawlessVictory ? 1 : 0;
         return BuyBackManager.instance.costMultiplier(String(param1),_loc2_);
      }
      
      protected function getBuyBackCash(param1:UnitItem, param2:int) : int
      {
         return param1.getModifiedCash(this.getBuyBackMultiplier(param2));
      }
      
      protected function getBuyAllBackCash() : int
      {
         var _loc2_:Object = null;
         var _loc3_:UnitItem = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_buyBackUnits)
         {
            if(!_loc2_.bought)
            {
               _loc3_ = _loc2_.item;
               _loc1_ += this.getBuyBackCash(_loc3_,this.numUnitsAvailableToBuyBack);
            }
         }
         return _loc1_;
      }
      
      protected function calculateActualBuyDiscount(param1:UnitItem) : int
      {
         var _loc2_:int = this.getBuyBackCash(param1,1);
         if(param1.cash < 1)
         {
            return 0;
         }
         return Math.floor((1 - _loc2_ / param1.cash) * 100);
      }
      
      protected function calculateActualBuyAllDiscount() : int
      {
         var _loc3_:Object = null;
         var _loc4_:UnitItem = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         for each(_loc3_ in this.m_buyBackUnits)
         {
            if(!_loc3_.bought)
            {
               _loc4_ = _loc3_.item;
               _loc1_ += _loc4_.cash;
               _loc2_ += this.getBuyBackCash(_loc4_,this.numUnitsAvailableToBuyBack);
            }
         }
         if(_loc1_ < 1)
         {
            return 0;
         }
         return Math.floor((1 - _loc2_ / _loc1_) * 100);
      }
      
      protected function getUnitBuyBackCards() : Array
      {
         if(this.numBuyBackCards % 2 == 0)
         {
            this.screen.units_odd.visible = false;
            this.screen.units_even.visible = true;
            return [this.screen.units_even.reward1_mc,this.screen.units_even.reward2_mc,this.screen.units_even.reward3_mc,this.screen.units_even.reward4_mc];
         }
         this.screen.units_odd.visible = true;
         this.screen.units_even.visible = false;
         return [this.screen.units_odd.reward1_mc,this.screen.units_odd.reward2_mc,this.screen.units_odd.reward3_mc,this.screen.units_odd.reward4_mc,this.screen.units_odd.reward5_mc];
      }
      
      protected function getFirstVisibleCardIndex() : uint
      {
         if(this.numBuyBackCards % 2 == 0)
         {
            return (4 - this.numBuyBackCards) / 2;
         }
         return (5 - this.numBuyBackCards) / 2;
      }
      
      protected function get numBuyBackCards() : uint
      {
         if(this.flawlessVictory)
         {
            return this.numRemainingUnits;
         }
         return this.numLostUnits;
      }
      
      protected function get numUnitsAvailableToBuyBack() : uint
      {
         var _loc2_:Object = null;
         var _loc1_:uint = 0;
         for each(_loc2_ in this.m_buyBackUnits)
         {
            if(!_loc2_.bought)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      protected function onBuyBack(param1:MouseEvent) : void
      {
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc2_:Object = this.m_buyBackUnits[param1.currentTarget.buttonValue];
         var _loc3_:UnitItem = _loc2_.item;
         var _loc4_:int = this.getBuyBackCash(_loc3_,1);
         if(ZGlobal.player.canBuyCash(_loc4_,true,"",false))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc4_))
            {
               _loc5_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
               _loc6_ = ZGameUtils.CashTokenReplacements(_loc4_);
               _loc6_.item = _loc3_.getSentenceNameLocalizationObject("singular,indefinite",true);
               _loc7_ = ZGameUtils.ZlocT("Dialogs","BuyBackConfirmation",_loc6_);
               this.m_buyPopup = GenericPopup2B.NewYesNo(_loc7_,_loc5_,this.buyBackConfirmed);
               this.m_buyPopup.userData = {"index":param1.currentTarget.buttonValue};
               PopupManager.instance.push(this.m_buyPopup,0,false);
            }
            else
            {
               this.buyBack(param1.currentTarget.buttonValue);
            }
         }
      }
      
      private function buyBackConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.buyBack(param1.userData.index);
         }
         this.m_buyPopup = null;
      }
      
      private function buyBack(param1:uint) : void
      {
         var _loc2_:Object = this.m_buyBackUnits[param1];
         var _loc3_:UnitItem = _loc2_.item;
         ZGlobal.player.buyBackItems([_loc3_],this.flawlessVictory);
         ZGlobal.player.addToInventory(_loc3_.code);
         TransactionManager.addTransaction(new TBuyBack(_loc3_.code),true);
         _loc2_.bought = true;
         this.updateAllCards();
         this.updateBuyAllDisplay();
      }
      
      protected function onBuyAllBack(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc2_:int = this.getBuyAllBackCash();
         if(ZGlobal.player.canBuyCash(_loc2_,true,"",false))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
            {
               _loc3_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
               _loc4_ = ZGameUtils.CashTokenReplacements(_loc2_);
               _loc5_ = ZGameUtils.ZlocT("Dialogs","BuyAllBackConfirmation",_loc4_);
               this.m_buyPopup = GenericPopup2B.NewYesNo(_loc5_,_loc3_,this.buyAllBackConfirmed);
               PopupManager.instance.push(this.m_buyPopup,0,false);
            }
            else
            {
               this.buyAllBack();
            }
         }
      }
      
      private function buyAllBackConfirmed(param1:GenericPopupEvent) : void
      {
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         if(param1.button == GenericPopup.YES)
         {
            this.buyAllBack();
         }
         this.m_buyPopup = null;
      }
      
      private function buyAllBack() : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:UnitItem = null;
         var _loc1_:Array = new Array();
         for(_loc2_ in this.m_buyBackUnits)
         {
            _loc3_ = this.m_buyBackUnits[_loc2_];
            if(!_loc3_.bought)
            {
               _loc4_ = _loc3_.item;
               _loc1_.push(_loc4_);
               ZGlobal.player.addToInventory(_loc4_.code);
               TransactionManager.addTransaction(new TBuyBack(null,this.m_isSurvivalMode),true);
               _loc3_.bought = true;
               this.updateCard(uint(_loc2_));
            }
         }
         ZGlobal.player.buyBackItems(_loc1_,this.flawlessVictory);
         this.updateAllCards();
         this.updateBuyAllDisplay();
      }
      
      protected function get flawlessVictory() : Boolean
      {
         return this.isVictory && this.numLostUnits < 1;
      }
      
      protected function multiplierToDisplayDiscountPercent(param1:Number) : uint
      {
         var _loc2_:Number = Math.max(0,Math.min(1,1 - param1));
         return Math.round(_loc2_ * 100);
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         super.deinitDialog();
         if(null != this.m_movieController)
         {
            this.m_movieController.dispose();
            this.m_movieController = null;
         }
         if(null != this.m_movieClip)
         {
            this.screen.clipAnchor_mc.removeChild(this.m_movieClip);
            this.m_movieClip = null;
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
         this.m_buyBackUnits = null;
      }
      
      protected function get screen() : MovieClip
      {
         return null;
      }
      
      protected function get villainMovie() : String
      {
         return null;
      }
      
      protected function get lostUnits() : Dictionary
      {
         return this.m_lostUnits;
      }
      
      protected function get numLostUnits() : uint
      {
         var _loc2_:uint = 0;
         var _loc1_:uint = 0;
         if(this.lostUnits != null)
         {
            for each(_loc2_ in this.lostUnits)
            {
               _loc1_ += _loc2_;
            }
         }
         return _loc1_;
      }
      
      protected function get remainingUnits() : Array
      {
         return this.m_remainingUnits;
      }
      
      protected function get numRemainingUnits() : uint
      {
         return this.m_remainingUnits != null ? this.m_remainingUnits.length : 0;
      }
      
      protected function get loaders() : Array
      {
         return this.m_loaders;
      }
      
      protected function set loaders(param1:Array) : void
      {
         this.m_loaders = param1;
      }
      
      private function onVillainLoadComplete(param1:SWFResource) : void
      {
         this.m_movieClip = param1.clip;
         this.m_movieController = new MovieController(this.m_movieClip);
         var _loc2_:int = this.villainVictoryAnimationFramerate(ZGlobal.player.campaign.currentMap.villain);
         if(_loc2_)
         {
            this.m_movieController.fps = _loc2_;
         }
         this.screen.clipAnchor_mc.visible = true;
         this.screen.clipAnchor_mc.addChild(this.m_movieClip);
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,BattleBasePopup.EXIT));
         close();
      }
      
      protected function allowUnitBuyBack() : Boolean
      {
         return ExperimentsManager.instance.getExperimentVariant("empire_pricetest_unitbuyback") > 2 && TutorialManager.instance.isTutorialComplete() && (this.isVictory || this.numLostUnits > 0);
      }
      
      protected function get isVictory() : Boolean
      {
         return false;
      }
      
      private function villainVictoryAnimationFramerate(param1:String) : int
      {
         var _loc3_:XMLList = null;
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         if(_loc2_)
         {
            _loc3_ = _loc2_.xml.image;
            for each(_loc4_ in _loc3_)
            {
               if(_loc4_.@name == "victory")
               {
                  _loc5_ = _loc4_.@fps.toString();
                  if(_loc5_.length)
                  {
                     return int(_loc5_);
                  }
               }
            }
         }
         return 0;
      }
      
      protected function loadImage(param1:String, param2:UILoader) : void
      {
         var _loc3_:ImageLoader = ImageLoaderFactory.CreateImageLoader(param1,param2);
         if(_loc3_)
         {
            _loc3_.smooth = true;
            this.loaders.push(_loc3_);
         }
      }
   }
}

