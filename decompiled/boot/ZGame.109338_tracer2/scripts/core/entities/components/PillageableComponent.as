package core.entities.components
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.DormantState;
   import core.entities.components.utils.YieldHelper;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import core.managers.WorldResourceManager;
   import core.ui.feedbacktext.ExperienceFeedbackText;
   import core.ui.feedbacktext.QuantifiedFeedbackText;
   import core.ui.feedbacktext.ResourceFeedbackText;
   import entity.EntityInit;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.text.TextField;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   import utils.TileUtil;
   import utils.ZGameUtils;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   import zlabs.utils.MathUtils;
   
   public class PillageableComponent extends EntityComponent
   {
      
      private static var m_gameItemPropRef:PropertyReference = new PropertyReference("@Data.gameData");
      
      private static var m_stateMachinePropRef:PropertyReference = new PropertyReference("@StateMachine.stateMachine");
      
      public static const ADJUST_FEEDBACK_TEXT:String = "adjustPillageFeedbackText";
      
      private var m_markers:Array = new Array();
      
      private var m_rewardTextFields:Array = new Array();
      
      private var m_sprite:Sprite = new Sprite();
      
      private var m_container:Sprite = new Sprite();
      
      private var m_gameItem:GameItem;
      
      public function PillageableComponent(param1:EntityInit)
      {
         super();
         this.m_gameItem = param1.m_item as GameItem;
         this.m_container.mouseEnabled = false;
         this.m_container.mouseChildren = false;
      }
      
      public function get underPVPInfluence() : Boolean
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this.m_markers)
         {
            if(!_loc1_.forPlacement)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get sprite() : Sprite
      {
         return this.m_sprite;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(PVPManager.MARKER_ACTIVATED,this.onMarkerActivated,false,0,true);
         owner.eventDispatcher.addEventListener(PVPManager.PILLAGE_PERFORMED,this.onPillagePerformed,false,0,true);
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.STOP,this.refresh,false,0,true);
         owner.eventDispatcher.addEventListener(PVPManager.BUILD_FINISHED,this.refresh,false,0,true);
         owner.eventDispatcher.addEventListener(DormantState.SLEEP,this.onSleep,false,0,true);
         owner.eventDispatcher.addEventListener(ADJUST_FEEDBACK_TEXT,this.onAdjustFeedbackText,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(PVPManager.MARKER_ACTIVATED,this.onMarkerActivated);
         owner.eventDispatcher.removeEventListener(PVPManager.PILLAGE_PERFORMED,this.onPillagePerformed);
         owner.eventDispatcher.removeEventListener(IsoSpatialComponent.STOP,this.refresh);
         owner.eventDispatcher.removeEventListener(PVPManager.BUILD_FINISHED,this.refresh);
         PVPManager.instance.removeEventListener(PVPManager.MARKER_DEACTIVATED,this.onMarkerDeactivated);
         owner.eventDispatcher.removeEventListener(DormantState.SLEEP,this.onSleep);
         owner.eventDispatcher.removeEventListener(ADJUST_FEEDBACK_TEXT,this.onAdjustFeedbackText);
         this.cleanupTextFields();
      }
      
      private function cleanupTextFields() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this.m_rewardTextFields)
         {
            _loc1_.tf.parent.removeChild(_loc1_.tf);
            _loc1_.tf = null;
            _loc1_.mc = null;
         }
         this.m_rewardTextFields = new Array();
      }
      
      private function refresh(param1:Event) : void
      {
         this.refreshMarkerEffect();
      }
      
      private function onPillagePerformed(param1:WorldEvent) : void
      {
         var _loc5_:String = null;
         var _loc6_:XML = null;
         var _loc7_:YieldHelper = null;
         var _loc2_:Number = 1;
         if(Boolean(param1.eventData) && Boolean(param1.eventData.rewardMultiplier))
         {
            _loc2_ = Number(param1.eventData.rewardMultiplier);
         }
         var _loc3_:GameItem = owner.getProperty(m_gameItemPropRef);
         var _loc4_:BehaviorStateMachine = owner.getProperty(m_stateMachinePropRef) as BehaviorStateMachine;
         if(_loc3_)
         {
            _loc5_ = _loc3_.pillageType;
            if(_loc5_)
            {
               _loc6_ = PVPManager.instance.isVisitGlobalPVP() ? ZGlobal.gameSettings.getPillageRewardGlobalPVPXML(this.m_gameItem.pillageType) : ZGlobal.gameSettings.getPillageRewardXML(this.m_gameItem.pillageType);
               if(_loc6_)
               {
                  SoundEvent.getSoundEvent("PillageSuccess").play();
                  _loc7_ = new YieldHelper();
                  _loc7_.initFromData(_loc6_,_loc2_);
                  _loc7_.execute(_loc4_,_loc6_,false,false,owner);
               }
            }
         }
      }
      
      private function indexOfMarker(param1:String) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_markers.length)
         {
            if(this.m_markers[_loc2_].uid == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function onMarkerActivated(param1:WorldEvent) : void
      {
         var _loc5_:IsoSpatialComponent = null;
         var _loc6_:Point = null;
         PVPManager.instance.addEventListener(PVPManager.MARKER_DEACTIVATED,this.onMarkerDeactivated,false,0,true);
         var _loc2_:String = param1.eventData.uid;
         var _loc3_:Boolean = Boolean(param1.eventData.forPlacement);
         var _loc4_:int = this.indexOfMarker(_loc2_);
         if(_loc4_ < 0)
         {
            this.m_markers.push({
               "uid":param1.eventData.uid,
               "forPlacement":_loc3_
            });
            if(PVPManager.instance.isAttackVisit())
            {
               _loc5_ = IsoSpatialComponent(owner.lookupComponentByType(IsoSpatialComponent));
               _loc6_ = MathUtils.convertVectorToPoint(TileUtil.worldToTile(_loc5_.position));
               PVPManager.instance.dispatchUnitEvent(_loc6_,this.m_gameItem.sizeX,this.m_gameItem.sizeY,ProtectorComponent.PROTECTOR_ACTIVATED);
            }
         }
         else
         {
            this.m_markers[_loc4_].forPlacement = _loc3_;
         }
         this.updateFeedback();
      }
      
      private function onMarkerDeactivated(param1:WorldEvent) : void
      {
         var _loc2_:int = this.indexOfMarker(param1.eventData.uid);
         if(_loc2_ >= 0)
         {
            this.m_markers.splice(_loc2_,1);
            this.updateFeedback();
            if(!this.m_markers.length)
            {
               PVPManager.instance.removeEventListener(PVPManager.MARKER_DEACTIVATED,this.onMarkerDeactivated);
            }
         }
      }
      
      private function updateFeedback() : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:AreaImmuneComponent = null;
         var _loc1_:Boolean = false;
         for each(_loc2_ in this.m_markers)
         {
            if(_loc2_.forPlacement)
            {
               _loc1_ = true;
            }
         }
         _loc3_ = UIControllerComponent.EVENT_FILTER_EFFECT;
         if(this.m_markers.length)
         {
            if(_loc1_)
            {
               _loc4_ = owner.lookupComponentByType(AreaImmuneComponent) as AreaImmuneComponent;
               if((Boolean(_loc4_)) && _loc4_.isAreaImmune())
               {
                  owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc3_,UIControllerComponent.FILTER_EFFECT_AREA_IMMUNE_PILLAGE_PLACEMENT_ON));
               }
               else
               {
                  owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc3_,UIControllerComponent.FILTER_EFFECT_PILLAGE_PLACEMENT_ON));
               }
               owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc3_,UIControllerComponent.FILTER_EFFECT_PILLAGEABLE_OFF));
               this.removePillageFeedback();
               this.addPillageFeedback();
            }
            else
            {
               owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc3_,UIControllerComponent.FILTER_EFFECT_PILLAGEABLE_ON));
               owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc3_,UIControllerComponent.FILTER_EFFECT_PILLAGE_PLACEMENT_OFF));
               owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc3_,UIControllerComponent.FILTER_EFFECT_AREA_IMMUNE_PILLAGE_PLACEMENT_OFF));
               this.removePillageFeedback();
            }
         }
         else
         {
            this.removePillageFeedback();
            owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc3_,UIControllerComponent.FILTER_EFFECT_PILLAGEABLE_OFF));
            owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc3_,UIControllerComponent.FILTER_EFFECT_PILLAGE_PLACEMENT_OFF));
            owner.eventDispatcher.dispatchEvent(new WorldEvent(_loc3_,UIControllerComponent.FILTER_EFFECT_AREA_IMMUNE_PILLAGE_PLACEMENT_OFF));
         }
      }
      
      private function refreshMarkerEffect() : void
      {
         var _loc2_:String = null;
         this.m_markers = new Array();
         var _loc1_:Array = PVPManager.instance.getAffectingMarkers(owner);
         for each(_loc2_ in _loc1_)
         {
            this.m_markers.push({
               "uid":_loc2_,
               "forPlacement":false
            });
         }
         if(this.m_markers.length)
         {
            PVPManager.instance.addEventListener(PVPManager.MARKER_DEACTIVATED,this.onMarkerDeactivated,false,0,true);
         }
         this.updateFeedback();
      }
      
      private function addPillageFeedback() : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc1_:XML = PVPManager.instance.isVisitGlobalPVP() ? ZGlobal.gameSettings.getPillageRewardGlobalPVPXML(this.m_gameItem.pillageType) : ZGlobal.gameSettings.getPillageRewardXML(this.m_gameItem.pillageType);
         if(_loc1_)
         {
            for each(_loc2_ in _loc1_.attributes())
            {
               _loc3_ = _loc2_.name().toString();
               _loc4_ = parseInt(_loc2_);
               switch(_loc3_)
               {
                  case "name":
                     break;
                  case "xp":
                     this.addRewardTypeString(new ExperienceFeedbackText(_loc4_));
                     break;
                  case "socialXpGood":
                     break;
                  case "socialXpBad":
                     break;
                  default:
                     _loc5_ = WorldResourceManager.instance.resourceFromRareResource(_loc3_,ZGlobal.hostPlayer.rareResourceType);
                     if(WorldResourceManager.instance.getResourceInfoByType(_loc5_))
                     {
                        this.addRewardTypeString(new ResourceFeedbackText(_loc5_,_loc4_));
                     }
               }
            }
         }
         this.m_sprite.parent.parent.addChild(this.m_container);
      }
      
      private function addRewardTypeString(param1:QuantifiedFeedbackText) : void
      {
         var _loc2_:MovieClip = null;
         _loc2_ = new LootText();
         var _loc3_:TextField = _loc2_.text_tf;
         var _loc4_:String = ZGameUtils.ZlocT("Main","PositiveFeedback",{"feedback":param1.friendlyName});
         TextFieldUtil.processSingleLineTextField(_loc3_,_loc4_,15);
         _loc3_.textColor = param1.color;
         _loc3_.scaleX = _loc3_.scaleY = 1.5;
         var _loc5_:int = this.m_rewardTextFields.length * _loc3_.height;
         _loc3_.y = -(_loc5_ + 50);
         _loc3_.x -= _loc3_.width * 0.5;
         _loc3_.x += this.m_sprite.parent.x + this.m_sprite.x;
         _loc3_.y += this.m_sprite.parent.y + this.m_sprite.y;
         this.m_container.addChild(_loc3_);
         this.m_rewardTextFields.push({
            "tf":_loc3_,
            "mc":_loc2_
         });
      }
      
      private function removePillageFeedback() : void
      {
         this.cleanupTextFields();
      }
      
      private function onSleep(param1:Event) : void
      {
         this.m_markers = new Array();
         this.removePillageFeedback();
         owner.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_FILTER_EFFECT,UIControllerComponent.FILTER_EFFECT_PILLAGEABLE_OFF));
         owner.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_FILTER_EFFECT,UIControllerComponent.FILTER_EFFECT_PILLAGE_PLACEMENT_OFF));
      }
      
      public function onAdjustFeedbackText(param1:Event) : void
      {
         var _loc4_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:AreaImmuneComponent = owner.lookupComponentByType(AreaImmuneComponent) as AreaImmuneComponent;
         if(_loc3_)
         {
            _loc2_ = _loc3_.getFeedbackTextHeight() / 2;
            if(_loc2_ != 0)
            {
               _loc3_.shiftText(0,_loc2_);
               for each(_loc4_ in this.m_rewardTextFields)
               {
                  _loc4_.tf.y -= _loc2_;
               }
            }
         }
      }
   }
}

