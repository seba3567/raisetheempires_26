package core.ui.components.PortraitSlidePick
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationName;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gamemode.GMSell;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.ChallengeModeManager;
   import core.managers.ExperimentsManager;
   import core.managers.PVPManager;
   import core.managers.WorldObjectManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.IPVPPlayer;
   import core.player.Player;
   import core.player.PlayerDummy;
   import core.player.PlayerNonFriend;
   import core.player.PlayerVillain;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.PVPCombatStartPopup;
   import displays.popups.SpecialForcesMissionReportPopup;
   import displays.screens.PVPRepelGather;
   import displays.screens.contractScreen.MissionContractSlot;
   import fl.containers.UILoader;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.Timer;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import sound.SoundEvent;
   import transactions.TUseStrikeTeam;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class PortraitSlidePickPVP extends PortraitSlidePick
   {
      
      private var m_owner:IEntity;
      
      private var m_pickClass:Class;
      
      private var m_dissolveHelper:PortraitPickDissolveHelper;
      
      private var m_pvpLoader:ImageLoader = null;
      
      private var m_missionItemCodes:Array = [PVPManager.MISSION_AMBUSH,PVPManager.MISSION_MIND_CONTROL,PVPManager.MISSION_AMBUSH2];
      
      private var m_missionStringNames:Array = ["Ambush","MindControl","TotalAmbush"];
      
      private var m_missionIconLoaders:Array;
      
      private var m_missionItemCode:String = null;
      
      private var m_missionTargetId:String = null;
      
      protected var m_repelButton:ZGameButton;
      
      protected var m_askForHelpButton:ZGameButton;
      
      protected var m_continueButton:ZGameButton;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_invader:Object;
      
      protected var m_missionButton:ZGameButton;
      
      protected var m_deployButton:ZGameButton;
      
      protected var m_animTimer:Timer;
      
      protected var m_missionDeployMode:String;
      
      public function PortraitSlidePickPVP(param1:IEntity, param2:IPVPPlayer, param3:Number, param4:Class, param5:Object)
      {
         this.m_invader = param5;
         this.m_owner = param1;
         this.m_pickClass = param4;
         super(param2,param3);
         PVPManager.instance.addEventListener(PVPManager.REMOVE_MARKER,this.onRemoveMarker,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.DISABLE_MARKER,this.onDisableMarker,false,0,true);
         PVPManager.instance.addEventListener(PVPManager.UPDATE_MARKER,this.onUpdateMarker,false,0,true);
         PVPManager.instance.addEventListener(this.getCommentListenerType(),this.onUpdateComment,false,0,true);
         UIDispatcher.instance.addEventListener(MissionContractSlot.UNLOCK_MISSION,this.onUnlockMission,false,0,true);
         if(WorldObjectManager.instance.getNumberBuiltObjectsWithCode(PVPManager.STRIKE_TEAM_BUILDING) == 0)
         {
            WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_BUILT,this.onObjectBuilt,false,0,true);
         }
      }
      
      protected function getCommentListenerType() : String
      {
         return PVPManager.UPDATE_TAUNT;
      }
      
      override protected function getPickClass() : Class
      {
         return this.m_pickClass;
      }
      
      override protected function onDispose() : void
      {
         super.onDispose();
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         if(this.m_repelButton)
         {
            this.m_repelButton.dispose();
            this.m_repelButton = null;
         }
         if(this.m_askForHelpButton)
         {
            this.m_askForHelpButton.dispose();
            this.m_askForHelpButton = null;
         }
         if(this.m_continueButton)
         {
            this.m_continueButton.dispose();
            this.m_continueButton = null;
         }
         if(this.m_missionButton)
         {
            this.m_missionButton.dispose();
            this.m_missionButton = null;
         }
         if(this.m_deployButton)
         {
            this.m_deployButton.dispose();
            this.m_deployButton = null;
         }
         if(this.m_dissolveHelper)
         {
            this.m_dissolveHelper.removeEventListener(PortraitPickDissolveHelper.HIDE,this.onDissolveHide);
            this.m_dissolveHelper.removeEventListener(PortraitPickDissolveHelper.DONE,this.onDissolveDone);
            this.m_dissolveHelper.dispose();
            this.m_dissolveHelper = null;
         }
         if(this.m_pvpLoader)
         {
            this.m_pvpLoader.destroy();
            this.m_pvpLoader = null;
         }
         if(Boolean(m_pick) && Boolean(m_pick.bubble))
         {
            Tooltip.unsubscribe(m_pick.bubble);
         }
         PVPManager.instance.removeEventListener(PVPManager.REMOVE_MARKER,this.onRemoveMarker);
         PVPManager.instance.removeEventListener(PVPManager.DISABLE_MARKER,this.onDisableMarker);
         PVPManager.instance.removeEventListener(PVPManager.UPDATE_MARKER,this.onUpdateMarker);
         PVPManager.instance.removeEventListener(this.getCommentListenerType(),this.onUpdateComment);
         PVPManager.instance.removeEventListener(PVPManager.MISSION_DEPLOY_MODE,this.onMissionDeployMode);
         PVPManager.instance.removeEventListener(PVPManager.STRIKE_TEAM_DEPLOYED,this.onStrikeTeamDeployed);
         UIDispatcher.instance.removeEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdatedForMissions);
         UIDispatcher.instance.removeEventListener(MissionContractSlot.UNLOCK_MISSION,this.onUnlockMission);
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_BUILT,this.onObjectBuilt);
         this.m_owner = null;
      }
      
      override protected function get yOffset() : int
      {
         return -100;
      }
      
      override protected function get portraitUILoader() : UILoader
      {
         return portraitBubble.player.portrait_mc;
      }
      
      override protected function onCreatePickAsset(param1:IPVPPlayer) : void
      {
         var _loc5_:Number = NaN;
         super.onCreatePickAsset(param1);
         this.setButtons();
         this.setPickText();
         var _loc2_:String = param1.genderTag;
         var _loc3_:String = param1.firstName;
         var _loc4_:LocalizationName = ZLoc.tn(_loc3_,_loc2_);
         if(ZGlobal.localizer.localeCode == "ja_JP")
         {
            _loc5_ = 2.5;
            slideCard.title_tf.y -= _loc5_;
         }
         TextFieldUtil.processTextField(slideCard.title_tf,_loc4_.getString());
         TextFieldUtil.processTextField(portraitBubble.generic_tf,_loc4_.getString());
         this.setupIcon();
         this.updateComment();
      }
      
      protected function setupIcon() : void
      {
         var _loc1_:String = ZGlobal.getAssetURL(this.getIconURL());
         this.m_pvpLoader = ImageLoaderFactory.CreateImageLoader(_loc1_,m_pick.bubble.action_icon);
      }
      
      protected function getIconURL() : String
      {
         return "assets/game/GeneralAssetGroup_UI.swf/playerOccupying_icon_24.png";
      }
      
      protected function setButtons() : void
      {
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_repelButton = new ZGameButton(slideCard.green_btn_0,this.onRepel);
         this.m_buttonSounds.addButton(this.m_repelButton.m_overlay,ButtonSound.DEFAULT);
         this.m_askForHelpButton = new ZGameButton(slideCard.orange_btn,this.onAskForHelp);
         if(PVPManager.instance.isInvaderManualRepelOnly(neighborID))
         {
            ZGameUtils.disableButton(slideCard.orange_btn,this.onAskForHelp);
            this.m_askForHelpButton.disable();
         }
         else
         {
            this.m_buttonSounds.addButton(this.m_askForHelpButton.m_overlay,ButtonSound.DEFAULT);
         }
         if(hasStrikeTeamAssets())
         {
            this.m_deployButton = new ZGameButton(m_pick.bubble.deploy_btn,this.onDeployButton,1.1,true);
            this.m_deployButton.text = ZGameUtils.ZlocT("Dialogs","MissionSelectionDeployButtonText");
            this.m_buttonSounds.addButton(this.m_deployButton.m_overlay,ButtonSound.DEFAULT);
            this.m_missionButton = new ZGameButton(slideCard.missionTab_mc.mission_btn,this.onMissionButton);
            this.m_missionButton.text = ZGameUtils.ZlocT("Dialogs","StrikeTeam");
            this.m_buttonSounds.addButton(this.m_missionButton.m_overlay,ButtonSound.DEFAULT);
         }
         if(slideCard.green_btn_1)
         {
            slideCard.green_btn_1.visible = false;
            this.m_continueButton = new ZGameButton(slideCard.green_btn_1,this.onRepel);
            this.m_continueButton.text = ZGameUtils.ZlocT("Dialogs","InProgressButton");
            this.m_continueButton.disable();
            this.onUpdateMarker(null);
         }
      }
      
      private function onUpdateMarker(param1:WorldEvent) : void
      {
         var _loc2_:Object = null;
         this.updateComment();
         if(hasStrikeTeamAssets())
         {
            slideCard.missionTab_mc.visible = false;
            slideCard.missionTab_mc.missionUI_mc.visible = false;
            PVPManager.instance.removeEventListener(PVPManager.MISSION_DEPLOY_MODE,this.onMissionDeployMode);
            PVPManager.instance.removeEventListener(PVPManager.STRIKE_TEAM_DEPLOYED,this.onStrikeTeamDeployed);
            UIDispatcher.instance.removeEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdatedForMissions);
         }
         this.m_missionItemCode = null;
         this.m_missionTargetId = null;
         if(slideCard.green_btn_1)
         {
            if(PVPManager.instance.isNormalVisit() && !ZGlobal.isHome())
            {
               this.setPickText();
            }
            else if(PVPManager.instance.isInvaderManualRepelOnly(neighborID))
            {
               slideCard.green_btn_1.visible = true;
               slideCard.green_btn_0.visible = false;
               slideCard.orange_btn.visible = false;
               slideCard.missionTab_mc.mission_btn.visible = false;
               this.m_continueButton.text = ZGameUtils.ZlocT("Dialogs","RepelButton");
               this.m_continueButton.enable();
               this.m_buttonSounds.addButton(this.m_continueButton.m_overlay,ButtonSound.DEFAULT);
               this.m_repelButton.disable();
               this.m_buttonSounds.removeButton(this.m_repelButton.m_overlay);
               this.m_askForHelpButton.disable();
               this.m_buttonSounds.removeButton(this.m_askForHelpButton.m_overlay);
               this.m_missionButton.disable();
               this.m_buttonSounds.removeButton(this.m_missionButton.m_overlay);
            }
            else
            {
               _loc2_ = PVPManager.instance.getInvadersChallenge(neighborID);
               if(Boolean(_loc2_) && _loc2_.state == ChallengeModeManager.CHALLENGE_STATE_IN_PROGRESS)
               {
                  slideCard.green_btn_1.visible = true;
                  slideCard.green_btn_0.visible = false;
                  slideCard.orange_btn.visible = false;
                  slideCard.missionTab_mc.mission_btn.visible = false;
                  this.m_continueButton.enable();
                  this.m_buttonSounds.addButton(this.m_continueButton.m_overlay,ButtonSound.DEFAULT);
                  this.m_repelButton.disable();
                  this.m_buttonSounds.removeButton(this.m_repelButton.m_overlay);
                  this.m_askForHelpButton.disable();
                  this.m_buttonSounds.removeButton(this.m_askForHelpButton.m_overlay);
                  this.m_missionButton.disable();
                  this.m_buttonSounds.removeButton(this.m_missionButton.m_overlay);
               }
               else if(this.missionUIEnabled())
               {
                  slideCard.missionTab_mc.visible = true;
                  slideCard.green_btn_1.visible = false;
                  this.m_continueButton.disable();
                  this.m_buttonSounds.removeButton(this.m_continueButton.m_overlay);
                  slideCard.green_btn_0.visible = true;
                  this.m_repelButton.enable();
                  this.m_buttonSounds.addButton(this.m_repelButton.m_overlay,ButtonSound.DEFAULT);
                  slideCard.orange_btn.visible = false;
                  this.m_askForHelpButton.disable();
                  this.m_buttonSounds.removeButton(this.m_askForHelpButton.m_overlay);
                  slideCard.missionTab_mc.mission_btn.visible = true;
                  this.m_missionButton.enable();
                  this.m_buttonSounds.addButton(this.m_missionButton.m_overlay,ButtonSound.DEFAULT);
                  PVPManager.instance.addEventListener(PVPManager.MISSION_DEPLOY_MODE,this.onMissionDeployMode,false,0,true);
                  PVPManager.instance.addEventListener(PVPManager.STRIKE_TEAM_DEPLOYED,this.onStrikeTeamDeployed,false,0,true);
                  UIDispatcher.instance.addEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdatedForMissions,false,0,true);
                  this.updateMissionUI();
               }
               else
               {
                  slideCard.green_btn_1.visible = false;
                  slideCard.green_btn_0.visible = true;
                  slideCard.orange_btn.visible = true;
                  slideCard.missionTab_mc.mission_btn.visible = false;
                  this.m_continueButton.disable();
                  this.m_buttonSounds.removeButton(this.m_continueButton.m_overlay);
                  this.m_repelButton.enable();
                  this.m_buttonSounds.addButton(this.m_repelButton.m_overlay,ButtonSound.DEFAULT);
                  if(!PVPManager.instance.isInvaderManualRepelOnly(neighborID))
                  {
                     this.m_askForHelpButton.enable();
                     this.m_buttonSounds.addButton(this.m_askForHelpButton.m_overlay,ButtonSound.DEFAULT);
                  }
                  else
                  {
                     this.m_buttonSounds.removeButton(this.m_askForHelpButton.m_overlay);
                  }
                  this.m_missionButton.disable();
                  this.m_buttonSounds.removeButton(this.m_missionButton.m_overlay);
               }
            }
         }
      }
      
      protected function missionCardFromIndex(param1:int) : MovieClip
      {
         if(!slideCard || !slideCard.missionTab_mc || !slideCard.missionTab_mc.missionUI_mc || !slideCard.missionTab_mc.missionUI_mc.missionPanel_mc)
         {
            return null;
         }
         switch(param1)
         {
            case 0:
               return slideCard.missionTab_mc.missionUI_mc.missionPanel_mc.missionCard01_mc;
            case 1:
               return slideCard.missionTab_mc.missionUI_mc.missionPanel_mc.missionCard02_mc;
            case 2:
               return slideCard.missionTab_mc.missionUI_mc.missionPanel_mc.missionCard03_mc;
            case 3:
               return slideCard.missionTab_mc.missionUI_mc.missionPanel_mc.missionCard04_mc;
            default:
               return null;
         }
      }
      
      private function onObjectBuilt(param1:WorldEvent) : void
      {
         var _loc2_:String = param1.eventData as String;
         if(Boolean(_loc2_) && _loc2_ == PVPManager.STRIKE_TEAM_BUILDING)
         {
            this.onUpdateMarker(param1);
            WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_BUILT,this.onObjectBuilt);
         }
      }
      
      protected function missionUIEnabled() : Boolean
      {
         if(PVPManager.instance.isInvaderManualRepelOnly(neighborID))
         {
            return false;
         }
         if(TutorialManager.instance.active && TutorialManager.instance.pvpTutorialMode)
         {
            return false;
         }
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SPECOPS_PARTS) < ZGlobal.EXPERIMENT_MISSION_BUILDABLE_PARTS_V3)
         {
            return false;
         }
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(PVPManager.STRIKE_TEAM_BUILDING,GameItem) as GameItem;
         if(ZGlobal.player.level < _loc1_.requiredLevel)
         {
            return false;
         }
         if(WorldObjectManager.instance.getNumberBuiltObjectsWithCode(PVPManager.STRIKE_TEAM_BUILDING) == 0)
         {
            return false;
         }
         return true;
      }
      
      protected function onInventoryUpdatedForMissions(param1:WorldEvent) : void
      {
         this.updateMissionUI();
      }
      
      protected function updateMissionUI() : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Boolean = false;
         var _loc4_:String = null;
         var _loc5_:GameItem = null;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:ImageLoader = null;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:String = null;
         var _loc12_:String = null;
         this.m_missionIconLoaders = new Array();
         var _loc1_:int = 0;
         while(_loc1_ < 4)
         {
            _loc2_ = this.missionCardFromIndex(_loc1_);
            if(_loc2_)
            {
               _loc3_ = _loc1_ < this.m_missionItemCodes.length;
               _loc2_.visible = false;
               _loc2_.tooltip_mc.visible = false;
               _loc2_.icon_mc.removeEventListener(MouseEvent.MOUSE_OVER,this.onMissionMouseOver);
               _loc2_.icon_mc.removeEventListener(MouseEvent.MOUSE_OUT,this.onMissionMouseOut);
               _loc2_.icon_mc.removeEventListener(MouseEvent.CLICK,this.onMissionClick);
               _loc4_ = this.m_missionItemCodes[_loc1_];
               _loc2_.missionData = {
                  "cardIdx":_loc1_,
                  "code":_loc4_,
                  "enabled":false
               };
               if(_loc3_)
               {
                  _loc5_ = ZGlobal.gameSettings.getItemByCode(this.m_missionItemCodes[_loc1_],GameItem) as GameItem;
                  if(_loc5_)
                  {
                     _loc2_.visible = _loc3_;
                     _loc6_ = ZGlobal.player.getNumberOfInventoryItems(_loc4_);
                     TextFieldUtil.processTextField(_loc2_.qty_tf,_loc6_.toString());
                     _loc7_ = ZGlobal.gameSettings.getImageByName(_loc5_.name,"pickIcon");
                     _loc8_ = ImageLoaderFactory.CreateImageLoader(_loc7_,_loc2_.icon_mc);
                     this.m_missionIconLoaders.push(_loc8_);
                     _loc2_.icon_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onMissionMouseOver,false,0,true);
                     _loc2_.icon_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onMissionMouseOut,false,0,true);
                     _loc9_ = _loc6_ == 0;
                     _loc10_ = ZGlobal.player.checkGate(_loc5_).isBitSet(Player.GATE_FAILURE_CONSUMABLES_USED);
                     _loc11_ = _loc5_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                     _loc12_ = this.m_missionStringNames[_loc1_];
                     if(!_loc9_ && !_loc10_)
                     {
                        _loc2_.filters = new Array();
                        _loc2_.missionData.enabled = true;
                        TextFieldUtil.processTextField(_loc2_.tooltip_mc.tooltipText_tf,_loc11_);
                        _loc2_.icon_mc.addEventListener(MouseEvent.CLICK,this.onMissionClick,false,0,true);
                     }
                     else
                     {
                        _loc2_.gotoAndStop("disabled");
                     }
                     if(_loc10_)
                     {
                        _loc2_.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
                        TextFieldUtil.processTextField(_loc2_.tooltip_mc.tooltipText_tf,ZGameUtils.ZlocT("Tooltips","StrikeTeam_" + _loc12_ + "Locked"));
                     }
                     else if(_loc9_)
                     {
                        TextFieldUtil.processTextField(_loc2_.tooltip_mc.tooltipText_tf,ZGameUtils.ZlocT("Tooltips","StrikeTeam_" + _loc12_ + "NoneAvailable"));
                     }
                  }
               }
            }
            _loc1_++;
         }
      }
      
      private function cardFromMissionIconEvent(param1:MouseEvent) : MovieClip
      {
         return param1.currentTarget.parent as MovieClip;
      }
      
      private function onMissionMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = this.cardFromMissionIconEvent(param1);
         _loc2_.tooltip_mc.visible = true;
         if(_loc2_.missionData.enabled)
         {
            _loc2_.gotoAndStop("over");
         }
      }
      
      private function onMissionMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = this.cardFromMissionIconEvent(param1);
         _loc2_.tooltip_mc.visible = false;
         if(_loc2_.missionData.enabled)
         {
            _loc2_.gotoAndStop("out");
         }
      }
      
      private function onMissionButton(param1:MouseEvent) : void
      {
         slideCard.missionTab_mc.missionUI_mc.visible = !slideCard.missionTab_mc.missionUI_mc.visible;
      }
      
      private function onMissionClick(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = this.cardFromMissionIconEvent(param1);
         _loc2_.gotoAndStop("down");
         this.onStrikeTeam(_loc2_,_loc2_.missionData.code);
      }
      
      private function onMissionEffectFinished() : void
      {
         var _loc1_:SpecialForcesMissionReportPopup = null;
         if(m_neighbor.uid == this.m_missionTargetId && m_neighbor.uid != PVPManager.PVE_MARKER_KEY)
         {
            _loc1_ = new SpecialForcesMissionReportPopup(this.m_missionItemCode,this.m_missionTargetId);
            PopupManager.instance.push(_loc1_);
         }
         PVPManager.instance.acceptRepelLocal(m_neighbor.uid);
      }
      
      private function onMissionAnimFinished(param1:TimerEvent) : void
      {
         this.m_animTimer.removeEventListener(TimerEvent.TIMER,this.onMissionAnimFinished);
         this.m_animTimer = null;
         this.onMissionEffectFinished();
      }
      
      private function onReplacementPortraitLoaded(param1:String, param2:BitmapData) : void
      {
      }
      
      private function onSwirlyFadeInFinished(param1:TimerEvent) : void
      {
         this.m_animTimer.removeEventListener(TimerEvent.TIMER,this.onSwirlyFadeInFinished);
         this.m_animTimer = null;
         ImageLoaderFactory.CreateImageLoader(ZGlobal.player.portraitURL,this.portraitUILoader,this.onReplacementPortraitLoaded);
         this.m_animTimer = new Timer(1000);
         this.m_animTimer.addEventListener(TimerEvent.TIMER,this.onSwirlyHoldFinished);
         this.m_animTimer.start();
      }
      
      private function onSwirlyHoldFinished(param1:TimerEvent) : void
      {
         this.m_animTimer.removeEventListener(TimerEvent.TIMER,this.onSwirlyHoldFinished);
         this.m_animTimer = null;
         TweenLite.to(m_pick.bubble.player.mindControlSwirl_mc,1,{"alpha":0});
         this.m_animTimer = new Timer(1000);
         this.m_animTimer.addEventListener(TimerEvent.TIMER,this.onSwirlyFadeOutFinished);
         this.m_animTimer.start();
      }
      
      private function onSwirlyFadeOutFinished(param1:TimerEvent) : void
      {
         this.m_animTimer.removeEventListener(TimerEvent.TIMER,this.onSwirlyFadeOutFinished);
         this.m_animTimer = null;
         this.onMissionEffectFinished();
      }
      
      private function onStrikeTeam(param1:MovieClip, param2:String) : void
      {
         PVPManager.instance.removeEventListener(PVPManager.MISSION_DEPLOY_MODE,this.onMissionDeployMode);
         PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.STRIKE_TEAM_DEPLOYED,{
            "strikeTeam":param2,
            "neighborId":m_neighbor.uid
         }));
         ZGlobal.player.onConsumableUsed(param2);
         PVPManager.instance.removeEventListener(PVPManager.UPDATE_MARKER,this.onUpdateMarker);
         PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.UPDATE_MARKER));
      }
      
      protected function onStrikeTeamDeployed(param1:WorldEvent) : void
      {
         var _loc4_:Number = NaN;
         PVPManager.instance.removeEventListener(PVPManager.STRIKE_TEAM_DEPLOYED,this.onStrikeTeamDeployed);
         var _loc2_:String = param1.eventData.strikeTeam;
         var _loc3_:String = param1.eventData.neighborId;
         this.m_missionItemCode = _loc2_;
         this.m_missionTargetId = _loc3_;
         if(this.m_missionItemCode == PVPManager.MISSION_AMBUSH || this.m_missionItemCode == PVPManager.MISSION_AMBUSH2)
         {
            if(this.m_missionItemCode == PVPManager.MISSION_AMBUSH2 || m_neighbor.uid == _loc3_)
            {
               if(m_pick.bubble.bulletHoles_mc)
               {
                  m_pick.bubble.bulletHoles_mc.visible = true;
                  _loc4_ = 1000 * m_pick.bubble.bulletHoles_mc.framesLoaded / Zlab.mainStage.frameRate;
                  this.m_animTimer = new Timer(_loc4_);
                  this.m_animTimer.addEventListener(TimerEvent.TIMER,this.onMissionAnimFinished);
                  this.m_animTimer.start();
                  m_pick.bubble.bulletHoles_mc.gotoAndStop(1);
                  m_pick.bubble.bulletHoles_mc.gotoAndPlay(1);
                  SoundEvent.getSoundEvent("MachineGunHit").play();
               }
               if(m_neighbor.uid == this.m_missionTargetId)
               {
                  ZGlobal.player.removeInventoryItem(this.m_missionItemCode);
                  StatsManager.count("mission","deploy",this.m_missionItemCode);
                  TransactionManager.addTransaction(new TUseStrikeTeam(this.m_missionItemCode,m_neighbor.uid));
               }
               PVPManager.instance.doStrikeTeamPillage(m_neighbor.uid,this.m_missionItemCode);
               PVPManager.instance.removeEventListener(PVPManager.STRIKE_TEAM_DEPLOYED,this.onStrikeTeamDeployed);
               ignoreMouseInput();
               this.pickExited();
               hide();
               if(!m_pick.bubble.bulletHoles_mc)
               {
                  this.onMissionEffectFinished();
               }
            }
         }
         else if(this.m_missionItemCode == PVPManager.MISSION_MIND_CONTROL && m_neighbor.uid == _loc3_)
         {
            m_pick.bubble.player.mindControlSwirl_mc.alpha = 0;
            m_pick.bubble.player.mindControlSwirl_mc.visible = true;
            TweenLite.to(m_pick.bubble.player.mindControlSwirl_mc,1,{"alpha":1});
            this.m_animTimer = new Timer(1000);
            this.m_animTimer.addEventListener(TimerEvent.TIMER,this.onSwirlyFadeInFinished);
            this.m_animTimer.start();
            SoundEvent.getSoundEvent("Roulette").play();
            if(m_neighbor.uid == this.m_missionTargetId)
            {
               ZGlobal.player.removeInventoryItem(this.m_missionItemCode);
               StatsManager.count("mission","deploy",this.m_missionItemCode);
               TransactionManager.addTransaction(new TUseStrikeTeam(this.m_missionItemCode,m_neighbor.uid));
            }
            PVPManager.instance.doStrikeTeamPillage(m_neighbor.uid,this.m_missionItemCode);
            PVPManager.instance.removeEventListener(PVPManager.STRIKE_TEAM_DEPLOYED,this.onStrikeTeamDeployed);
            ignoreMouseInput();
            this.pickExited();
            hide();
         }
      }
      
      protected function onMissionDeployModeClick(param1:WorldEvent) : void
      {
         if(m_pick.bubble.deploy_btn.mouseX >= 0 && m_pick.bubble.deploy_btn.mouseX < m_pick.bubble.deploy_btn.width && m_pick.bubble.deploy_btn.mouseY >= 0 && m_pick.bubble.deploy_btn.mouseY < m_pick.bubble.deploy_btn.height)
         {
            this.onDeployButton(param1.eventData.mouseEvent);
         }
      }
      
      protected function onMissionDeployMode(param1:WorldEvent) : void
      {
         if(Boolean(param1.eventData.active) && !ignoringMouseInput)
         {
            m_pick.bubble.deploy_btn.visible = true;
            m_pick.bubble.pickGlow.visible = true;
            this.m_deployButton.enable();
            this.m_missionItemCode = param1.eventData.strikeTeam;
            PVPManager.instance.addEventListener(PVPManager.MISSION_DEPLOY_MODE_CLICK,this.onMissionDeployModeClick,false,0,true);
         }
         else
         {
            m_pick.bubble.deploy_btn.visible = false;
            m_pick.bubble.pickGlow.visible = false;
            this.m_deployButton.disable();
            PVPManager.instance.removeEventListener(PVPManager.MISSION_DEPLOY_MODE_CLICK,this.onMissionDeployModeClick);
         }
      }
      
      protected function onDeployButton(param1:MouseEvent) : void
      {
         if(m_pick.bubble.deploy_btn)
         {
            m_pick.bubble.deploy_btn.visible = false;
         }
         if(m_pick.bubble.pickGlow)
         {
            m_pick.bubble.pickGlow.visible = false;
         }
         this.onStrikeTeam(null,this.m_missionItemCode);
      }
      
      override protected function pickExited() : void
      {
         super.pickExited();
      }
      
      protected function setPickText() : void
      {
         this.m_repelButton.text = ZGameUtils.ZlocT("Dialogs","RepelButton");
         this.m_askForHelpButton.text = ZGameUtils.ZlocT("Dialogs","PVPAskForHelpButton");
         slideCard.title01_tf.visible = true;
         TextFieldUtil.processTextField(slideCard.title01_tf,ZGameUtils.ZlocT("Dialogs","InvadedText"));
         var _loc1_:Number = PVPManager.instance.AccelerationPillageMultiplier();
         if(_loc1_ > 1)
         {
            TextFieldUtil.processTextField(slideCard.title02_tf,ZGameUtils.ZlocT("Dialogs","AccelerationPVPPillageMultiplier",{"multiplier":_loc1_}));
         }
      }
      
      private function doFriendRepel(param1:String) : void
      {
         ChallengeModeManager.instance.startNeighborRepel(ZGlobal.hostPlayer.uid,param1);
      }
      
      protected function onRepel(param1:MouseEvent) : void
      {
         var _loc2_:PVPCombatStartPopup = null;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         if(status == PortraitSlidePick.PICK_STATUS_SHOWING)
         {
            if(PVPManager.instance.isNormalVisit() && !ZGlobal.isHome())
            {
               if(Boolean(m_neighbor as Player) || Boolean(m_neighbor as PlayerNonFriend) || Boolean(m_neighbor as PlayerVillain))
               {
                  this.doFriendRepel(neighborID);
               }
            }
            else if(Boolean(m_neighbor as Player) || Boolean(m_neighbor as PlayerDummy))
            {
               if(ChallengeModeManager.instance.onSelectChallengerPlayer(neighborID))
               {
                  _loc2_ = new PVPCombatStartPopup(ZGlobal.player,m_neighbor);
                  PVPManager.instance.setAndShowCombatPopup(_loc2_);
               }
            }
            else
            {
               _loc3_ = false;
               PVPManager.instance.doPveRepel(_loc3_);
            }
            if(TutorialManager.instance.active && TutorialManager.instance.pvpTutorialMode)
            {
               _loc4_ = PVPManager.instance.isInvaderQuestPVE(neighborID);
               TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.PVP_REPEL_CLICKED,{"quest":_loc4_}));
            }
            onStopPropagation(param1);
            this.pickExited();
            hide();
         }
      }
      
      protected function onAskForHelp(param1:MouseEvent) : void
      {
         var _loc2_:CrewTemplateWrapper = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:LocalizationName = null;
         if(status == PortraitSlidePick.PICK_STATUS_SHOWING)
         {
            _loc2_ = ZGlobal.gameSettings.getCrewTemplateWrapper("PVPFriendAssist");
            _loc3_ = PVPManager.instance.getSocialHelpersForInvasion(neighborID);
            _loc4_ = m_neighbor.genderTag;
            _loc5_ = ZLoc.tn(m_neighbor.name,_loc4_);
            WindowManager.instance.push(new PVPRepelGather(_loc2_,_loc3_,_loc5_.getString(),m_neighbor.uid));
            onStopPropagation(param1);
            this.pickExited();
            hide();
         }
      }
      
      private function startDissolve(param1:int) : void
      {
         hide();
         this.pickExited();
         ignoreMouseInput();
         if(this.m_missionItemCode != null)
         {
            param1 = PVPManager.MARKER_FADE_ALPHA;
         }
         switch(param1)
         {
            case PVPManager.MARKER_FADE_ALPHA:
               this.m_dissolveHelper = new PortraitPickDissolveHelperAlpha(m_pick);
               break;
            case PVPManager.MARKER_FADE_EMBERS:
               this.m_dissolveHelper = new PortraitPickDissolveHelperEmbers(m_pick);
         }
         if(this.m_dissolveHelper)
         {
            this.m_dissolveHelper.addEventListener(PortraitPickDissolveHelper.HIDE,this.onDissolveHide,false,0,true);
            this.m_dissolveHelper.addEventListener(PortraitPickDissolveHelper.DONE,this.onDissolveDone,false,0,true);
         }
      }
      
      private function onDissolveHide(param1:Event) : void
      {
         m_pick.bubble.visible = false;
         m_pick.card_mc.visible = false;
      }
      
      private function onDissolveDone(param1:Event) : void
      {
         GMSell.clearObject(this.m_owner,true);
      }
      
      private function onRemoveMarker(param1:WorldEvent) : void
      {
         if(m_neighbor.uid == String(param1.eventData.invaderID))
         {
            if(param1.eventData.fadeType)
            {
               this.startDissolve(param1.eventData.fadeType);
            }
            else
            {
               GMSell.clearObject(this.m_owner,true);
            }
            PVPManager.instance.removeEventListener(PVPManager.REMOVE_MARKER,this.onRemoveMarker);
         }
      }
      
      private function onDisableMarker(param1:WorldEvent) : void
      {
         if(param1.eventData.invID == m_neighbor.uid)
         {
            hide();
            this.pickExited();
            ignoreMouseInput();
         }
      }
      
      protected function getCommentText() : String
      {
         if(Boolean(this.m_invader) && Boolean(this.m_invader.iTxt))
         {
            return this.m_invader.iTxt;
         }
         return null;
      }
      
      private function onUpdateComment(param1:WorldEvent) : void
      {
         if(this.m_invader.chID == param1.eventData.chID)
         {
            this.m_invader = param1.eventData;
            this.updateComment();
         }
      }
      
      private function onUnlockMission(param1:WorldEvent) : void
      {
         this.updateMissionUI();
      }
      
      protected function updateComment() : void
      {
         var _loc1_:String = this.getCommentText();
         if(_loc1_)
         {
            _loc1_ = "\"" + _loc1_ + "\"";
            m_pick.bubble.bubble_mc.visible = true;
            Tooltip.subscribe(m_pick.bubble,_loc1_);
            TextFieldUtil.processTextField(slideCard.title02_tf,_loc1_);
         }
         else
         {
            m_pick.bubble.bubble_mc.visible = false;
            Tooltip.unsubscribe(m_pick.bubble);
            TextFieldUtil.processTextField(slideCard.title02_tf," ");
         }
      }
      
      override protected function onPickClicked() : void
      {
      }
   }
}

