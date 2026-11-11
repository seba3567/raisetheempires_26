package displays.screens.leaderboard
{
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationObjectToken;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.leaderboardManager.Leaderboard;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import transactions.TCollectLeaderBoard;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class SummaryBoard extends Board
   {
      
      private const m_rewards:Array = ["LB01","LB02","LB03","LB04"];
      
      private var m_minPercentageOff:Number = 0;
      
      public function SummaryBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
         this.m_minPercentageOff = ZGlobal.gameSettings.getNumber("leaderboardMinRewardPercentage",5);
      }
      
      override protected function validatePlayer(param1:Player) : Boolean
      {
         return param1.uid == ZGlobal.player.uid;
      }
      
      override protected function allowPlacementRewardCollection(param1:Object) : Boolean
      {
         return getReward(param1) >= 0;
      }
      
      override protected function populatePlayer(param1:MovieClip, param2:Object) : void
      {
         super.populatePlayer(param1,param2);
         this.hideSpecialDealSymbols(param1);
      }
      
      override protected function populateReward(param1:MovieClip, param2:XML, param3:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:ZGameButton = null;
         super.populateReward(param1,param2,param3);
         if(param2.@item != undefined)
         {
            if(m_leaderboard.completedRewards[param3])
            {
               this.rewardCollected(param1);
            }
            else
            {
               _loc4_ = this.calculateCost(param2,param1);
               _loc5_ = m_leaderboard.getValue(ZGlobal.player.uid);
               if(_loc4_ == 0 || _loc5_ > param2.@value)
               {
                  this.hideSpecialDealSymbols(param1);
               }
               else
               {
                  param1.oneTimeOnly_mc.visible = true;
                  TextFieldUtil.processTextField(param1.oneTimeOnly_mc.oneTime_mc,ZGameUtils.ZlocT("Leaderboards","Leaderboards_OneTimeOnly"));
                  param1.discount_mc.visible = true;
                  param1.icon_mc.visible = true;
                  param1.upgrade_mc.visible = true;
                  _loc6_ = new ZGameButton(param1.upgrade_mc,this.onBuyReward);
                  _loc6_.buttonValue = param3.toString();
                  _loc6_.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":_loc4_});
                  m_buttons.push(_loc6_);
                  m_buttonSounds.addButton(_loc6_.m_overlay,ButtonSound.DEFAULT);
               }
            }
         }
      }
      
      private function hideSpecialDealSymbols(param1:MovieClip) : void
      {
         param1.oneTimeOnly_mc.visible = false;
         param1.upgrade_mc.visible = false;
         param1.discount_mc.visible = false;
      }
      
      override protected function getRewardItem(param1:XML) : GameItem
      {
         return ZGlobal.gameSettings.getItemByCode(param1.@item,GameItem) as GameItem;
      }
      
      override protected function calculateCost(param1:XML, param2:MovieClip = null) : int
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:int = 0;
         var _loc3_:GameItem = this.getRewardItem(param1);
         var _loc4_:int = _loc3_.xmlCash;
         if(_loc4_ > 0)
         {
            if(ZGameTimeUtil.instance.isLimitedEdition(_loc3_.xml))
            {
               _loc10_ = ZGlobal.gameSettings.getLEUnitDiscount(_loc3_);
               if(_loc10_ > 0)
               {
                  _loc4_ = Math.ceil(_loc4_ * (1 - _loc10_));
               }
            }
            _loc5_ = m_leaderboard.getValue(ZGlobal.player.uid);
            _loc6_ = Number(param1.@value);
            _loc5_ /= _loc6_;
            _loc5_ = _loc5_ * this.getRewardCostMultiplier(_loc5_);
            _loc7_ = this.m_minPercentageOff * 0.01;
            if(_loc5_ < _loc7_)
            {
               _loc5_ = _loc7_;
            }
            _loc8_ = _loc5_;
            _loc5_ = 1 - _loc5_;
            _loc9_ = _loc3_.getModifiedCash(_loc5_);
            if(Boolean(param2) && _loc9_ > 0)
            {
               _loc11_ = int(_loc8_ * 100);
               TextFieldUtil.processTextField(param2.discount_mc.discount_tf,ZGameUtils.ZlocT("Leaderboards","Leaderboards_PercentOff",{"amount":_loc11_}));
            }
            return _loc9_;
         }
         return _loc4_;
      }
      
      private function getRewardCostMultiplier(param1:Number) : Number
      {
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant("empire_leaderboard_reward_cost_min_percentage");
         var _loc3_:String = ZGlobal.gameSettings.getString("leaderboardRewardCostMinPercentages");
         var _loc4_:Array = _loc3_.split(",");
         if(_loc2_ < _loc4_.length)
         {
            return _loc4_[_loc2_];
         }
         return 1;
      }
      
      private function onBuyReward(param1:MouseEvent) : void
      {
         if(collectReward(param1.target.parent,parseInt(param1.target.buttonValue),true))
         {
            this.rewardCollected(param1.target.parent);
         }
      }
      
      override protected function rewardCollected(param1:MovieClip) : void
      {
         super.rewardCollected(param1);
         this.hideSpecialDealSymbols(param1);
      }
      
      override protected function onPlacementRewardClicked(param1:MouseEvent) : void
      {
         var _loc3_:Array = null;
         var _loc4_:GameItem = null;
         var _loc5_:LocalizationObjectToken = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:FeedPopup = null;
         var _loc2_:int = getReward(m_leaderboard.entry(ZGlobal.player.uid));
         if(_loc2_ > REWARD_NONE)
         {
            if(!m_leaderboard.completedRewards[Leaderboard.PLACEMENT_REWARD_INDEX])
            {
               param1.target.parent.check_mc.visible = true;
               param1.target.parent.return_mc.visible = false;
               _loc3_ = m_leaderboard.getPlacementRewards();
               if(!_loc3_)
               {
                  _loc3_ = this.m_rewards;
               }
               ZGlobal.player.addToInventory(_loc3_[_loc2_]);
               _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_[_loc2_],GameItem) as GameItem;
               _loc5_ = _loc4_.getSentenceNameLocalizationObject("singular",true);
               _loc6_ = ZGameUtils.ZlocT("Leaderboards","Leaderboards_CollectRewardTitle");
               _loc7_ = ZGameUtils.ZlocT("Leaderboards","Leaderboards_CollectRewardMessage",{
                  "item":_loc5_,
                  "amount":1
               });
               _loc8_ = ZGameUtils.ZlocT("Dialogs","Share");
               _loc9_ = new FeedPopup(_loc7_,_loc6_,_loc8_,GenericPopup.TYPE_ACCEPTCANCEL,this.onSharePlacementReward,_loc4_.getCachedImage("icon").url);
               _loc9_.userData = {"reward":_loc2_};
               PopupManager.instance.push(_loc9_,0,false);
               m_leaderboard.completedRewards[Leaderboard.PLACEMENT_REWARD_INDEX] = true;
               ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
                  "counter":"dialog",
                  "kingdom":"lb_placement_complete",
                  "phylum":"collect"
               }));
               TransactionManager.addTransaction(new TCollectLeaderBoard(id,Leaderboard.PLACEMENT_REWARD_INDEX,_loc2_,false,false));
            }
         }
      }
      
      override protected function get addShareButton() : Boolean
      {
         return true;
      }
      
      override protected function onPlacementShareClicked(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.target.buttonValue;
         var _loc3_:int = m_leaderboard.getValue(_loc2_);
         ViralsManager.instance.sendFeed("LB_Summary",{
            "title":title,
            "user":ZGlobal.player.firstName,
            "rank":rank,
            "amount":_loc3_
         });
         super.onPlacementShareClicked(param1);
      }
      
      private function onSharePlacementReward(param1:GenericPopupEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Array = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = param1.userData;
            _loc3_ = m_leaderboard.getPlacementVirals();
            if(!_loc3_)
            {
               _loc3_ = ["LB_PlatinumPlacementReward","LB_GoldPlacementReward","LB_SilverPlacementReward","LB_BronzePlacementReward"];
            }
            ViralsManager.instance.sendFeed(_loc3_[_loc2_.reward],{
               "title":title,
               "user":ZGlobal.player.firstName,
               "rank":rank,
               "amount":numValidEntries
            });
         }
      }
   }
}

