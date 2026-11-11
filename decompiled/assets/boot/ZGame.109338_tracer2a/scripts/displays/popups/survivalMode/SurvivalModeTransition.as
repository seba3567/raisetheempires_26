package displays.popups.survivalMode
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class SurvivalModeTransition extends GallantPopup
   {
      
      public static const MANUAL_DELAY:int = -1;
      
      private static const PAUSE_FRAME:int = 30;
      
      private static const END_FRAME:int = 39;
      
      private var m_reward:XML = null;
      
      private var m_msg:String = null;
      
      private var m_closeCallback:Function = null;
      
      private var m_loaders:Array = null;
      
      private var m_delay:int = 0;
      
      public function SurvivalModeTransition(param1:XML, param2:String, param3:Function, param4:int)
      {
         super(ZGlobal.getAssetURL(this.assetURL));
         this.m_reward = param1;
         this.m_msg = param2;
         this.m_closeCallback = param3;
         this.m_delay = param4;
      }
      
      private function get assetURL() : String
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON && SurvivalModeManager.instance.isInEliteSurvivalModeBattle)
         {
            return "assets/displays/dialogs/PU_EliteSurvivalModeWaveTransition.swf";
         }
         return "assets/displays/dialogs/PU_SurvivalModeWaveTransition.swf";
      }
      
      private function get mc() : MovieClip
      {
         return m_window.waveTransition_mc;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.mc.gotoAndStop(1);
         this.contentWidth = this.mc.background_mc.width;
         this.contentHeight = this.mc.background_mc.height;
         ZGameUtils.hideIfExists(this.mc.background_mc);
         centerWithinStage(Zlab.mainStage);
         TextFieldUtil.compactTextField(this.mc.title_mc.title_tf,this.m_msg);
         this.m_loaders = new Array();
         this.populateRewards();
         if(null != this.m_closeCallback)
         {
            addEventListener(Event.COMPLETE,this.m_closeCallback);
         }
         this.mc.addFrameScript(PAUSE_FRAME,this.doDelay);
         this.mc.addFrameScript(END_FRAME,this.doExit);
         this.doFadeIn();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         if(null != this.m_closeCallback)
         {
            removeEventListener(Event.COMPLETE,this.m_closeCallback);
            this.m_closeCallback = null;
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
         super.deinitDialog();
      }
      
      private function populateRewards() : void
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:Object = null;
         var _loc7_:XML = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Array = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:String = null;
         var _loc15_:GameItem = null;
         var _loc16_:Object = null;
         var _loc17_:UnitItem = null;
         var _loc18_:RewardHelper = null;
         var _loc19_:ImageLoader = null;
         var _loc1_:Array = [this.mc.rewards_mc.rewards1_mc.quantity_tf,this.mc.rewards_mc.rewards2_mc.quantity_tf,this.mc.rewards_mc.rewards3_mc.quantity_tf];
         var _loc2_:int = 0;
         var _loc3_:XML = this.m_reward;
         if(Boolean(_loc3_) && Boolean(_loc3_.reward.length()))
         {
            TextFieldUtil.processTextField(this.mc.rewards_mc.rewards_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeTransitionRewards"));
            _loc4_ = [this.mc.rewards_mc.rewards1_mc,this.mc.rewards_mc.rewards2_mc,this.mc.rewards_mc.rewards3_mc];
            _loc5_ = [this.mc.rewards_mc.rewards1_mc.icon,this.mc.rewards_mc.rewards2_mc.icon,this.mc.rewards_mc.rewards3_mc.icon];
            _loc6_ = new Object();
            _loc6_.rewardText = new Array();
            _loc6_.rewardIcons = new Array();
            _loc6_.rewardPairs = new Array();
            for each(_loc7_ in _loc3_.reward)
            {
               _loc12_ = int(_loc3_.@index);
               if(_loc7_.@rewardFeature.toString() == "true" && ExperimentsManager.instance.getExperimentVariant("empires_survival_autorefresh") > 2 && _loc12_ % 20 == 0 && !SurvivalModeManager.instance.isInEliteSurvivalModeBattle)
               {
                  _loc13_ = _loc12_ == 20 ? 0 : (_loc12_ == 40 ? 1 : 2);
                  _loc14_ = SurvivalModeManager.instance.survivalModeRewards[_loc13_];
                  _loc15_ = ZGlobal.gameSettings.getItemByCode(_loc14_,GameItem) as GameItem;
                  _loc6_.rewardText.push(ZGameUtils.ZlocT("Main","GenericItemAmount",{
                     "amount":1,
                     "item":_loc15_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)
                  }));
                  _loc6_.rewardIcons.push(ZGlobal.gameSettings.getImageByName(_loc15_.name,"icon"));
                  _loc16_ = {
                     "reward":_loc15_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME),
                     "count":1
                  };
                  if(_loc15_.isUnit())
                  {
                     _loc17_ = ZGlobal.gameSettings.getItemByCode(_loc14_,UnitItem) as UnitItem;
                     _loc16_["strength"] = _loc17_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc17_.code));
                  }
                  _loc6_.rewardPairs.push(_loc16_);
               }
               else
               {
                  _loc18_ = new RewardHelper(_loc7_);
                  _loc18_.buildUI(_loc6_,WorldResourceManager.LARGE_ICON);
               }
            }
            _loc8_ = Math.min(_loc5_.length,_loc6_.rewardText.length);
            _loc9_ = 142;
            _loc10_ = [-20,122,264];
            if(_loc8_ == 1)
            {
               _loc11_ = _loc9_;
            }
            else if(_loc8_ == 2)
            {
               _loc11_ = _loc9_ / 2;
            }
            _loc2_ = 0;
            while(_loc2_ < _loc8_)
            {
               _loc19_ = ImageLoaderFactory.CreateImageLoader(_loc6_.rewardIcons[_loc2_],_loc5_[_loc2_]);
               _loc19_.smooth = true;
               this.m_loaders.push(_loc19_);
               TextFieldUtil.compactTextField(_loc1_[_loc2_],ZGameUtils.ZlocT("Dialogs","WinRewardResult",{"reward":_loc6_.rewardText[_loc2_]}));
               _loc4_[_loc2_].x = _loc10_[_loc2_] + _loc11_;
               _loc4_[_loc2_].visible = true;
               _loc2_++;
            }
            while(_loc2_ < _loc4_.length)
            {
               _loc4_[_loc2_].visible = false;
               _loc2_++;
            }
         }
         else
         {
            TextFieldUtil.processTextField(this.mc.rewards_mc.rewards_tf," ");
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               TextFieldUtil.processTextField(_loc1_[_loc2_]," ");
               _loc2_++;
            }
         }
      }
      
      private function doFadeIn() : void
      {
         this.mc.gotoAndPlay(1);
      }
      
      private function doFadeOut() : void
      {
         this.mc.play();
      }
      
      private function doDelay() : void
      {
         this.mc.addFrameScript(PAUSE_FRAME,null);
         Zlab.processManager.schedule(this.m_delay,this,this.doFadeOut);
      }
      
      private function doExit() : void
      {
         this.mc.addFrameScript(END_FRAME,null);
         dispatchEvent(new Event(Event.COMPLETE));
         close();
      }
   }
}

