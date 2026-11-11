package displays.popups.survivalMode
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class SurvivalModeWelcomePopup extends GallantPopup
   {
      
      private static const WAVE_REWARD_INTERVAL:int = 5;
      
      private static const NUM_REWARD_TIERS:int = 3;
      
      private var m_set:String = null;
      
      private var m_eliteSet:String = null;
      
      private var m_callback:Function = null;
      
      private var m_goButton:ZGameButton = null;
      
      private var m_goButtonEpic:ZGameButton = null;
      
      private var m_loaders:Array = null;
      
      private var m_rewardIndex:Array = [20,40,60];
      
      public function SurvivalModeWelcomePopup(param1:String, param2:Function, param3:String = "")
      {
         this.m_set = param1;
         this.m_eliteSet = param3;
         this.m_callback = param2;
         super(ZGlobal.getAssetURL(this.assetURL));
      }
      
      private function get assetURL() : String
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON)
         {
            return "assets/displays/dialogs/PU_SurvivalMode_WelcomeElite.swf";
         }
         return "assets/displays/dialogs/PU_SurvivalMode_Welcome.swf";
      }
      
      override protected function initializeScreen() : void
      {
         var _loc2_:XML = null;
         super.initializeScreen();
         contentWidth = this.mc.panel_mc.width;
         contentHeight = this.mc.panel_mc.height;
         centerWithinStage(Zlab.mainStage);
         this.m_loaders = new Array();
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         this.m_goButton = new ZGameButton(this.mc.deploy_bt,this.onGoButton);
         this.m_goButton.text = ZGameUtils.ZlocT("Dialogs","Fight");
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON)
         {
            this.m_goButtonEpic = new ZGameButton(this.mc.deploy1_bt,this.onGoButtonEpic);
            TextFieldUtil.compactTextField(this.mc.sticker_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","SurvivalMode_Epic_Sticker"));
            if(!SurvivalModeManager.instance.isEliteModeUnlocked())
            {
               this.mc.levelLocked_mc.visible = true;
               this.m_goButtonEpic.disable();
               this.mc.levelLocked_mc.generic_tf.text = ZGameUtils.ZlocT("Dialogs","EliteSurvivalUnLockLevel");
            }
            else
            {
               this.mc.levelLocked_mc.visible = false;
               this.m_goButtonEpic.enable();
               this.mc.levelLocked_mc.generic_tf.text = "";
               this.m_goButtonEpic.text = ZGameUtils.ZlocT("Dialogs","EliteFight");
            }
         }
         TextFieldUtil.compactTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeWelcomeTitle"));
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON)
         {
            TextFieldUtil.compactTextField(this.mc.popupBox_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeWelcomeMessage_Epic_Enhancements",{"count":WAVE_REWARD_INTERVAL}));
         }
         else
         {
            TextFieldUtil.compactTextField(this.mc.popupBox_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeWelcomeMessage",{"count":WAVE_REWARD_INTERVAL}));
         }
         TextFieldUtil.compactTextField(this.mc.reward_tf_0,ZGameUtils.ZlocT("Dialogs","SurvivalModeWelcomeReward"));
         TextFieldUtil.compactTextField(this.mc.reward_tf_1,ZGameUtils.ZlocT("Dialogs","SurvivalModeWelcomeReward"));
         TextFieldUtil.compactTextField(this.mc.reward_tf_2,ZGameUtils.ZlocT("Dialogs","SurvivalModeWelcomeUltimate"));
         var _loc1_:Number = ExperimentsManager.instance.getExperimentVariant("empires_survival_autorefresh");
         if(_loc1_ <= 2)
         {
            _loc2_ = null;
            _loc2_ = SurvivalModeManager.instance.getXMLForSet(this.m_set);
            this.loadRewardsFromXML(_loc2_,false);
         }
         else
         {
            this.loadRewardsFromZRT();
         }
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON)
         {
            TextFieldUtil.compactTextField(this.mc.reward_tf_3,ZGameUtils.ZlocT("Dialogs","SurvivalModeWelcomeReward"));
            TextFieldUtil.compactTextField(this.mc.reward_tf_4,ZGameUtils.ZlocT("Dialogs","SurvivalModeWelcomeReward"));
            TextFieldUtil.compactTextField(this.mc.reward_tf_5,ZGameUtils.ZlocT("Dialogs","EliteSurvivalModeWelcomeUltimate"));
            _loc2_ = SurvivalModeManager.instance.getXMLForSet(this.m_eliteSet);
            this.loadRewardsFromXML(_loc2_,true);
         }
      }
      
      private function loadRewardsFromZRT() : void
      {
         var _loc1_:Object = SurvivalModeManager.instance.survivalModeRewards;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < 3)
         {
            this.populateUnitReward(_loc3_ + 1,this.m_rewardIndex[_loc3_],_loc1_[_loc3_],_loc2_);
            _loc3_++;
         }
      }
      
      private function loadRewardsFromXML(param1:XML, param2:Boolean = false) : void
      {
         var _loc3_:XML = null;
         if(param1)
         {
            for each(_loc3_ in param1.wave)
            {
               if(_loc3_.@rewardTier != undefined)
               {
                  if(SurvivalModeManager.instance.isInExperimentReward && !SurvivalModeManager.instance.bIsInBattle)
                  {
                     if(Boolean(_loc3_.experimentalrewards) && Boolean(_loc3_.experimentalrewards.reward))
                     {
                        this.getFeatureReward(true,param2,_loc3_);
                     }
                  }
                  else
                  {
                     this.getFeatureReward(false,param2,_loc3_);
                  }
               }
            }
         }
      }
      
      private function getFeatureReward(param1:Boolean, param2:Boolean, param3:XML) : void
      {
         var _loc5_:XML = null;
         var _loc4_:XMLList = param1 ? param3.experimentalrewards.reward : param3.reward;
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.@rewardFeature != undefined && _loc5_.@rewardFeature == "true")
            {
               this.populateUnitReward(param3.@rewardTier,param3.@index,_loc5_.@item,param2);
            }
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         if(this.m_goButton)
         {
            this.m_goButton.dispose();
         }
         if(this.m_goButtonEpic)
         {
            this.m_goButtonEpic.dispose();
         }
         for each(_loc1_ in this.m_loaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_loaders = null;
         super.deinitDialog();
      }
      
      private function get mc() : MovieClip
      {
         return m_window.clip_mc;
      }
      
      private function onGoButton(param1:MouseEvent) : void
      {
         if(this.m_callback != null)
         {
            SurvivalModeManager.instance.isEliteMode = false;
            if(this.m_set != null)
            {
               this.m_callback(this.m_set);
            }
            else
            {
               this.m_callback(SurvivalModeManager.SET_NAME_1);
            }
         }
         close();
      }
      
      private function onGoButtonEpic(param1:MouseEvent) : void
      {
         if(this.m_callback != null)
         {
            SurvivalModeManager.instance.isEliteMode = true;
            if(this.m_eliteSet != null)
            {
               this.m_callback(this.m_eliteSet);
            }
            else
            {
               this.m_callback(SurvivalModeManager.SET_NAME_6);
            }
         }
         close();
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         close();
      }
      
      private function populateUnitReward(param1:int, param2:int, param3:String, param4:Boolean = false) : void
      {
         var _loc9_:GameItem = null;
         var _loc10_:UnitItem = null;
         var _loc5_:Array = new Array();
         var _loc6_:Array = new Array();
         var _loc7_:Array = new Array();
         var _loc8_:Array = new Array();
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON && param4)
         {
            _loc5_ = [this.mc.wave_tf_3,this.mc.wave_tf_4,this.mc.wave_tf_5];
            _loc6_ = [this.mc.name_tf_3,this.mc.name_tf_4,this.mc.name_tf_5];
            _loc7_ = [this.mc.icon_3,this.mc.icon_4,this.mc.icon_5];
            _loc8_ = [this.mc.strength_mc_3,this.mc.strength_mc_4,this.mc.strength_mc_5];
         }
         else
         {
            _loc5_ = [this.mc.wave_tf_0,this.mc.wave_tf_1,this.mc.wave_tf_2];
            _loc6_ = [this.mc.name_tf_0,this.mc.name_tf_1,this.mc.name_tf_2];
            _loc7_ = [this.mc.icon_0,this.mc.icon_1,this.mc.icon_2];
            _loc8_ = [this.mc.strength_mc_0,this.mc.strength_mc_1,this.mc.strength_mc_2];
         }
         if(Boolean(param1 > 0 && param1 <= NUM_REWARD_TIERS) && Boolean(param3) && param3 != "")
         {
            _loc9_ = ZGlobal.gameSettings.getItemByCode(param3,GameItem) as GameItem;
            if(_loc9_)
            {
               TextFieldUtil.compactTextField(_loc5_[param1 - 1],ZGameUtils.ZlocT("Dialogs","SurvivalModeWave",{"wave":param2}));
               TextFieldUtil.compactTextField(_loc6_[param1 - 1],_loc9_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
               _loc10_ = ZGlobal.gameSettings.getItemByCode(param3,UnitItem) as UnitItem;
               if(_loc10_)
               {
                  TextFieldUtil.compactTextField(_loc8_[param1 - 1].strength_tf,String(_loc10_.getUpgradedStrength()));
                  _loc8_[param1 - 1].visible = true;
               }
               else
               {
                  _loc8_[param1 - 1].visible = false;
               }
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc9_.name,"icon"),_loc7_[param1 - 1]));
            }
         }
      }
   }
}

