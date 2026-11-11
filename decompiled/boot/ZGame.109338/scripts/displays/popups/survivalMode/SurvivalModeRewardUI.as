package displays.popups.survivalMode
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.managers.ExperimentsManager;
   import core.managers.WorldResourceManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class SurvivalModeRewardUI
   {
      
      private static const FADE_RATE:Number = 0.3;
      
      private var m_clip:MovieClip = null;
      
      private var m_loaders:Array = null;
      
      public function SurvivalModeRewardUI(param1:MovieClip)
      {
         super();
         this.m_clip = param1;
         this.m_clip.visible = false;
         this.m_clip.tooltip_mc.visible = false;
         TextFieldUtil.compactTextField(this.m_clip.header_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeNextRewardAt"),{
            "maxLines":1,
            "minScale":0.7
         });
         this.m_clip.bg_mc.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this.m_clip.bg_mc.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
      }
      
      public function dispose() : void
      {
         this.clearLoaders();
         this.m_clip.bg_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.m_clip.bg_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      public function set visible(param1:Boolean) : void
      {
         this.m_clip.visible = param1;
      }
      
      public function updateState() : void
      {
         var _loc3_:XML = null;
         var _loc4_:Boolean = false;
         var _loc5_:XML = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:XMLList = null;
         var _loc1_:int = SurvivalModeManager.instance.getCurrentRound();
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON && (SurvivalModeManager.instance.isInEliteSurvivalModeBattle || SurvivalModeManager.instance.isEliteMode))
         {
            TextFieldUtil.compactTextField(this.m_clip.current_tf,ZGameUtils.ZlocT("Dialogs","EliteSurvivalModeWave",{"wave":_loc1_}));
         }
         else
         {
            TextFieldUtil.compactTextField(this.m_clip.current_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeWave",{"wave":_loc1_}));
         }
         var _loc2_:String = SurvivalModeManager.instance.getSetInProgress();
         if(!_loc2_)
         {
            _loc2_ = SurvivalModeManager.instance.getCurrentSet();
         }
         if(_loc2_)
         {
            _loc3_ = SurvivalModeManager.instance.getXMLForSet(_loc2_);
            _loc4_ = false;
            for each(_loc5_ in _loc3_.wave)
            {
               if(!_loc4_ && _loc5_.@index != undefined && _loc5_.@index == _loc1_)
               {
                  _loc4_ = true;
               }
               _loc6_ = SurvivalModeManager.instance.isInExperimentReward && !SurvivalModeManager.instance.bIsInBattle ? int(_loc5_.experimentalrewards.reward.length()) : _loc5_.reward.length();
               if(_loc4_ && Boolean(_loc6_))
               {
                  _loc7_ = int(_loc5_.@index);
                  if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON && (SurvivalModeManager.instance.isInEliteSurvivalModeBattle || SurvivalModeManager.instance.isEliteMode))
                  {
                     TextFieldUtil.compactTextField(this.m_clip.wave_tf,ZGameUtils.ZlocT("Dialogs","EliteSurvivalModeWave",{"wave":_loc7_}));
                  }
                  else
                  {
                     TextFieldUtil.compactTextField(this.m_clip.wave_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeWave",{"wave":_loc7_}));
                  }
                  this.clearLoaders();
                  _loc8_ = SurvivalModeManager.instance.isInExperimentReward && !SurvivalModeManager.instance.bIsInBattle ? _loc5_.experimentalrewards.reward : _loc5_.reward;
                  if(_loc6_ & 1)
                  {
                     this.loadRewards(_loc8_,_loc7_,this.m_clip.tooltip_mc.rewards_odd);
                     this.m_clip.tooltip_mc.rewards_even.visible = false;
                  }
                  else
                  {
                     this.loadRewards(_loc8_,_loc7_,this.m_clip.tooltip_mc.rewards_even);
                     this.m_clip.tooltip_mc.rewards_odd.visible = false;
                  }
                  break;
               }
            }
         }
      }
      
      private function loadRewards(param1:XMLList, param2:int, param3:MovieClip) : void
      {
         var _loc5_:MovieClip = null;
         var _loc6_:int = 0;
         var _loc7_:XML = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:GameItem = null;
         var _loc11_:ImageLoader = null;
         var _loc4_:Array = [param3.rewardCard_01,param3.rewardCard_02,param3.rewardCard_03,param3.rewardCard_04];
         param3.visible = true;
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_)
            {
               _loc5_.visible = false;
            }
         }
         _loc6_ = param1.length() == 1 ? 1 : 0;
         for each(_loc7_ in param1)
         {
            if(Boolean(_loc7_.@rewardFeature.toString() == "true" && ExperimentsManager.instance.getExperimentVariant("empires_survival_autorefresh") > 2 && param2 % 20 == 0) && Boolean(_loc4_[_loc6_]) && !SurvivalModeManager.instance.isEliteMode)
            {
               _loc8_ = param2 == 20 ? 0 : (param2 == 40 ? 1 : 2);
               _loc9_ = SurvivalModeManager.instance.survivalModeRewards[_loc8_];
               _loc10_ = ZGlobal.gameSettings.getItemByCode(_loc9_,GameItem) as GameItem;
               _loc11_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc10_.name,"icon"),_loc4_[_loc6_].icon);
               _loc11_.smooth = true;
               this.m_loaders.push(_loc11_);
               TextFieldUtil.compactTextField(_loc4_[_loc6_].value_tf,ZGameUtils.ZlocT("Dialogs","WinRewardResult",{"reward":1}));
               _loc4_[_loc6_].visible = true;
            }
            else
            {
               this.loadRewardIcon(_loc7_,_loc4_[_loc6_]);
            }
            _loc6_++;
         }
      }
      
      private function loadRewardIcon(param1:XML, param2:MovieClip) : void
      {
         var _loc3_:Object = null;
         var _loc4_:RewardHelper = null;
         var _loc5_:ImageLoader = null;
         if(Boolean(param1) && Boolean(param2))
         {
            param2.visible = true;
            _loc3_ = {
               "rewardText":new Array(),
               "rewardIcons":new Array(),
               "rewardPairs":new Array()
            };
            _loc4_ = new RewardHelper(param1);
            _loc4_.buildUI(_loc3_,WorldResourceManager.SMALL_ICON);
            _loc5_ = ImageLoaderFactory.CreateImageLoader(_loc3_.rewardIcons[0],param2.icon);
            _loc5_.smooth = true;
            this.m_loaders.push(_loc5_);
            TextFieldUtil.compactTextField(param2.value_tf,ZGameUtils.ZlocT("Dialogs","WinRewardResult",{"reward":_loc3_.rewardPairs[0].count}));
         }
      }
      
      private function clearLoaders() : void
      {
         this.m_loaders = new Array();
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         TweenLite.killTweensOf(this.m_clip.tooltip_mc);
         this.m_clip.tooltip_mc.alpha = 0;
         this.m_clip.tooltip_mc.visible = true;
         TweenLite.to(this.m_clip.tooltip_mc,FADE_RATE,{"alpha":1});
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         TweenLite.killTweensOf(this.m_clip.tooltip_mc);
         this.m_clip.tooltip_mc.alpha = 1;
         TweenLite.to(this.m_clip.tooltip_mc,FADE_RATE * 2,{"alpha":0});
      }
   }
}

