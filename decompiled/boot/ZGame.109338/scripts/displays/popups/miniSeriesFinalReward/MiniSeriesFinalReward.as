package displays.popups.miniSeriesFinalReward
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.managers.ExperimentsManager;
   import core.managers.WorldResourceManager;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.questTrees.PlayerQuestTrees;
   import core.player.questTrees.QuestTree;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.genericPopup.NotEnoughCashPopup;
   import events.MarketEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   import zlabs.debug.Logger;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class MiniSeriesFinalReward extends GallantPopup
   {
      
      protected static var CONTENT_WIDTH_OVERRIDE:int = 500;
      
      protected static var CONTENT_HEIGHT_OVERRIDE:int = 340;
      
      protected var m_questTree:QuestTree;
      
      protected var m_button:ZGameButton;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer;
      
      protected var m_loaders:Array = new Array();
      
      protected var m_quest:String;
      
      private var m_buyButtons:Array = null;
      
      private var m_buyPopup:GenericPopup;
      
      public function MiniSeriesFinalReward(param1:String, param2:String = null)
      {
         this.m_quest = param1;
         var _loc3_:String = "assets/displays/dialogs/PU_MiniSeries_FinalReward.swf";
         var _loc4_:String = ZGlobal.player.questTrees.getQuestTreeNameForQuest(param1);
         if(_loc4_)
         {
            this.m_questTree = ZGlobal.player.questTrees.getQuestTree(_loc4_);
            _loc3_ = this.m_questTree.finalUrl;
         }
         if(param2)
         {
            _loc3_ = param2;
         }
         super(ZGlobal.getAssetURL(_loc3_));
      }
      
      public function getMainReward() : String
      {
         var _loc2_:ZGameQuest = null;
         var _loc3_:XML = null;
         var _loc1_:String = null;
         if(Boolean(this.m_questTree) && this.m_questTree.mainReward != "")
         {
            _loc1_ = this.m_questTree.mainReward;
         }
         if(_loc1_ == null)
         {
            _loc2_ = QuestSettingsInit.getInstance().getItemByName(this.m_quest) as ZGameQuest;
            if(_loc2_)
            {
               for each(_loc3_ in _loc2_.xml.reward)
               {
                  if(_loc3_.@mainReward != undefined)
                  {
                     if(_loc3_.@type == "item")
                     {
                        _loc1_ = _loc3_.@item;
                     }
                  }
               }
            }
         }
         return _loc1_;
      }
      
      override protected function initializeScreen() : void
      {
         this.initUI();
         super.initializeScreen();
      }
      
      protected function initUI() : void
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc7_:GameItem = null;
         var _loc8_:ImageLoader = null;
         var _loc9_:Object = null;
         var _loc10_:int = 0;
         var _loc11_:Array = null;
         var _loc12_:String = null;
         var _loc13_:int = 0;
         var _loc14_:GameItem = null;
         var _loc15_:String = null;
         var _loc16_:ZGameButton = null;
         var _loc17_:Object = null;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Array = null;
         var _loc21_:Array = null;
         var _loc22_:Array = null;
         var _loc23_:String = null;
         var _loc1_:Rectangle = getVisibleBounds(this.screen);
         contentWidth = _loc1_.width;
         contentHeight = _loc1_.height;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(this.m_quest) as ZGameQuest;
         if(this.screen.icon)
         {
            _loc7_ = ZGlobal.gameSettings.getItemByCode(this.m_questTree.mainReward,GameItem) as GameItem;
            if(_loc7_ != null)
            {
               _loc8_ = ImageLoaderFactory.CreateImageLoader(_loc7_.getCachedImage("sw").url,this.screen.icon);
            }
            else
            {
               _loc8_ = ImageLoaderFactory.CreateImageLoader(this.m_questTree.iconURL,this.screen.icon);
            }
            _loc8_.smooth = true;
            this.m_loaders.push(_loc8_);
         }
         else if(_loc2_)
         {
            _loc9_ = _loc2_.getRewardTextObject(WorldResourceManager.XTRA_LARGE_ICON);
            _loc10_ = 0;
            this.hideAllRewards();
            this.m_buyButtons = new Array();
            _loc11_ = this.getRewardCards(_loc9_.rewardIcons.length);
            for each(_loc12_ in _loc9_.rewardText)
            {
               if(_loc10_ < _loc11_.length)
               {
                  _loc11_[_loc10_].visible = true;
                  TextFieldUtil.compactTextField(_loc11_[_loc10_].name_tf,_loc12_);
                  _loc8_ = ImageLoaderFactory.CreateImageLoader(_loc9_.rewardIcons[_loc10_],_loc11_[_loc10_].icon);
                  _loc8_.smooth = true;
                  this.m_loaders.push(_loc8_);
                  if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_QUEST_REWARD_BUY) == 2)
                  {
                     if(_loc11_[_loc10_].buy_bt != null)
                     {
                        if(_loc9_.rewardBuyable[_loc10_] == true)
                        {
                           _loc14_ = ZGlobal.gameSettings.getItemByCode(_loc9_.rewardItems[_loc10_],GameItem) as GameItem;
                           _loc15_ = ZGameUtils.ZlocT("Dialogs","BuyOneMoreForAmount",{"amount":_loc14_.cash});
                           _loc16_ = new ZGameButton(_loc11_[_loc10_].buy_bt,this.onBuyClick);
                           TextFieldUtil.compactTextField(_loc11_[_loc10_].buy_bt.generic_tf,_loc15_);
                           _loc11_[_loc10_].buy_bt.visible = true;
                           _loc17_ = new Object();
                           _loc17_.item = _loc14_;
                           _loc17_.button = _loc16_;
                           this.m_buyButtons.push(_loc17_);
                        }
                        else
                        {
                           _loc11_[_loc10_].buy_bt.visible = false;
                        }
                     }
                  }
                  else if(_loc11_[_loc10_].buy_bt != null)
                  {
                     _loc11_[_loc10_].buy_bt.visible = false;
                  }
                  _loc13_ = int(_loc9_.rewardPairs[_loc10_].count);
               }
               _loc10_++;
            }
            if(this.m_quest == "QT025_reward")
            {
               _loc18_ = 3;
               _loc19_ = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MINISERIES025_REWARDS);
               if(_loc19_ == 1 || _loc19_ == 2)
               {
                  _loc18_ = 3;
               }
               else if(_loc19_ == 3)
               {
                  _loc18_ = 1;
               }
               else if(_loc19_ == 4)
               {
                  _loc18_ = 6;
               }
               else if(_loc19_ == 5)
               {
                  _loc18_ = 10;
               }
               TextFieldUtil.processTextField(this.screen.rewardsOdd.reward0.qty_tf,"x" + _loc18_.toString());
            }
         }
         if(this.screen.place_btn != null && this.screen.place_btn != undefined)
         {
            this.m_button = new ZGameButton(this.screen.place_btn,this.onPlace);
         }
         var _loc3_:Object = ZGameUtils.buildLocalizedParams();
         if(this.m_button != null)
         {
            if(Boolean(_loc2_) && Boolean(_loc2_.finishButtonText))
            {
               this.m_button.text = ZGameUtils.ZlocTP("Dialogs",_loc2_.finishButtonText,_loc3_);
            }
            else
            {
               this.m_button.text = ZGameUtils.ZlocT("Dialogs","PlaceReward");
            }
         }
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
         if(this.m_button != null)
         {
            this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         }
         if(_loc2_.title)
         {
            _loc20_ = _loc2_.title.split(":");
            if(_loc20_.length == 2)
            {
               _loc4_ = ZGameUtils.ZlocT(_loc20_[0],_loc20_[1]);
            }
         }
         if(_loc4_)
         {
            TextFieldUtil.compactTextField(this.screen.header_tf,_loc4_,{
               "minScale":0.4,
               "maxLines":1
            });
         }
         else
         {
            TextFieldUtil.compactTextField(this.screen.header_tf,this.m_questTree.rewardTextHeader,{
               "minScale":0.4,
               "maxLines":1
            });
         }
         var _loc5_:XML = XML(_loc2_.xml.reward);
         if(_loc2_.desc)
         {
            _loc21_ = _loc2_.desc.split(":");
            if(_loc21_.length == 2)
            {
               _loc6_ = ZGameUtils.ZlocT(_loc21_[0],_loc21_[1]);
            }
         }
         if(_loc2_.difficultyModeDesc)
         {
            _loc22_ = _loc2_.difficultyModeDesc.split(":");
            if(_loc22_.length == 2)
            {
               if(_loc5_.hasOwnProperty("difficultyMode") && _loc5_.difficultyMode.hasOwnProperty("@experiment") && ExperimentsManager.instance.experimentGateEnabled(_loc5_.difficultyMode.@experiment,_loc5_.difficultyMode.@variant))
               {
                  _loc6_ = ZGameUtils.ZlocT(_loc22_[0],_loc22_[1],{"num":_loc13_});
                  TextFieldUtil.processTextField(this.screen.rewardsOdd.reward0.qty_tf,"x" + _loc13_.toString());
               }
            }
         }
         if(_loc6_)
         {
            TextFieldUtil.compactTextField(this.screen.header2_tf,_loc6_,{
               "minScale":0.65,
               "filter":"ignore"
            });
            TextFieldUtil.processTextField(this.screen.rewardsOdd.reward0.qty_tf,"x" + _loc13_.toString());
         }
         else if(_loc5_.hasOwnProperty("difficultyMode") && _loc5_.difficultyMode.hasOwnProperty("@experiment") && ExperimentsManager.instance.experimentGateEnabled(_loc5_.difficultyMode.@experiment,_loc5_.difficultyMode.@variant))
         {
            _loc23_ = this.m_questTree.rewardTextDescWithParams({"num":_loc13_});
            TextFieldUtil.compactTextField(this.screen.header2_tf,_loc23_,{
               "minScale":0.65,
               "filter":"ignore"
            });
            TextFieldUtil.processTextField(this.screen.rewardsOdd.reward0.qty_tf,"x" + _loc13_.toString());
         }
         else
         {
            TextFieldUtil.compactTextField(this.screen.header2_tf,this.m_questTree.rewardTextDescription,{
               "minScale":0.65,
               "filter":"ignore"
            });
            TextFieldUtil.processTextField(this.screen.rewardsOdd.reward0.qty_tf,"x" + _loc13_.toString());
         }
      }
      
      private function onBuyClick(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc2_:GameItem = null;
         for each(_loc3_ in this.m_buyButtons)
         {
            if(_loc3_.button == param1.target.buttonPointer)
            {
               _loc2_ = _loc3_.item;
               if(ZGlobal.player.canBuyCash(_loc2_.cash,false))
               {
                  if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_.cash))
                  {
                     _loc4_ = ZGameUtils.ZlocT("Dialogs","QuestTaskBuyConfirmMsg",ZGameUtils.CashTokenReplacements(_loc2_.cash));
                     _loc5_ = new Array("EmpirePointsConfirm","","","");
                     this.m_buyPopup = GenericPopup2B.NewYesNo(_loc4_,null,this.onBuyConfirmed,_loc5_);
                     this.m_buyPopup.userData = _loc2_;
                     PopupManager.instance.push(this.m_buyPopup,0,false);
                  }
                  else
                  {
                     ZGlobal.player.buyRewardItem(_loc2_,1,this.m_quest);
                     _loc6_ = _loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                     if(null == _loc6_)
                     {
                        _loc6_ = "";
                     }
                     PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","PurchasedItem",{
                        "num":1,
                        "item":_loc6_
                     })),0,false);
                  }
               }
               else
               {
                  PopupManager.instance.push(new NotEnoughCashPopup(ZGameUtils.ZlocT("Dialogs","ImpulseCash")),0,false);
               }
               break;
            }
         }
      }
      
      private function onBuyConfirmed(param1:GenericPopupEvent) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:String = null;
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
            ZGlobal.player.buyRewardItem(_loc2_,1,this.m_quest);
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","PurchasedItem",{
               "num":1,
               "item":_loc3_
            })),0,false);
         }
         this.m_buyPopup = null;
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:Object = null;
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         if(this.m_button != null)
         {
            this.m_button.dispose();
         }
         this.m_button = null;
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
            _loc1_ = null;
         }
         this.m_loaders = null;
         if(this.m_buyButtons != null)
         {
            for each(_loc2_ in this.m_buyButtons)
            {
               _loc2_ = null;
            }
            this.m_buyButtons = null;
         }
         super.deinitDialog();
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.QUEST_COMPLETE_POPUP_CONTINUE,this.m_quest));
      }
      
      protected function hideAllRewards() : void
      {
         if(this.screen.rewardsEven)
         {
            this.screen.rewardsEven.visible = false;
            this.hideArray([this.screen.rewardsEven.reward0,this.screen.rewardsEven.reward1]);
         }
         if(this.screen.rewardsOdd)
         {
            this.screen.rewardsOdd.visible = false;
            this.hideArray([this.screen.rewardsOdd.reward0]);
         }
      }
      
      protected function hideArray(param1:Array) : void
      {
         var _loc2_:MovieClip = null;
         for each(_loc2_ in param1)
         {
            _loc2_.visible = false;
         }
      }
      
      protected function getRewardCards(param1:int) : Array
      {
         switch(param1)
         {
            case 1:
               this.screen.rewardsOdd.visible = true;
               return [this.screen.rewardsOdd.reward0];
            case 2:
               this.screen.rewardsEven.visible = true;
               return [this.screen.rewardsEven.reward0,this.screen.rewardsEven.reward1];
            default:
               return null;
         }
      }
      
      protected function get screen() : MovieClip
      {
         return m_window.movie_mc;
      }
      
      protected function getMainRewardItem() : GameItem
      {
         var _loc1_:GameItem = null;
         var _loc2_:ZGameQuest = null;
         var _loc3_:XMLList = null;
         var _loc4_:XML = null;
         var _loc5_:String = null;
         if(this.m_questTree.mainReward)
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_questTree.mainReward,GameItem) as GameItem;
         }
         else
         {
            _loc2_ = QuestSettingsInit.getInstance().getItemByName(this.m_quest) as ZGameQuest;
            _loc3_ = _loc2_.xml.reward;
            for each(_loc4_ in _loc3_)
            {
               if(_loc4_.@mainReward)
               {
                  if(_loc4_.@type == "item")
                  {
                     _loc1_ = ZGlobal.gameSettings.getItemByCode(_loc4_.@item,GameItem) as GameItem;
                     if(_loc1_ != null)
                     {
                        break;
                     }
                  }
                  else
                  {
                     Logger.debug(null,"getMainRewardItem"," Main reward found, but is not an item. " + _loc4_.toXMLString());
                  }
               }
            }
         }
         if(ExperimentsManager.instance.experimentGateEnabled("empire_variable_rewards","2") && this.m_quest != null)
         {
            _loc5_ = this.getReward(this.m_quest);
            _loc1_ = ZGlobal.gameSettings.getItemByCode(_loc5_,GameItem) as GameItem;
         }
         return _loc1_;
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         var _loc2_:GameItem = this.getMainRewardItem();
         if(_loc2_ != null)
         {
            GMObjectPlace.notifyPlacementPopup(_loc2_);
         }
         this.close();
      }
      
      protected function onPlace(param1:MouseEvent) : void
      {
         this.close();
         ZGameQuestManager.instance.dispatchEvent(new WorldEvent(PlayerQuestTrees.FINAL_REWARD_PLACE));
         var _loc2_:GameItem = this.getMainRewardItem();
         if(_loc2_ != null)
         {
            if(_loc2_.placeable)
            {
               GameModeManager.instance.addGameMode(new GMObjectPlace(_loc2_.name,MarketEvent.SOURCE_INVENTORY,true));
            }
            else
            {
               GMObjectPlace.notifyPlacementPopup(_loc2_);
            }
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         ZGameQuestManager.instance.dispatchEvent(new WorldEvent(PlayerQuestTrees.FINAL_REWARD_CLOSE));
         super.close();
      }
      
      protected function getReward(param1:String) : String
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         var _loc3_:XML = new XML(_loc2_.xml.reward.toXMLString());
         var _loc4_:RewardHelper = new RewardHelper(_loc3_);
         return _loc4_.modifiedReward();
      }
      
      protected function getRewardCount(param1:String) : int
      {
         var _loc2_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param1) as ZGameQuest;
         var _loc3_:XML = new XML(_loc2_.xml.reward.toXMLString());
         var _loc4_:RewardHelper = new RewardHelper(_loc3_);
         return _loc4_.modifiedRewardCount();
      }
   }
}

