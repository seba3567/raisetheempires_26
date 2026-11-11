package displays.popups.battlewon
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.IslandItem;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.WorldResourceManager;
   import core.player.Player;
   import dispatchers.StrategicDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.battlebase.BattleBasePopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class BattleCampaignWonPopup extends BattleWonPopup
   {
      
      private var m_mapName:String = ZGlobal.player.campaign.currentMapName;
      
      private var m_islandIndex:int = ZGlobal.player.campaign.currentMap.lastIsland;
      
      private var m_allies:Array = null;
      
      private var m_bossDefeated:Boolean = false;
      
      private var m_giveVillainToken:Boolean = false;
      
      public function BattleCampaignWonPopup(param1:Array, param2:Array, param3:Dictionary, param4:Function)
      {
         this.m_allies = param1;
         super(param2,param3,param4);
      }
      
      override protected function close(param1:Event = null) : void
      {
         if(this.m_giveVillainToken)
         {
            PopupManager.instance.push(new VillainTokenAwardedPopup(1));
         }
         super.close();
      }
      
      override protected function assetStr() : String
      {
         var _loc1_:Boolean = false;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPV3_ENABLED) == ExperimentsManager.EXPERIMENT_CAMPV3_ENABLED_VARIANT_ENABLED)
         {
            _loc1_ = ZGlobal.player.campaign.currentCampaignName == "camp003";
         }
         if(allowUnitBuyBack())
         {
            if(_loc1_)
            {
               return "assets/displays/dialogs/PU_Victory3.swf";
            }
            return "assets/displays/dialogs/PU_Victory2.swf";
         }
         return "assets/displays/dialogs/PU_Victory.swf";
      }
      
      override protected function setUpScreen() : void
      {
         if(allowUnitBuyBack())
         {
            this.m_origOffsetY = 49;
         }
         super.setUpScreen();
      }
      
      override protected function setUpPopupUI() : void
      {
         super.setUpPopupUI();
         mainButton.text = ZGameUtils.ZlocT("Dialogs","PostTaunt");
         var _loc1_:Object = new Object();
         ZGlobal.player.campaign.currentMap.getTextObject(_loc1_,false,null,WorldResourceManager.LARGE_ICON);
         textObj = _loc1_;
         TextFieldUtil.compactTextField(this.screen.title_tf,ZGlobal.player.campaign.getWinTitleText(this.m_mapName,this.m_islandIndex));
         TextFieldUtil.compactTextField(this.screen.generic_tf,ZGlobal.player.campaign.getWinDescText(this.m_mapName,this.m_islandIndex));
         TextFieldUtil.compactTextField(this.screen.title01_tf,ZGameUtils.ZlocT("Dialogs","WinResult"));
         if(!allowUnitBuyBack())
         {
            TextFieldUtil.compactTextField(this.screen.title02_tf,ZGameUtils.ZlocT("Dialogs","WinAlliesTitle"));
            if(this.m_allies.length > 0)
            {
               TextFieldUtil.compactTextField(this.screen.popupBox_tf,ZGameUtils.ZlocT("Dialogs","WinAllyText"));
            }
            else
            {
               TextFieldUtil.compactTextField(this.screen.popupBox_tf,ZGameUtils.ZlocT("Dialogs","WinAllyTextSolo"));
            }
         }
         var _loc2_:int = ZGlobal.player.campaign.currentMap.currentIslandItem.index;
         var _loc3_:int = ZGlobal.player.campaign.getPreviousMastery(_loc2_);
         var _loc4_:int = ZGlobal.player.campaign.getMastery(_loc2_);
         this.setRewards();
         this.setBonusUnit(ZGlobal.player.campaign.currentMap.currentIslandItem,_loc3_);
         this.loadCharacter();
         this.showFriends();
      }
      
      override protected function get screen() : MovieClip
      {
         if(this.m_allies.length > 0)
         {
            return super.screen;
         }
         return m_window.victory_solo;
      }
      
      override protected function get bonusHeight() : int
      {
         if(this.m_allies.length > 0)
         {
            return super.bonusHeight;
         }
         return 155;
      }
      
      override protected function onButtonClicked(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,this.m_bossDefeated ? BattleBasePopup.SHARE_VILLAIN : BattleBasePopup.SHARE));
         super.onButtonClicked(param1);
      }
      
      override protected function get villainMovie() : String
      {
         return "defeat";
      }
      
      private function loadCharacter() : void
      {
         this.screen.clipAnchor_mc.visible = false;
         this.screen.scarlett_mc.visible = false;
         var _loc1_:String = ZGlobal.player.campaign.currentMap.currentIslandItem.winType;
         if(_loc1_.length == 0 || _loc1_ == IslandItem.ADVISOR_TYPE)
         {
            this.screen.scarlett_mc.visible = true;
         }
         else if(!loadVillain())
         {
            this.screen.scarlett_mc.visible = true;
         }
      }
      
      private function getFriendMovieClips() : Array
      {
         var _loc1_:int = int(this.m_allies.length);
         var _loc2_:Array = null;
         if(_loc1_ == 0)
         {
            _loc2_ = [];
         }
         else if(_loc1_ % 2 == 0)
         {
            _loc2_ = [this.screen.alliesEven.ally02_mc,this.screen.alliesEven.ally03_mc,this.screen.alliesEven.ally01_mc,this.screen.alliesEven.ally04_mc];
            this.screen.alliesEven.visible = true;
            this.screen.alliesOdd.visible = false;
         }
         else
         {
            _loc2_ = [this.screen.alliesOdd.ally03_mc,this.screen.alliesOdd.ally02_mc,this.screen.alliesOdd.ally04_mc,this.screen.alliesOdd.ally01_mc,this.screen.alliesOdd.ally05_mc];
            this.screen.alliesEven.visible = false;
            this.screen.alliesOdd.visible = true;
         }
         return _loc2_;
      }
      
      private function showFriends() : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:GameItem = null;
         var _loc8_:ImageLoader = null;
         var _loc9_:Player = null;
         var _loc1_:Array = this.getFriendMovieClips();
         var _loc2_:uint = _loc1_.length;
         var _loc3_:int = 0;
         for each(_loc4_ in this.m_allies)
         {
            _loc5_ = null;
            _loc6_ = null;
            _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc4_,GameItem) as GameItem;
            if(_loc7_)
            {
               _loc5_ = _loc7_.getCachedImage("icon").url;
               _loc6_ = _loc7_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
            }
            else
            {
               _loc9_ = ZGlobal.player.findFriendById(_loc4_);
               if(null != _loc9_)
               {
                  _loc5_ = _loc9_.snUser.picture;
                  _loc6_ = _loc9_.firstName;
               }
            }
            _loc1_[_loc3_].visible = true;
            _loc8_ = ImageLoaderFactory.CreateImageLoader(_loc5_,_loc1_[_loc3_].icon);
            _loc8_.smooth = true;
            loaders.push(_loc8_);
            if(allowUnitBuyBack())
            {
               TextFieldUtil.compactTextField(_loc1_[_loc3_].generic_tf,_loc6_);
            }
            else
            {
               TextFieldUtil.compactTextField(_loc1_[_loc3_].name_tf,_loc6_);
            }
            _loc3_++;
         }
         while(_loc3_ < _loc2_)
         {
            _loc1_[_loc3_].visible = false;
            _loc3_++;
         }
      }
      
      private function setBonusUnit(param1:IslandItem, param2:int) : void
      {
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         var _loc5_:BitArray = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc8_:UnitItem = null;
         if(param2 == 0)
         {
            this.updateBossDefeated(param1);
            _loc3_ = param1.unit || param1.showBonus;
            if(_loc3_)
            {
               _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
               if(param1.unit)
               {
                  _loc5_ = ZGlobal.player.checkGate(_loc4_,{"ignoreCampaignLocking":true});
                  if(!_loc5_.isBitSet(Player.GATE_FAILURE_LEVEL))
                  {
                     return;
                  }
               }
               this.addBonusUnit(_loc4_,null,_loc4_.type == GameItem.TYPE_MERCENARY ? "WinMercBonusDesc" : "WinGenericBonusDesc");
            }
            else
            {
               _loc6_ = param1.getUnits();
               for each(_loc7_ in _loc6_)
               {
                  _loc8_ = ZGlobal.gameSettings.getItemByCode(_loc7_,UnitItem) as UnitItem;
                  if(_loc8_.hasType(UnitItem.VILLAIN))
                  {
                     this.addBonusUnit(_loc8_,_loc8_,"WinUnitBonusDesc");
                     break;
                  }
               }
            }
         }
      }
      
      private function updateBossDefeated(param1:IslandItem) : void
      {
         var _loc3_:String = null;
         var _loc4_:UnitItem = null;
         var _loc2_:Array = param1.getUnits();
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UnitItem) as UnitItem;
            if(_loc4_.hasType(UnitItem.VILLAIN))
            {
               this.m_bossDefeated = true;
               break;
            }
         }
      }
      
      private function addBonusUnit(param1:GameItem, param2:UnitItem, param3:String) : void
      {
         var _loc4_:ImageLoader = null;
         if(!allowUnitBuyBack())
         {
            this.screen.bonusInd.visible = true;
            this.screen.bonusInd.reward1_mc.check_mc.visible = false;
            _loc4_ = ImageLoaderFactory.CreateImageLoader(param1.getCachedImage("icon").url,this.screen.bonusInd.reward1_mc.uiloader_mc);
            _loc4_.smooth = true;
            loaders.push(_loc4_);
            TextFieldUtil.compactTextField(this.screen.bonusInd.title_tf,ZGameUtils.ZlocT("Dialogs","WinBonus"));
            TextFieldUtil.compactTextField(this.screen.bonusInd.details_tf,param1.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            TextFieldUtil.compactTextField(this.screen.bonusInd.popupBox_tf,ZGameUtils.ZlocT("Dialogs",param3));
            this.contentHeight = windowHeight + this.bonusHeight;
            centerWithinStage(Zlab.mainStage);
         }
      }
      
      private function getRewardCards(param1:uint) : Array
      {
         if(param1 % 2 == 0)
         {
            this.screen.rewards_odd.visible = false;
            this.screen.rewards_even.visible = true;
            return [this.screen.rewards_even.rewardCard_01,this.screen.rewards_even.rewardCard_02];
         }
         this.screen.rewards_odd.visible = true;
         this.screen.rewards_even.visible = false;
         return [this.screen.rewards_odd.rewardCard_01,this.screen.rewards_odd.rewardCard_02,this.screen.rewards_odd.rewardCard_03];
      }
      
      private function setRewards() : void
      {
         var _loc4_:int = 0;
         var _loc5_:ImageLoader = null;
         var _loc6_:IslandItem = null;
         var _loc7_:String = null;
         var _loc1_:uint = textObj.rewardText ? uint(textObj.rewardText.length) : 0;
         var _loc2_:Array = this.getRewardCards(_loc1_);
         if(_loc1_ > 0)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc1_)
            {
               _loc5_ = ImageLoaderFactory.CreateImageLoader(textObj.rewardIcons[_loc4_],_loc2_[_loc4_].icon);
               _loc5_.smooth = true;
               loaders.push(_loc5_);
               TextFieldUtil.compactTextField(_loc2_[_loc4_].value_tf,ZGameUtils.ZlocT("Dialogs","WinRewardResult",{"reward":textObj.rewardText[_loc4_]}),{
                  "minScale":0.5,
                  "fontSize":14
               });
               _loc4_++;
            }
         }
         while(_loc4_ < _loc2_.length)
         {
            _loc2_[_loc4_].visible = false;
            _loc4_++;
         }
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_CAMPAIGN_MASTERY);
         if(_loc3_ == ZGlobal.EXPERIMENT_CAMPAIGN_MASTERY_ENABLED)
         {
            _loc6_ = ZGlobal.player.campaign.currentMap.currentIslandItem;
            if(ZGlobal.player.campaign.getIslandMastery(_loc6_.map) > ZGlobal.player.campaign.getPreviousIslandMastery(_loc6_.map) && ZGlobal.player.campaign.isMasteryEnabled)
            {
               _loc7_ = "VTK";
               this.m_giveVillainToken = true;
               ZGlobal.player.addToInventory(_loc7_);
               StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.VILLAIN_TOKEN_AWARDED));
            }
         }
      }
   }
}

