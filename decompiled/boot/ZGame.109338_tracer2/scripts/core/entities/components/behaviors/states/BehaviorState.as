package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.DecorationTargetComponent;
   import core.entities.components.UIControllerComponent;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.states.BasicState;
   import core.entities.components.states.IMachine;
   import core.entities.components.states.IState;
   import core.entities.components.utils.MultiHarvestHelper;
   import core.entities.components.utils.ServerTimeProgressionHelper;
   import core.entities.components.utils.YieldHelper;
   import core.gamemode.GameModeManager;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.ItemImage;
   import core.managers.CrewManager;
   import core.managers.PVPManager;
   import core.managers.SuperOreManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.visitorManager.VisitorManager;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import entity.GameDataComponent;
   import events.ProgressBarEvent;
   import events.UnitEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import rendering.rendering2d.ImageModifierComponent;
   import sound.SoundEvent;
   import sound.StateSound;
   import transactions.TNeighborSetState;
   import transactions.TSetState;
   import transactions.TVisitorHelpSpeedup;
   import utils.ZGameRandom;
   import utils.ZGameTime;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.core.ITickedObject;
   import zlabs.core.PBGroup;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class BehaviorState extends BasicState
   {
      
      private static const PROGRESSBAR_ALWAYS:String = "always";
      
      private static const PROGRESSBAR_ICON:String = "icon";
      
      private static const PROGRESSBAR_HOMECONTRACT:String = "homecontract";
      
      private static const SEEN_CHALLENGE_STADIUM:String = "challengeStadium";
      
      private static const SEEN_FIRST_MARKET:String = "1stmarket";
      
      public static const CURSOR_UPDATED_FROM_STATE_CHANGE:String = "bscursorupdated";
      
      protected var m_stateMachine:BehaviorStateMachine;
      
      protected var m_clickNextStateIndex:String;
      
      protected var m_autoNextStateIndex:String;
      
      protected var m_visitNextStateIndex:String;
      
      protected var m_imageName:String;
      
      protected var m_updateHelper:ITickedObject = null;
      
      private var m_yieldHelper:YieldHelper;
      
      protected var m_multiHarvestHelper:MultiHarvestHelper;
      
      protected var m_data:XML;
      
      protected var m_originalData:XML;
      
      protected var overlayDataProperty:PropertyReference = new PropertyReference("@Overlay.overlayData");
      
      protected var imageProperty:PropertyReference = new PropertyReference("@Image.itemImage");
      
      protected var animProperty:PropertyReference = new PropertyReference("@AnimationCanvas.animationData");
      
      protected var dataProperty:PropertyReference = new PropertyReference("@Data.gameData");
      
      protected var userDataProperty:PropertyReference = new PropertyReference("@Data.userData");
      
      protected var directionProperty:PropertyReference = new PropertyReference("@Data.direction");
      
      protected var m_durationSeconds:ZGameTime = null;
      
      protected var m_startTime:Number;
      
      private var m_displayProgressBar:Boolean;
      
      private var m_progressBarVisible:Boolean;
      
      private var m_checkedStateSounds:Boolean = false;
      
      private var m_stateSounds:StateSound = null;
      
      protected var m_alwaysDispatchProgress:Boolean = false;
      
      private var m_helpRequestState:Boolean = false;
      
      private var m_helpRedeemState:Boolean = false;
      
      private var m_multiHarvestState:Boolean = false;
      
      public function BehaviorState(param1:BehaviorStateInit)
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         super();
         this.m_originalData = param1.m_stateData.copy();
         this.m_data = param1.m_stateData.copy();
         this.m_yieldHelper = new YieldHelper();
         this.m_stateMachine = param1.m_machine as BehaviorStateMachine;
         if(this.m_data.@clickNext != undefined)
         {
            _loc2_ = this.m_data.@clickNext.toString();
            _loc3_ = _loc2_.split("|");
            if(_loc3_.length > 1)
            {
               this.m_clickNextStateIndex = ZGlobal.isVisiting() ? _loc3_[1] : _loc3_[0];
            }
            else
            {
               this.m_clickNextStateIndex = _loc2_;
            }
         }
         if(this.m_data.@autoNext != undefined)
         {
            _loc4_ = this.m_data.@autoNext.toString();
            _loc5_ = _loc4_.split("|");
            if(_loc5_.length > 1)
            {
               this.m_autoNextStateIndex = ZGlobal.isVisiting() ? _loc5_[1] : _loc5_[0];
            }
            else
            {
               this.m_autoNextStateIndex = _loc4_;
            }
         }
         if(this.m_data.@visitNextState != undefined)
         {
            _loc6_ = this.m_data.@visitNextState.toString();
            _loc7_ = _loc6_.split("|");
            if(_loc7_.length > 1)
            {
               this.m_visitNextStateIndex = ZGlobal.isVisiting() ? _loc7_[1] : _loc7_[0];
            }
            else
            {
               this.m_visitNextStateIndex = _loc6_;
            }
         }
         if(this.m_data.@imageType != undefined)
         {
            this.m_imageName = this.m_data.@imageType.toString();
         }
         this.m_durationSeconds = new ZGameTime(this.calculateDuration(this.m_data,NaN));
         if(param1.m_gameObject)
         {
            _loc8_ = ZGlobal.isVisiting() && param1.m_gameObject.visitorState != null ? int(param1.m_gameObject.visitorState) : int(param1.m_gameObject.state);
            if(this.m_data.@stateName == _loc8_)
            {
               this.m_startTime = ZGlobal.isVisiting() && param1.m_gameObject.visitorLastUpdated != null ? Number(param1.m_gameObject.visitorLastUpdated) : Number(param1.m_gameObject.lastUpdated);
            }
         }
      }
      
      public static function overrideStateDefaults(param1:XML, param2:Dictionary, param3:Dictionary, param4:Dictionary) : void
      {
         var _loc7_:XML = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         if(param1 == null)
         {
            return;
         }
         if(param3 == null && param4 == null && param2 == null)
         {
            return;
         }
         var _loc5_:XMLList = param1.attributes();
         var _loc6_:int = 0;
         for each(_loc7_ in _loc5_)
         {
            _loc8_ = String(_loc7_);
            if(_loc8_.charAt(0) == "$")
            {
               _loc9_ = _loc8_.split(":");
               if(_loc9_.length == 2)
               {
                  if(Boolean(param3) && Boolean(param3[_loc9_[0]]))
                  {
                     param1.attributes()[_loc6_] = param3[_loc9_[0]];
                  }
                  else if(Boolean(param4) && Boolean(param4[_loc9_[0]]))
                  {
                     param1.attributes()[_loc6_] = param4[_loc9_[0]];
                  }
                  else if(Boolean(param2) && Boolean(param2[_loc9_[0]]))
                  {
                     param1.attributes()[_loc6_] = param2[_loc9_[0]];
                  }
                  else
                  {
                     param1.attributes()[_loc6_] = _loc9_[1];
                  }
               }
            }
            _loc6_++;
         }
      }
      
      public function getClickNextStateIndex() : String
      {
         if(Boolean(this.m_visitNextStateIndex) && this.canVisitorHelp())
         {
            if(ZGlobal.isVisiting() || this.stateMachine.inVisitorHelpRedeemTransition)
            {
               return this.m_visitNextStateIndex;
            }
         }
         return this.defaultClickNextStateIndex;
      }
      
      protected function get defaultClickNextStateIndex() : String
      {
         return this.m_clickNextStateIndex;
      }
      
      public function getAutoNextStateIndex() : String
      {
         return this.m_autoNextStateIndex;
      }
      
      protected function removeListeners() : void
      {
         if(this.m_data.@cursor.length() > 0)
         {
            this.stateMachine.propertyBag.eventDispatcher.removeEventListener(UIControllerComponent.SET_TEMP_STATE_CURSOR,this.onSetUICursor);
         }
      }
      
      override public function stop() : void
      {
         this.removeListeners();
         if(this.m_multiHarvestHelper)
         {
            this.m_multiHarvestHelper.dispose();
            this.m_multiHarvestHelper = null;
         }
         if(this.m_updateHelper)
         {
            Zlab.processManager.removeTickedObject(this.m_updateHelper);
         }
         this.m_updateHelper = null;
         this.m_stateMachine = null;
         this.m_displayProgressBar = false;
      }
      
      override public function enter(param1:IMachine) : void
      {
         super.enter(param1);
         this.performEnterActions();
      }
      
      protected function initHelpStateFlags() : void
      {
         this.m_helpRequestState = this.stateMachine.inVisitorHelpRequestTransition;
         this.m_helpRedeemState = this.stateMachine.inVisitorHelpRedeemTransition;
         this.m_multiHarvestState = this.stateMachine.m_multiHarvestTransition;
      }
      
      protected function addListeners() : void
      {
         if(this.m_data.@cursor.length() > 0)
         {
            this.stateMachine.propertyBag.eventDispatcher.addEventListener(UIControllerComponent.SET_TEMP_STATE_CURSOR,this.onSetUICursor);
            GameModeManager.instance.dispatchEvent(new Event(CURSOR_UPDATED_FROM_STATE_CHANGE));
         }
      }
      
      protected function performEnterActions() : void
      {
         this.initHelpStateFlags();
         var _loc1_:DecorationTargetComponent = DecorationTargetComponent.getDecorationTargetComponent(this.owner);
         if(_loc1_)
         {
            _loc1_.registerStateEnter(this.decoEffect);
         }
         var _loc2_:String = null;
         var _loc3_:GameItem = this.stateMachine.propertyBag.getProperty(this.dataProperty,null) as GameItem;
         this.overrideAndUpdateOverlay(_loc3_);
         this.updateTooltip(_loc3_);
         this.m_yieldHelper.holdReserves();
         this.addListeners();
         if(this.m_data.@buildImage.length() > 0)
         {
            this.setImage(_loc3_,null);
         }
         else
         {
            if(Boolean(this.imageName) && this.imageName.length > 0)
            {
               _loc2_ = this.imageName;
            }
            this.setImage(_loc3_,_loc2_);
         }
         this.setupBounceOnClick(true);
         this.startProgressTimer();
         if(this.decoEffect == DecorationsManager.EFFECT_CONTRACT_DURATION)
         {
            if(_loc1_)
            {
               this.updateProgress(_loc1_.getContractDurationPercentage());
            }
         }
         else if(this.decoEffect == DecorationsManager.EFFECT_FARM_CAMP_DURATION)
         {
            if(_loc1_)
            {
               this.updateProgress(_loc1_.getFarmCampDurationPercentage());
            }
         }
         if(Boolean(_loc1_) && this.decoEffect == DecorationsManager.EFFECT_ARMY_RESEARCH_ACCELERATION)
         {
            this.updateProgress(_loc1_.getResearchAccelerationPercentage());
         }
         if(ZGlobal.loadingStage != ZGlobal.LOADING_STAGE_OBJECTS)
         {
            this.playSoundEvent(StateSound.ON_ENTER);
         }
         if(this.m_data.@multiharvestable.toString() == "true")
         {
            if(!this.m_multiHarvestHelper)
            {
               this.m_multiHarvestHelper = new MultiHarvestHelper(this.owner,this);
            }
            this.m_multiHarvestHelper.enable();
         }
      }
      
      private function getVisitTooltip() : String
      {
         if(this.isVisitHelpLimitReached())
         {
            return "";
         }
         var _loc1_:GameDataComponent = GameDataComponent.getGameDataComponent(this.owner);
         if(CrewManager.isCrewBuilding(this.owner,_loc1_))
         {
            if(!CrewManager.isPlayerInCrew(this.owner,ZGlobal.player.uid,_loc1_))
            {
               return "";
            }
         }
         return this.m_data.@visitTooltip;
      }
      
      protected function updateTooltip(param1:GameItem) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(this.m_data.@tooltip.length() > 0)
         {
            _loc2_ = new Object();
            _loc2_.tooltip = this.m_data.@tooltip;
            _loc2_.visitTooltip = ZGlobal.isVisiting() ? this.getVisitTooltip() : "";
            _loc2_.tooltipData = "";
            _loc2_.label = this.m_data.@label;
            _loc2_.tooltipType = this.m_data.@tooltipType;
            _loc3_ = param1.getStateMachineValuesAsString();
            if(_loc3_.length > 0)
            {
               _loc2_.tooltipData = _loc3_;
            }
            this.stateMachine.propertyBag.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_TOOLTIP_UPDATE,_loc2_));
         }
      }
      
      private function setupBounceOnClick(param1:Boolean) : void
      {
         var _loc2_:String = this.m_data.@bounceOnClick.toString();
         var _loc3_:Boolean = _loc2_.length > 0;
         if(_loc3_)
         {
            if(param1)
            {
               this.stateMachine.propertyBag.eventDispatcher.dispatchEvent(new WorldEvent(ImageModifierComponent.ACTIVATE,_loc2_));
            }
            else
            {
               this.stateMachine.propertyBag.eventDispatcher.dispatchEvent(new Event(ImageModifierComponent.DEACTIVATE));
            }
         }
      }
      
      public function isBuilt() : Boolean
      {
         var _loc1_:int = parseInt(this.name);
         var _loc2_:int = parseInt(this.stateMachine.builtState);
         return !(_loc1_ < _loc2_ || this.m_data.@buildingState != undefined && this.m_data.@buildingState.toString().length && this.m_data.@buildingState.toString() == "true");
      }
      
      private function checkForBuiltEvent(param1:String) : void
      {
         var _loc3_:GameItem = null;
         var _loc2_:BehaviorState = this.stateMachine.getState(this.stateMachine.currentStateName) as BehaviorState;
         if(!ZGlobal.isVisiting() && this.stateMachine.builtState == param1 && !_loc2_.isBuilt())
         {
            _loc3_ = this.stateMachine.propertyBag.getProperty(this.dataProperty,null) as GameItem;
            WorldObjectManager.instance.addObjectToBuiltDictionary(_loc3_.code);
            this.checkForFirstBuiltEvent(_loc3_);
         }
      }
      
      private function checkForFirstBuiltEvent(param1:GameItem) : void
      {
         var _loc2_:int = ZGlobal.gameSettings.getInt("newBuildingDialogDelay");
         if(param1 != null)
         {
            if(!ZGlobal.player.getSeenFlag(SEEN_FIRST_MARKET) && param1.code == "R00")
            {
               Zlab.processManager.schedule(_loc2_,this,this.onFirstMarketDialog,param1);
            }
            else if(param1.isResearchItem())
            {
               Zlab.processManager.schedule(_loc2_,this,this.onResearchBuildingDialog,param1);
            }
            else if(param1.isSupportFactory())
            {
               Zlab.processManager.schedule(_loc2_,this,this.onSupportBuildingDialog,param1);
            }
         }
      }
      
      private function onFirstMarketDialog(param1:GameItem) : void
      {
         PopupManager.instance.push(new FeedPopup(ZGameUtils.ZlocT("FeedPopups","market_built",{"user":ZLoc.tn("",ZGlobal.player.snUser.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC)}),ZGameUtils.ZlocT("FeedPopups","market_built_title"),ZGameUtils.ZlocT("FeedPopups","feed_share_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onFirstMarketDialogClosed,ZGlobal.gameSettings.getImageByName(param1.name,"icon")));
         ZGlobal.player.setSeenFlag(SEEN_FIRST_MARKET);
      }
      
      private function onResearchBuildingDialog(param1:GameItem) : void
      {
         var _loc2_:String = param1.referenceSubtype;
         var _loc3_:FeedPopup = new FeedPopup(ZGameUtils.ZlocT("FeedPopups","research_building"),ZGameUtils.ZlocT("FeedPopups","research_building_title"),ZGameUtils.ZlocT("FeedPopups","feed_share_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onResearchBuildingDialogClosed,ZGlobal.gameSettings.getImageByName(param1.name,"icon"),FeedPopup.LARGE_IMAGE,null,param1.isMegaBuilding() ? param1 : null);
         _loc3_.userData = param1.name + "|indefinite|singular";
         PopupManager.instance.push(_loc3_);
      }
      
      private function onSupportBuildingDialog(param1:GameItem) : void
      {
         var _loc2_:String = param1.referenceSubtype;
         var _loc3_:FeedPopup = new FeedPopup(ZGameUtils.ZlocT("FeedPopups","support_building"),ZGameUtils.ZlocT("FeedPopups","support_building_title"),ZGameUtils.ZlocT("FeedPopups","feed_share_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onSupportBuildingDialogClosed,ZGlobal.gameSettings.getImageByName(param1.name,"icon"));
         _loc3_.userData = {
            "name":param1.name + "|indefinite|singular",
            "code":param1.code
         };
         PopupManager.instance.push(_loc3_);
      }
      
      private function onFirstMarketDialogClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            ViralsManager.instance.sendFeed("market_built",{});
         }
      }
      
      private function onResearchBuildingDialogClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            ViralsManager.instance.sendFeed("research_building",{"ITEMTOKbuilding":param1.userData});
         }
      }
      
      private function onSupportBuildingDialogClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            ViralsManager.instance.sendFeed("support_building",{
               "ITEMTOKbuilding":param1.userData.name,
               "IMGCODE":param1.userData.code
            });
         }
      }
      
      protected function overrideAndUpdateOverlay(param1:GameItem) : void
      {
         this.overrideAndUpdate(param1);
         this.updateOverlay();
      }
      
      protected function updateOverlay() : void
      {
         var _loc3_:Object = null;
         var _loc4_:IState = null;
         var _loc1_:XML = null;
         var _loc2_:Object = this.shouldShowOverlay();
         if(_loc2_.show)
         {
            _loc1_ = _loc2_.data;
         }
         if(this.stateMachine.propertyBag.doesPropertyExist(this.overlayDataProperty))
         {
            _loc3_ = {"xml":_loc1_};
            if(ZGlobal.visitMode == ZGlobal.MODE_VISIT)
            {
               _loc4_ = this.getOverridenCheckState();
               if(null != _loc4_)
               {
                  _loc3_.checkData = BehaviorState(_loc4_).m_data;
               }
            }
            this.stateMachine.propertyBag.setProperty(this.overlayDataProperty,_loc3_);
         }
      }
      
      public function isVisitHelpLimitReached() : Boolean
      {
         var _loc1_:PropertyReference = null;
         var _loc2_:Boolean = false;
         if(PVPManager.instance.isNormalVisit())
         {
            _loc1_ = new PropertyReference("@VisitHostComponent.helpLimitReached");
            return this.stateMachine.propertyBag.getProperty(_loc1_,false) as Boolean;
         }
         return true;
      }
      
      protected function shouldShowOverlay() : Object
      {
         if(this.isVisitable())
         {
            return {
               "show":true,
               "data":this.m_data
            };
         }
         if(!ZGlobal.isVisiting())
         {
            return {
               "show":true,
               "data":this.m_data
            };
         }
         var _loc1_:Boolean = true;
         if(this.stateMachine.validCrewState)
         {
            _loc1_ = this.stateMachine.validCrewState == this.stateMachine.currentStateName;
         }
         return CrewManager.shouldShowVisitOverlay(this.owner,this,_loc1_);
      }
      
      protected function removeOverlay() : void
      {
         this.stateMachine.propertyBag.setProperty(this.overlayDataProperty,null);
      }
      
      public function set direction(param1:int) : void
      {
         this.stateMachine.propertyBag.setProperty(this.directionProperty,param1);
         var _loc2_:GameItem = this.stateMachine.propertyBag.getProperty(this.dataProperty,null) as GameItem;
         this.setImage(_loc2_,this.imageName);
      }
      
      protected function get imageName() : String
      {
         var _loc1_:GameItem = this.stateMachine.propertyBag.getProperty(this.dataProperty,null) as GameItem;
         if(_loc1_.isSuperOre())
         {
            if(this.isBuilt())
            {
               this.m_imageName = this.getSuperOreImage(this.m_imageName);
            }
         }
         return this.m_imageName;
      }
      
      private function getSuperOreImage(param1:String) : String
      {
         var _loc2_:Array = ["Active_BottomRight","Active_BottomLeft","Active_TopRight","Active_TopLeft"];
         var _loc3_:String = _loc2_[Math.max(SuperOreManager.instance.findLastUnlocked(),0)];
         if(param1.indexOf("_Anim") < 0)
         {
            return _loc3_;
         }
         return _loc3_ + "_Anim";
      }
      
      public function get data() : XML
      {
         return this.m_data;
      }
      
      protected function setImage(param1:GameItem, param2:String) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         if(param2 == null || param1.rotateable)
         {
            _loc4_ = this.stateMachine.propertyBag.getProperty(this.directionProperty,null) as int;
            if(param2 == null)
            {
               param2 = GameItem.DIRECTION_NAMES[_loc4_];
            }
            else
            {
               param2 += "_" + GameItem.DIRECTION_NAMES[_loc4_];
            }
         }
         var _loc3_:ItemImage = param1.getCachedImage(param2);
         if(_loc3_ == null)
         {
            param1 = ZGlobal.gameSettings.getItemByName(this.stateMachine.referenceItemName,GameItem) as GameItem;
            if(param1)
            {
               _loc3_ = param1.getCachedImage(param2);
            }
         }
         if(_loc3_ != null)
         {
            this.m_stateMachine.propertyBag.setProperty(this.imageProperty,_loc3_);
            _loc5_ = param1.getAnimations(param2);
            this.loadAnimations(_loc5_);
         }
      }
      
      protected function loadAnimations(param1:Array) : void
      {
         if(this.m_stateMachine.propertyBag.doesPropertyExist(this.animProperty))
         {
            this.m_stateMachine.propertyBag.setProperty(this.animProperty,param1);
         }
      }
      
      override public function exit(param1:IMachine) : void
      {
         super.exit(param1);
         this.performExitActions(param1);
      }
      
      protected function performExitActions(param1:IMachine) : void
      {
         var _loc2_:Object = null;
         this.m_yieldHelper.releaseReserves();
         if(this.m_multiHarvestHelper)
         {
            this.m_multiHarvestHelper.disable();
         }
         var _loc3_:DecorationTargetComponent = DecorationTargetComponent.getDecorationTargetComponent(this.owner);
         if(_loc3_)
         {
            _loc2_ = _loc3_.registerStateExit(this.decoEffect);
         }
         this.checkYieldChanges(_loc2_);
         this.setUpdateHelper(null);
         this.setupBounceOnClick(false);
         this.playSoundEvent(StateSound.ON_EXIT);
         this.dispatchActionCompleteEvent(param1);
         this.removeListeners();
         if(this.m_data.@cursor.length() > 0)
         {
            GameModeManager.instance.dispatchEvent(new Event(CURSOR_UPDATED_FROM_STATE_CHANGE));
         }
         this.m_helpRequestState = false;
         this.m_helpRedeemState = false;
         this.m_multiHarvestState = false;
      }
      
      public function dispatchActionCompleteEvent(param1:IMachine) : void
      {
         var _loc2_:String = this.m_data.@orders.toString();
         if(this.m_yieldHelper.usesEnergy(this.owner) || _loc2_.length > 0)
         {
            if(param1)
            {
               param1.propertyBag.eventDispatcher.dispatchEvent(new UnitEvent(UnitEvent.ACTION_COMPLETE,param1.propertyBag));
            }
         }
      }
      
      protected function startProgressTimer() : void
      {
         var _loc2_:GameItem = null;
         this.m_displayProgressBar = false;
         var _loc1_:Number = this.adjustedDuration;
         if(_loc1_ == 0)
         {
            this.autoNextState();
         }
         else if(!isNaN(_loc1_))
         {
            if(Boolean(this.stateMachine.referenceItemName) && !this.hasClientDuration(this.m_data))
            {
               _loc2_ = ZGlobal.gameSettings.getItemByName(this.stateMachine.referenceItemName,GameItem) as GameItem;
               this.m_durationSeconds = new ZGameTime(WorldUpgradeManager.instance.getModifiedDuration(WorldUpgradeManager.instance.getUpgradesByCode(_loc2_.code),_loc1_));
               _loc1_ = this.adjustedDuration;
            }
            this.setUpdateHelper(new ServerTimeProgressionHelper(this.m_startTime,_loc1_,this.onProgressComplete,this.onProgress));
            this.startProgressBar();
            this.m_startTime = 0;
         }
      }
      
      public function updateProgress(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(!isNaN(param1) && param1 != 0 && this.updateHelper != null)
         {
            _loc2_ = this.updateHelper.currentProgress + param1 / 100;
            this.updateHelper.setProgress(_loc2_);
         }
      }
      
      protected function onProgressComplete() : void
      {
         this.stopProgressBar();
         this.autoNextState();
      }
      
      private function progressBarHas(param1:String) : Boolean
      {
         var _loc2_:String = this.m_data.@progressBar.toString();
         if(_loc2_.indexOf(param1) >= 0)
         {
            return true;
         }
         return false;
      }
      
      protected function shouldShowProgressBar() : Boolean
      {
         if(this.m_data.@actionMessage == undefined)
         {
            return false;
         }
         if(ZGlobal.isVisiting() && !this.m_helpRequestState)
         {
            return false;
         }
         return true;
      }
      
      protected function startProgressBar() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc3_:UIControllerComponent = null;
         this.m_displayProgressBar = this.shouldShowProgressBar();
         if(this.m_displayProgressBar)
         {
            _loc1_ = false;
            _loc2_ = false;
            if(this.progressBarHas(PROGRESSBAR_ALWAYS))
            {
               _loc2_ = true;
               _loc1_ = true;
            }
            this.setProgressBarIcon();
            if(!_loc1_)
            {
               _loc3_ = UIControllerComponent(this.owner.lookupComponentByType(UIControllerComponent));
               if(Boolean(_loc3_) && _loc3_.highlighted)
               {
                  _loc1_ = true;
               }
            }
            if(_loc1_)
            {
               this.m_progressBarVisible = true;
               this.dispatchShowBarEvent();
            }
            if(!_loc2_)
            {
               this.stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
               this.stateMachine.propertyBag.eventDispatcher.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
            }
         }
      }
      
      private function setProgressBarIcon() : void
      {
         var _loc1_:ProgressBarEvent = new ProgressBarEvent(ProgressBarEvent.PROGRESS_BAR_ICON);
         _loc1_.message = null;
         if(this.progressBarHas(PROGRESSBAR_ICON))
         {
            _loc1_.message = this.stateMachine.referenceItemName;
         }
         this.stateMachine.propertyBag.eventDispatcher.dispatchEvent(_loc1_);
      }
      
      protected function stopProgressBar() : void
      {
         if(this.m_displayProgressBar || this.m_alwaysDispatchProgress)
         {
            this.m_progressBarVisible = false;
            this.stateMachine.propertyBag.eventDispatcher.dispatchEvent(new ProgressBarEvent(ProgressBarEvent.STOP_PROGRESS_BAR));
            this.stateMachine.propertyBag.eventDispatcher.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.stateMachine.propertyBag.eventDispatcher.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
      }
      
      public function cleanupProgressBar() : void
      {
         this.stopProgressBar();
      }
      
      protected function conditionallyUpdateProgressBar(param1:Number) : void
      {
         if(this.m_displayProgressBar && this.m_progressBarVisible || this.m_alwaysDispatchProgress)
         {
            this.updateProgressBar(param1);
         }
      }
      
      protected function addCustomProgressBarTextReplacements(param1:Object) : void
      {
      }
      
      protected function updateProgressBar(param1:Number) : void
      {
         var _loc3_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc2_:ProgressBarEvent = new ProgressBarEvent(ProgressBarEvent.UPDATE_PROGRESS);
         var _loc4_:String = "";
         if(this.progressBarHas(PROGRESSBAR_ALWAYS))
         {
            _loc4_ = Math.floor(param1 * 100).toString();
            _loc3_ = ZGameUtils.ZlocT("Main",this.m_data.@actionMessage.toString());
            _loc2_.isPercent = true;
         }
         else
         {
            _loc5_ = this.m_durationSeconds.absolute;
            _loc6_ = _loc5_ - param1 * _loc5_;
            _loc4_ = ZGameTimeUtil.instance.getClockString(_loc6_ + 1,false,false);
            _loc7_ = {"time":_loc4_};
            this.addCustomProgressBarTextReplacements(_loc7_);
            _loc3_ = ZGameUtils.ZlocT("Main",this.m_data.@actionMessage.toString(),_loc7_);
            _loc2_.isPercent = false;
         }
         _loc2_.message = _loc3_;
         _loc2_.progress = param1;
         _loc2_.timeRemaining = _loc4_;
         this.stateMachine.propertyBag.eventDispatcher.dispatchEvent(_loc2_);
      }
      
      protected function onProgress(param1:Number) : void
      {
         this.conditionallyUpdateProgressBar(param1);
      }
      
      public function onMouseOver(param1:MouseEvent) : void
      {
         if(this.m_displayProgressBar)
         {
            this.m_progressBarVisible = true;
            this.dispatchShowBarEvent();
         }
      }
      
      public function onMouseOut(param1:MouseEvent) : void
      {
         if(this.m_displayProgressBar)
         {
            this.m_progressBarVisible = false;
            this.stateMachine.propertyBag.eventDispatcher.dispatchEvent(new ProgressBarEvent(ProgressBarEvent.STOP_PROGRESS_BAR));
         }
      }
      
      public function onVisitHelpSuccess() : void
      {
         var _loc1_:GameItem = this.stateMachine.propertyBag.getProperty(this.dataProperty,null) as GameItem;
         this.updateTooltip(_loc1_);
         this.updateOverlay();
      }
      
      public function get yieldHelper() : YieldHelper
      {
         return this.m_yieldHelper;
      }
      
      protected function playSoundEvent(param1:int) : void
      {
         if(this.m_stateSounds)
         {
            this.m_stateSounds.playSoundEvent(param1);
         }
      }
      
      public function overrideAndUpdate(param1:GameItem) : void
      {
         var _loc3_:GameItem = null;
         var _loc4_:Dictionary = null;
         var _loc5_:Dictionary = null;
         var _loc2_:Dictionary = param1.getStateMachineValues(null);
         if(Boolean(this.stateMachine.referenceItemName) && this.stateMachine.referenceItemName.length > 0)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByName(this.stateMachine.referenceItemName,GameItem) as GameItem;
            _loc4_ = new Dictionary();
            _loc5_ = new Dictionary();
            if(_loc3_)
            {
               _loc4_ = _loc3_.getStateMachineValues(param1.name);
               _loc5_ = _loc3_.getReferenceImage();
            }
         }
         this.m_data = this.m_originalData.copy();
         overrideStateDefaults(this.m_data,_loc2_,_loc4_,_loc5_);
         this.updateOverrides(this.m_data);
      }
      
      protected function get stateMachine() : BehaviorStateMachine
      {
         return this.m_stateMachine;
      }
      
      protected function calculateDuration(param1:XML, param2:Number) : Number
      {
         var _loc3_:Number = NaN;
         if(this.hasClientDuration(param1))
         {
            _loc3_ = ZGameTimeUtil.instance.parseTimeAsSeconds(param1.@clientDuration,param2);
         }
         else
         {
            _loc3_ = ZGameTimeUtil.instance.parseTimeAsSeconds(param1.@duration,param2);
         }
         return _loc3_;
      }
      
      private function hasClientDuration(param1:XML) : Boolean
      {
         if(param1.@clientDuration == undefined)
         {
            return false;
         }
         return true;
      }
      
      protected function updateOverrides(param1:XML) : void
      {
         var _loc2_:String = param1.@duration.toString();
         var _loc3_:String = param1.@clientDuration.toString();
         if(Boolean(_loc2_) && Boolean(_loc2_.length > 0) || Boolean(_loc3_) && Boolean(_loc3_.length > 0))
         {
            this.m_durationSeconds = new ZGameTime(this.calculateDuration(param1,0));
         }
         this.m_yieldHelper.initFromData(param1);
         if(!this.m_checkedStateSounds)
         {
            this.m_stateSounds = StateSound.CreateStateSound(param1);
            this.m_checkedStateSounds = true;
         }
         if(this.stateMachine.resourceType)
         {
            this.m_yieldHelper.initResourceData(param1,this.stateMachine.resourceType);
         }
      }
      
      protected function get absoluteDuration() : Number
      {
         return this.m_durationSeconds.absolute;
      }
      
      protected function get adjustedDuration() : Number
      {
         return this.m_durationSeconds.adjusted;
      }
      
      protected function checkRequirements(param1:Boolean = true) : Boolean
      {
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc8_:FeedPopup = null;
         var _loc9_:Object = null;
         if(this.stateMachine.inVisitorHelpRedeemTransition || this.stateMachine.inMultiHarvestTransition)
         {
            return true;
         }
         var _loc2_:String = "";
         var _loc3_:int = this.m_yieldHelper.checkRequirements(this.owner);
         if(_loc3_ != YieldHelper.REQUIREMENT_SUCCESS)
         {
            _loc2_ += this.m_yieldHelper.getLackingRequirementsText(this.owner);
         }
         var _loc4_:IState = this.getOverridenCheckState();
         if(_loc4_)
         {
            _loc3_ |= BehaviorState(_loc4_).yieldHelper.checkRequirements(this.owner);
            if(_loc3_ != YieldHelper.REQUIREMENT_SUCCESS)
            {
               if(_loc2_.length > 0)
               {
                  _loc2_ += ", ";
               }
               _loc2_ += BehaviorState(_loc4_).yieldHelper.getLackingRequirementsText(this.owner);
            }
         }
         if(_loc3_ != YieldHelper.REQUIREMENT_SUCCESS)
         {
            this.stateMachine.propertyBag.eventDispatcher.dispatchEvent(new UnitEvent(UnitEvent.ACTION_FAILED));
            if(param1)
            {
               if((_loc3_ & YieldHelper.REQUIREMENT_ENERGY) != 0)
               {
                  BuyEnergyPopup.enableWatchToEarn();
                  BuyEnergyPopup.show();
               }
               else
               {
                  _loc5_ = this.m_yieldHelper.getLackingRequirementsTypes(this.owner);
                  _loc6_ = _loc5_.split(",");
                  _loc7_ = ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items",this.name + "_sentenceName","plural"));
                  _loc8_ = new FeedPopup(ZGameUtils.ZlocT("FeedPopups","out_of_resource",{"resource":ZGameUtils.ZlocTk("Items",_loc6_[0] + "_sentenceName","plural")}),ZGameUtils.ZlocT("FeedPopups","out_of_resource_title",{"resource":ZGameUtils.ZlocTk("Items",_loc6_[0] + "_sentenceName","plural")}),ZGameUtils.ZlocT("FeedPopups","feed_send_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onOutOfResourceDialogClosed,WorldResourceManager.instance.getResourceImageURLByType(_loc6_[0],WorldResourceManager.XTRA_LARGE_ICON));
                  _loc9_ = new Object();
                  _loc9_.name = _loc6_[0];
                  _loc9_.localized = _loc7_;
                  _loc8_.userData = _loc9_;
                  PopupManager.instance.push(_loc8_);
               }
            }
            return false;
         }
         return true;
      }
      
      private function onOutOfResourceDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = "out_of_" + param1.userData.name;
            ViralsManager.instance.sendFeed(_loc2_,{"resource":param1.userData.localized});
         }
      }
      
      protected function getOverridenCheckState() : IState
      {
         var _loc2_:IState = null;
         var _loc3_:GameItem = null;
         var _loc1_:String = this.m_data.@checkState.toString();
         if(Boolean(_loc1_) && _loc1_.length > 0)
         {
            _loc2_ = this.m_stateMachine.getState(_loc1_);
            _loc3_ = this.stateMachine.propertyBag.getProperty(this.dataProperty,null) as GameItem;
            BehaviorState(_loc2_).overrideAndUpdate(_loc3_);
            return _loc2_;
         }
         return null;
      }
      
      protected function autoNextState() : void
      {
         if(this.m_autoNextStateIndex)
         {
            this.switchToState(this.m_autoNextStateIndex);
         }
         else
         {
            Logger.error(this,"autoNextState","trying to enter autoNextState when it isn\'t set");
         }
      }
      
      public function clickNextStateClientUpdateOnly() : void
      {
         if(this.getClickNextStateIndex())
         {
            this.switchToState(this.getClickNextStateIndex());
         }
         else
         {
            Logger.error(this,"clickNextStateClientUpdateOnly","trying to enter clickState when it isn\'t set");
         }
      }
      
      public function clickNextState() : void
      {
         var _loc1_:IState = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:TSetState = null;
         if(this.getClickNextStateIndex())
         {
            if(this.shouldSendSetStateTransaction())
            {
               _loc1_ = this.getOverridenCheckState();
               if(_loc1_)
               {
                  if(BehaviorState(_loc1_).yieldHelper.xpYield)
                  {
                     _loc2_ = ZGameRandom.rewardInstance.float();
                     BehaviorState(_loc1_).yieldHelper.saveXPBuffRandom(_loc2_);
                  }
                  if(BehaviorState(_loc1_).m_data.@dooberType != undefined)
                  {
                     _loc3_ = ZGameRandom.rewardInstance.float();
                     BehaviorState(_loc1_).yieldHelper.saveRandomFloat(_loc3_);
                  }
               }
            }
            this.switchToState(this.getClickNextStateIndex());
            if(this.shouldSendSetStateTransaction())
            {
               if(ZGlobal.isHome())
               {
                  _loc4_ = new TSetState(this.owner,this.getSetStateReferenceItemName());
                  _loc4_.stateMachine = this.stateMachine;
                  TransactionManager.addTransaction(_loc4_);
               }
               else
               {
                  TransactionManager.addTransaction(new TNeighborSetState(this.owner,ZGlobal.hostPlayer.uid,this.getSetStateReferenceItemName()));
               }
            }
         }
         else
         {
            Logger.error(this,"clickNextStateClientUpdateOnly","trying to enter clickState when it isn\'t set");
         }
      }
      
      protected function shouldSendSetStateTransaction() : Boolean
      {
         if(ZGlobal.isVisiting())
         {
            return false;
         }
         var _loc1_:GameItem = this.stateMachine.propertyBag.getProperty(this.dataProperty,null) as GameItem;
         if(_loc1_.name == "avatar" || _loc1_.name == "visitorAvatar")
         {
            return false;
         }
         if(this.stateMachine.inVisitorHelpRequestTransition || this.stateMachine.inVisitorHelpRedeemTransition)
         {
            return false;
         }
         return true;
      }
      
      protected function switchToState(param1:String) : void
      {
         this.checkForBuiltEvent(param1);
         this.stateMachine.setCurrentState(param1);
         WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_STATE_COMPLETE,{
            "entity":this.stateMachine.propertyBag,
            "state":this.m_data.@stateName.toString()
         }));
      }
      
      protected function getSetStateReferenceItemName() : String
      {
         return null;
      }
      
      protected function setUpdateHelper(param1:ITickedObject) : void
      {
         if(this.m_updateHelper)
         {
            Zlab.processManager.removeTickedObject(this.m_updateHelper);
         }
         this.m_updateHelper = param1;
         if(this.m_updateHelper)
         {
            Zlab.processManager.addTickedObject(this.m_updateHelper);
         }
      }
      
      override public function load(param1:IMachine, param2:IState) : void
      {
         super.load(param1,param2);
         WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_STATE_COMPLETE,{
            "entity":param1.propertyBag,
            "state":this.m_data.@stateName.toString()
         }));
      }
      
      private function checkYieldChanges(param1:Object) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:GameItem = null;
         var _loc4_:String = null;
         var _loc5_:XML = null;
         var _loc6_:YieldHelper = null;
         var _loc7_:Fleet = null;
         var _loc8_:PBGroup = null;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         if(ZGlobal.isVisiting())
         {
            if(!this.stateMachine.inRemoteStateChange)
            {
               _loc3_ = this.stateMachine.propertyBag.getProperty(this.dataProperty,null) as GameItem;
               _loc4_ = VisitorManager.getVisitorRewardLabel(this.stateMachine.propertyBag as IEntity,_loc3_,this.visitorRewardType,false);
               _loc5_ = VisitorManager.getRewardXML(_loc4_);
               if(_loc5_)
               {
                  _loc6_ = new YieldHelper();
                  _loc6_.initFromData(_loc5_);
                  _loc2_ = ZGameRandom.rewardInstance.float();
                  _loc6_.saveRandomFloat(_loc2_);
                  _loc6_.execute(this.stateMachine,_loc5_);
               }
            }
         }
         else
         {
            _loc8_ = IEntity(this.stateMachine.propertyBag).owningGroup;
            if((Boolean(_loc8_)) && Boolean(_loc8_.name))
            {
               _loc7_ = ZGlobal.hostPlayer.fleets.getFleetByName(_loc8_.name);
            }
            _loc9_ = false;
            if(Boolean(_loc7_) && Boolean(_loc7_.uid) && _loc7_.uid != ZGlobal.player.uid)
            {
               _loc9_ = true;
            }
            if(!_loc9_)
            {
               _loc10_ = this.m_helpRedeemState || this.m_multiHarvestState;
               if(this.m_helpRedeemState)
               {
                  if(this.m_data.@dooberType != undefined)
                  {
                     _loc2_ = ZGameRandom.rewardInstance.float();
                     this.m_yieldHelper.saveRandomFloat(_loc2_);
                  }
               }
               this.m_yieldHelper.execute(this.stateMachine,this.m_data,false,_loc10_,null,param1);
               if(this.visitorRewardType == VisitorManager.VISITOR_HELP_CREW_TAX)
               {
                  _loc11_ = param1 ? int(param1.amount) : 0;
                  CrewManager.doOwnerTendReward(this.owner,_loc11_);
               }
            }
         }
      }
      
      private function performSpeedup() : void
      {
         var _loc1_:Number = ZGlobal.gameSettings.getNumber("friendVisitSpeedupAmountPercent",0.15);
         var _loc2_:Number = this.updateHelper.currentProgress + _loc1_;
         this.updateHelper.setProgress(_loc2_);
      }
      
      public function performRebuildSpeedup() : void
      {
         var _loc1_:Number = 1000 * 60 * 60 * 24 / this.updateHelper.actionDuration;
         var _loc2_:Number = this.updateHelper.currentProgress + _loc1_;
         this.updateHelper.setProgress(_loc2_);
      }
      
      public function isVisitable() : Boolean
      {
         return this.m_data.@visitable == "1";
      }
      
      public function canVisitorHelp() : Boolean
      {
         return this.m_data.@visitorHelpType != undefined && VisitorManager.isValidHelpType(this.m_data.@visitorHelpType);
      }
      
      public function canRedeemHelp() : Boolean
      {
         return this.canVisitorHelp();
      }
      
      public function get visitorCursor() : Object
      {
         return VisitorManager.getCursor(this.owner,this.m_data.@visitorHelpType);
      }
      
      public function get visitorHelpType() : String
      {
         return this.m_data.@visitorHelpType.toString();
      }
      
      public function get visitorRewardType() : String
      {
         return this.m_data.@visitorRewardType.toString();
      }
      
      public function isVisitOnly() : Boolean
      {
         return this.m_data.@visitOnly == "1";
      }
      
      public function canBeSelected() : Boolean
      {
         return true;
      }
      
      public function actionSuffersPVPPenalty() : Boolean
      {
         var _loc1_:IState = null;
         if(!this.m_helpRedeemState)
         {
            if(this.yieldHelper.executionSubjectToPVPPenalty(this.owner))
            {
               return true;
            }
            _loc1_ = this.getOverridenCheckState();
            if(_loc1_)
            {
               return BehaviorState(_loc1_).yieldHelper.executionSubjectToPVPPenalty(this.owner);
            }
         }
         return false;
      }
      
      private function isPVPInfluenced(param1:IEntity) : Boolean
      {
         if(param1)
         {
            if(param1.doesPropertyExist(new PropertyReference("@pillageable.underPVPInfluence")))
            {
               return param1.getProperty(new PropertyReference("@pillageable.underPVPInfluence"));
            }
         }
         return false;
      }
      
      public function actionSuffersPVPPenaltyNeighborhood() : Boolean
      {
         if(this.isPVPInfluenced(this.owner))
         {
            return true;
         }
         var _loc1_:IState = this.getOverridenCheckState();
         if(_loc1_)
         {
            return BehaviorState(_loc1_).isPVPInfluenced(this.owner);
         }
         return false;
      }
      
      public function getEnergyDeductionInfo() : Object
      {
         var _loc1_:Object = this.yieldHelper.getEnergyRequirement(this.owner);
         if(Boolean(_loc1_) && _loc1_.energy < 0)
         {
            return _loc1_;
         }
         var _loc2_:IState = this.getOverridenCheckState();
         if(_loc2_)
         {
            _loc1_ = BehaviorState(_loc2_).yieldHelper.getEnergyRequirement(this.owner);
            if(Boolean(_loc1_) && _loc1_.energy < 0)
            {
               return _loc1_;
            }
         }
         return true;
      }
      
      public function needsAvatar() : Boolean
      {
         var _loc1_:IState = this.getOverridenCheckState();
         if(_loc1_)
         {
            if(BehaviorState(_loc1_).yieldHelper.usesEnergy(this.owner))
            {
               return true;
            }
         }
         return false;
      }
      
      public function sell() : void
      {
         this.setUpdateHelper(null);
      }
      
      public function get updateHelper() : ServerTimeProgressionHelper
      {
         return this.m_updateHelper as ServerTimeProgressionHelper;
      }
      
      public function get isHarvestingState() : Boolean
      {
         return this.m_data.@harvestingState == "1";
      }
      
      public function get isGrowingState() : Boolean
      {
         return this.m_data.@growingState == "1";
      }
      
      public function get name() : String
      {
         return this.m_data.@stateName;
      }
      
      public function onVisitorHelped() : void
      {
      }
      
      public function multiHarvest() : void
      {
         this.stateMachine.m_multiHarvestTransition = true;
         this.onMultiHarvested();
         this.stateMachine.m_multiHarvestTransition = false;
      }
      
      public function onMultiHarvested() : void
      {
      }
      
      public function onVisitorHelpRedeemed(param1:IEntity, param2:String) : void
      {
         var _loc3_:TVisitorHelpSpeedup = null;
         if(this.visitorHelpType == VisitorManager.VISITOR_HELP_SPEEDUP)
         {
            if(this.updateHelper)
            {
               this.performSpeedup();
               SoundEvent.getSoundEvent("StartResearch").play();
               _loc3_ = new TVisitorHelpSpeedup(param1,param2,this.updateHelper.elapsedTime);
               TransactionManager.addTransaction(_loc3_,true);
            }
            else
            {
               Logger.print(this,"Error, trying to speed up a state that isn\'t timed");
            }
         }
      }
      
      private function onSetUICursor(param1:WorldEvent) : void
      {
         UIControllerComponent(param1.eventData).stateCursor = this.m_data.@cursor;
      }
      
      protected function get owner() : IEntity
      {
         return this.stateMachine.propertyBag as IEntity;
      }
      
      private function dispatchShowBarEvent() : void
      {
         var _loc1_:ProgressBarEvent = new ProgressBarEvent(ProgressBarEvent.START_PROGRESS_BAR);
         _loc1_.barType = this.getProgressBarType();
         this.stateMachine.propertyBag.eventDispatcher.dispatchEvent(_loc1_);
      }
      
      private function getProgressBarType() : int
      {
         if(ZGlobal.isHome())
         {
            if(ZGlobal.enhancedProgressBarVariant > 0 && this.progressBarHas(PROGRESSBAR_HOMECONTRACT))
            {
               return ProgressBarEvent.TYPE_HOMECONTRACT;
            }
         }
         return ProgressBarEvent.TYPE_PLAIN;
      }
      
      private function get decoEffect() : String
      {
         if(this.m_data.@decoEffect == undefined)
         {
            return null;
         }
         return this.m_data.@decoEffect.toString();
      }
      
      public function hasResourceUnlock() : Boolean
      {
         if(this.m_data.@unlockResource != undefined && this.m_data.@unlockResource == "true")
         {
            SuperOreManager.instance.unlockResource();
            return true;
         }
         return false;
      }
      
      public function switchToUpgradeState() : void
      {
         var _loc1_:String = this.stateMachine.upgradeState;
         if(_loc1_)
         {
            this.switchToState(this.stateMachine.upgradeState);
         }
      }
      
      public function switchToCrewState(param1:String) : void
      {
         if(Boolean(param1) && param1 == this.stateMachine.crewState)
         {
            this.switchToState(param1);
         }
      }
      
      public function isCrewState() : Boolean
      {
         var _loc1_:int = parseInt(this.name);
         var _loc2_:int = parseInt(this.stateMachine.crewState);
         return _loc1_ == _loc2_;
      }
   }
}

