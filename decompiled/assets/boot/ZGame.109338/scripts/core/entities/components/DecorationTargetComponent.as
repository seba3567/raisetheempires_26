package core.entities.components
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gamemode.GMObjectMove;
   import core.gamemode.GameModeManager;
   import core.gameobjects.DecorationItem;
   import core.managers.BuildManager;
   import core.managers.CrewManager;
   import core.managers.FarmCampManager;
   import core.managers.decorationsManager.DecorationsManager;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class DecorationTargetComponent extends GameEntityComponent
   {
      
      private static var ID_NONE:int = -1;
      
      private static var TOOLTIP_SWF_PATH:String = "assets/ui/DeccoTooltip.swf";
      
      private var m_decoTargets:Array;
      
      private var m_decoEffects:Array;
      
      private var m_sources:Array = new Array();
      
      private var m_sprite:Sprite = new Sprite();
      
      private var m_container:Sprite = new Sprite();
      
      private var m_deferredPayouts:Dictionary = new Dictionary();
      
      private var m_beingMoved:Boolean;
      
      private var m_tooltipClass:Class;
      
      private var m_tooltipMC:MovieClip;
      
      private var m_contractDurationUpdated:Boolean = false;
      
      private var m_contractDurationEffect:Number = 0;
      
      private var m_farmCampDurationEffect:Number = 0;
      
      private var m_researchAccelerationEffect:Number = 0;
      
      public function DecorationTargetComponent(param1:Array)
      {
         super();
         this.m_decoTargets = param1;
         this.m_container.mouseEnabled = false;
         this.m_container.mouseChildren = false;
         var _loc2_:String = ZGlobal.getAssetURL(TOOLTIP_SWF_PATH);
         Zlab.resourceManager.load(_loc2_,SWFResource,this.onLoadComplete);
      }
      
      public static function getDecorationTargetComponent(param1:IEntity) : DecorationTargetComponent
      {
         return param1.lookupComponentByType(DecorationTargetComponent) as DecorationTargetComponent;
      }
      
      public static function getDiscountForObject(param1:IEntity) : Dictionary
      {
         var _loc2_:DecorationTargetComponent = getDecorationTargetComponent(param1);
         if(_loc2_)
         {
            return _loc2_.getDiscount();
         }
         return null;
      }
      
      public static function getDecoEffectsForTarget(param1:IEntity) : Array
      {
         var _loc4_:Object = null;
         var _loc5_:XML = null;
         var _loc2_:DecorationTargetComponent = getDecorationTargetComponent(param1);
         var _loc3_:Array = new Array();
         if(_loc2_ != null)
         {
            for each(_loc4_ in _loc2_.m_sources)
            {
               for each(_loc5_ in _loc4_.effectsData)
               {
                  _loc3_.push(_loc5_.@effect.toString());
               }
            }
         }
         return _loc3_;
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         this.m_tooltipClass = param1.getAssetClass("bonusTooltip_mc");
      }
      
      override protected function onAdd() : void
      {
         this.m_decoEffects = DecorationsManager.instance.getEffectsForGameItem(gameItem);
         owner.eventDispatcher.addEventListener(DecorationsManager.SOURCE_PLACED,this.onSourcePlaced,false,0,true);
         owner.eventDispatcher.addEventListener(DecorationsManager.SOURCE_REMOVED,this.onSourceRemoved,false,0,true);
         super.onAdd();
      }
      
      override protected function onRemove() : void
      {
         owner.eventDispatcher.removeEventListener(DecorationsManager.SOURCE_PLACED,this.onSourcePlaced);
         owner.eventDispatcher.removeEventListener(DecorationsManager.SOURCE_REMOVED,this.onSourceRemoved);
         this.removeFeedback();
         super.onRemove();
      }
      
      private function onSourcePlaced(param1:WorldEvent) : void
      {
         var _loc8_:XML = null;
         var _loc9_:XML = null;
         var _loc10_:XML = null;
         var _loc2_:DecorationItem = param1.eventData.data;
         if(!_loc2_.doesAffect(this.m_decoTargets))
         {
            return;
         }
         var _loc3_:Boolean = Boolean(param1.eventData.forPlacement);
         var _loc4_:int = int(param1.eventData.id);
         var _loc5_:Boolean = Boolean(param1.eventData.isBuilt);
         var _loc6_:Array = _loc2_.getEffectsData(this.m_decoTargets);
         var _loc7_:int = this.getSourceIndexByID(_loc4_);
         if(_loc7_ >= 0)
         {
            this.m_sources[_loc7_].forPlacement = _loc3_;
            this.m_sources[_loc7_].isBuilt = _loc5_;
            this.m_sources[_loc7_].effectsData = _loc6_;
         }
         else
         {
            this.m_sources.push({
               "id":_loc4_,
               "forPlacement":_loc3_,
               "effectsData":_loc6_,
               "isBuilt":_loc5_
            });
         }
         if(!param1.eventData.forPlacement)
         {
            for each(_loc8_ in _loc6_)
            {
               if(_loc8_.@effect.toString() == DecorationsManager.EFFECT_CONTRACT_DURATION)
               {
                  this.updateContractDurationDecoEffect();
                  break;
               }
            }
            for each(_loc9_ in _loc6_)
            {
               if(_loc9_.@effect.toString() == DecorationsManager.EFFECT_ARMY_RESEARCH_ACCELERATION)
               {
                  this.updateResearchAccelerationDecoEffect();
                  break;
               }
            }
            for each(_loc10_ in _loc6_)
            {
               if(_loc10_.@effect.toString() == DecorationsManager.EFFECT_FARM_CAMP_DURATION)
               {
                  this.updateFarmCampDurationTargetProgress();
                  break;
               }
            }
         }
         this.updateFeedback();
      }
      
      private function onSourceRemoved(param1:WorldEvent) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:XML = null;
         var _loc8_:XML = null;
         var _loc9_:XML = null;
         var _loc2_:int = int(param1.eventData.id);
         var _loc3_:int = this.getSourceIndexByID(_loc2_);
         if(_loc3_ >= 0)
         {
            _loc4_ = false;
            _loc5_ = false;
            _loc6_ = false;
            for each(_loc7_ in this.m_sources[_loc3_].effectsData)
            {
               if(_loc7_.@effect.toString() == DecorationsManager.EFFECT_CONTRACT_DURATION)
               {
                  _loc4_ = true;
                  break;
               }
            }
            for each(_loc8_ in this.m_sources[_loc3_].effectsData)
            {
               if(_loc8_.@effect.toString() == DecorationsManager.EFFECT_ARMY_RESEARCH_ACCELERATION)
               {
                  _loc6_ = true;
                  break;
               }
            }
            for each(_loc9_ in this.m_sources[_loc3_].effectsData)
            {
               if(_loc9_.@effect.toString() == DecorationsManager.EFFECT_FARM_CAMP_DURATION)
               {
                  _loc5_ = true;
                  break;
               }
            }
            if(param1.eventData.forPlacement)
            {
               if(this.m_sources[_loc3_].forPlacement)
               {
                  this.m_sources.splice(_loc3_,1);
               }
            }
            else
            {
               this.m_sources.splice(_loc3_,1);
            }
            if(_loc4_)
            {
               this.updateContractDurationDecoEffect();
            }
            if(_loc5_)
            {
               this.updateFarmCampDurationTargetProgress();
            }
            if(_loc6_)
            {
               this.updateResearchAccelerationDecoEffect();
            }
            this.updateFeedback();
         }
      }
      
      private function updateFeedback() : void
      {
         if(this.shouldShowFeedback)
         {
            this.showFeedback();
         }
         else
         {
            this.removeFeedback();
         }
      }
      
      private function removeFeedback() : void
      {
         if(this.m_tooltipMC)
         {
            if(this.m_tooltipMC.parent)
            {
               this.m_tooltipMC.parent.removeChild(this.m_tooltipMC);
            }
            this.m_tooltipMC = null;
         }
      }
      
      private function showFeedback() : void
      {
         var _loc1_:Array = this.feedbackInfo;
         if(Boolean(_loc1_.length > 0) && Boolean(this.m_sprite.parent) && Boolean(this.m_sprite.parent.parent))
         {
            if(!this.m_tooltipMC)
            {
               if(this.m_tooltipClass)
               {
                  this.m_tooltipMC = new this.m_tooltipClass();
                  this.initTooltip();
               }
            }
            if(this.m_tooltipMC)
            {
               this.initTooltipInstance(_loc1_);
            }
            this.m_sprite.parent.parent.addChild(this.m_container);
         }
      }
      
      private function initTooltipInstance(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc2_:Array = [];
         var _loc3_:Boolean = false;
         for each(_loc4_ in param1)
         {
            _loc2_.push(_loc4_.msg);
            if(_loc4_.capReached)
            {
               _loc3_ = true;
            }
         }
         _loc5_ = _loc2_.join("\n");
         _loc6_ = _loc3_ ? 15597568 : 0;
         this.m_tooltipMC.generic_tf.textColor = _loc6_;
         TextFieldUtil.processTextField(this.m_tooltipMC.generic_tf,_loc5_);
         this.m_tooltipMC.x = this.m_sprite.parent.x + this.m_sprite.x;
         this.m_tooltipMC.y = this.m_sprite.parent.y + this.m_sprite.y;
         this.resizeTooltipBackground(this.widestTooltipElementWidth);
         if(_loc2_.length > 1)
         {
            this.resizeTooltipHeight();
         }
      }
      
      private function resizeTooltipBackground(param1:int) : void
      {
         var _loc2_:int = param1 / 2;
         this.m_tooltipMC.bubble_mc.box_lt.width = _loc2_;
         this.m_tooltipMC.bubble_mc.box_rt.width = _loc2_;
         this.m_tooltipMC.title_tf.x = 10 + this.m_tooltipMC.bubble_mc.width / 2 * -1;
      }
      
      private function resizeTooltipHeight() : void
      {
         var _loc1_:int = 0;
         if(this.m_tooltipMC.generic_tf != null && this.m_tooltipMC.title_tf != null)
         {
            _loc1_ = this.m_tooltipMC.generic_tf.height - this.m_tooltipMC.bubble_mc.box_lt.height + 10;
            this.m_tooltipMC.bubble_mc.box_lt.height += _loc1_;
            this.m_tooltipMC.bubble_mc.box_ctr.height += _loc1_;
            this.m_tooltipMC.bubble_mc.box_rt.height += _loc1_;
            this.m_tooltipMC.title_tf.y -= _loc1_;
            this.m_tooltipMC.generic_tf.y -= _loc1_;
         }
      }
      
      private function get widestTooltipElementWidth() : int
      {
         var _loc1_:Number = Math.max(this.m_tooltipMC.title_tf.width,this.m_tooltipMC.generic_tf.width);
         return Math.ceil(_loc1_);
      }
      
      private function initTooltip() : void
      {
         this.m_tooltipMC.title_tf.autoSize = "left";
         this.m_tooltipMC.generic_tf.autoSize = "center";
         this.m_tooltipMC.scaleX = this.m_tooltipMC.scaleY = 2;
         var _loc1_:String = ZGameUtils.ZlocT("Decorations","TooltipHeader");
         TextFieldUtil.processTextField(this.m_tooltipMC.title_tf,_loc1_);
         this.m_container.addChild(this.m_tooltipMC);
      }
      
      private function get feedbackInfo() : Array
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc6_:String = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this.m_decoEffects)
         {
            _loc3_ = this.getEffectAmount(false,true,_loc2_,true);
            _loc4_ = "";
            _loc5_ = false;
            if(Boolean(_loc3_) && Boolean(_loc3_.amount) || Boolean(_loc3_.placementAmount))
            {
               if(!_loc3_.amount)
               {
                  _loc6_ = "DecoPlace_Base_";
                  _loc3_.amount = _loc3_.placementAmount;
               }
               else if(this.m_beingMoved)
               {
                  _loc6_ = "DecoPlace_Base_";
               }
               else
               {
                  _loc6_ = "DecoPlace_BonusPlusBase_";
                  _loc3_.amount += _loc3_.placementAmount;
               }
               _loc5_ = _loc3_.amount >= _loc3_.cap;
               _loc3_.amount = Math.min(_loc3_.amount,_loc3_.cap);
               _loc4_ = ZGameUtils.ZlocT("Decorations",_loc6_ + _loc2_,_loc3_);
               _loc1_.push({
                  "msg":_loc4_,
                  "capReached":_loc5_
               });
            }
         }
         return _loc1_;
      }
      
      private function getSourceIndexByID(param1:int) : int
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this.m_sources)
         {
            if(_loc3_.id == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function get anyNearbyDecorationsBeingMoved() : Boolean
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this.m_sources)
         {
            if(_loc1_.forPlacement)
            {
               return true;
            }
         }
         return false;
      }
      
      private function get shouldShowFeedback() : Boolean
      {
         var _loc1_:GMObjectMove = GameModeManager.instance.getTopGameMode() as GMObjectMove;
         if(!_loc1_ || !_loc1_.isCurrentPlacementValid)
         {
            return false;
         }
         if(!this.m_sources.length)
         {
            return false;
         }
         if(!this.m_beingMoved && !this.anyNearbyDecorationsBeingMoved)
         {
            return false;
         }
         var _loc2_:BuildingFSMComponent = owner.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
         if(Boolean(_loc2_) && Boolean(id) && !_loc2_.isBuilt)
         {
            return false;
         }
         return true;
      }
      
      public function get sprite() : Sprite
      {
         return this.m_sprite;
      }
      
      public function registerStateEnter(param1:String) : void
      {
         var _loc2_:Object = this.getEffectResourcesAndAmount(true,param1);
         if(_loc2_)
         {
            this.m_deferredPayouts[param1] = _loc2_;
         }
      }
      
      public function getDiscount() : Dictionary
      {
         var _loc3_:String = null;
         var _loc1_:Dictionary = new Dictionary();
         var _loc2_:Object = null;
         for each(_loc3_ in this.m_decoEffects)
         {
            _loc2_ = this.getEffectResourcesAndAmount(true,_loc3_);
            if(_loc2_ != null)
            {
               _loc1_[_loc3_] = _loc2_;
            }
         }
         return _loc1_;
      }
      
      private function getEffectResourcesAndAmount(param1:Boolean, param2:String) : Object
      {
         var _loc3_:String = null;
         if(!param2)
         {
            return null;
         }
         var _loc4_:Array = DecorationsManager.instance.getAffectedResources(param2);
         var _loc5_:int = int(this.getEffectAmount(param1,false,param2).amount);
         if(!_loc5_)
         {
            return null;
         }
         return {
            "amount":_loc5_,
            "resources":_loc4_
         };
      }
      
      public function registerStateExit(param1:String) : Object
      {
         var _loc2_:Object = null;
         if(Boolean(param1) && this.m_deferredPayouts[param1] != 0)
         {
            _loc2_ = this.m_deferredPayouts[param1];
         }
         delete this.m_deferredPayouts[param1];
         return _loc2_;
      }
      
      private function getAmountLabel(param1:int) : String
      {
         var _loc2_:Object = {"id":param1};
         var _loc3_:WorldEvent = new WorldEvent(GameDataComponent.DECO_CREWCOUNT_QUERY,_loc2_);
         CrewManager.instance.dispatchEvent(_loc3_);
         if(_loc2_.crewCount)
         {
            return DecorationsManager.LABEL_AMOUNT_CREWED;
         }
         return DecorationsManager.LABEL_AMOUNT_NORMAL;
      }
      
      private function getEffectAmount(param1:Boolean, param2:Boolean, param3:String, param4:Boolean = false) : Object
      {
         var _loc7_:Object = null;
         var _loc8_:int = 0;
         var _loc9_:XML = null;
         var _loc10_:XMLList = null;
         var _loc11_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         for each(_loc7_ in this.m_sources)
         {
            if(!(!param2 && Boolean(_loc7_.forPlacement)))
            {
               if(!(!param4 && !_loc7_.isBuilt))
               {
                  for each(_loc9_ in _loc7_.effectsData)
                  {
                     if(!(_loc9_.@effect == undefined || param3 != _loc9_.@effect.toString() || this.m_decoEffects.indexOf(param3) < 0))
                     {
                        _loc10_ = _loc9_.attribute(this.getAmountLabel(_loc7_.id));
                        if(!(!_loc10_ || !_loc10_.length()))
                        {
                           if(param3 == DecorationsManager.EFFECT_FARM_CAMP_DURATION)
                           {
                              if(FarmCampManager.instance.isActive())
                              {
                                 _loc11_ = FarmCampManager.instance.effectPercentage;
                              }
                              else
                              {
                                 _loc11_ = 0;
                              }
                           }
                           else
                           {
                              _loc11_ = DecorationsManager.instance.getEffectVariantAmount(_loc10_[0].toString(),param3);
                           }
                           _loc11_ += this.getFullCrewBonus(_loc7_);
                           if(_loc7_.forPlacement)
                           {
                              if(param3 == DecorationsManager.EFFECT_FARM_CAMP_DURATION && !FarmCampManager.instance.isActive())
                              {
                                 _loc6_ += FarmCampManager.instance.getBaseAcceleration();
                              }
                              else
                              {
                                 _loc6_ += _loc11_;
                              }
                           }
                           else
                           {
                              _loc5_ += _loc11_;
                           }
                        }
                     }
                  }
               }
            }
         }
         _loc8_ = DecorationsManager.instance.getEffectCap(param3);
         if(param1)
         {
            _loc5_ = Math.min(_loc5_,_loc8_);
         }
         return {
            "amount":_loc5_,
            "placementAmount":_loc6_,
            "cap":_loc8_
         };
      }
      
      private function isSourceFullyCrewd() : Boolean
      {
         var _loc1_:IEntity = null;
         return true;
      }
      
      public function getContractDurationPercentage() : Number
      {
         return this.getEffectAmount(true,true,DecorationsManager.EFFECT_CONTRACT_DURATION).amount;
      }
      
      public function getFarmCampDurationPercentage(param1:Boolean = false) : Number
      {
         return this.getEffectAmount(true,true,DecorationsManager.EFFECT_FARM_CAMP_DURATION).amount;
      }
      
      public function getResearchAccelerationPercentage() : Number
      {
         return this.getEffectAmount(true,true,DecorationsManager.EFFECT_ARMY_RESEARCH_ACCELERATION).amount;
      }
      
      private function getFullCrewBonus(param1:Object) : int
      {
         var _loc2_:IEntity = ZGlobal.game.getObjectByID(param1.id);
         if(!_loc2_)
         {
            return 0;
         }
         var _loc3_:GameDataComponent = GameDataComponent.getGameDataComponent(_loc2_);
         if(_loc3_)
         {
            _loc3_.updateCrew();
         }
         if(!CrewManager.isCrewBuildingFull(_loc2_))
         {
            return 0;
         }
         return DecorationsManager.instance.fullCrewBonusAmount;
      }
      
      override protected function onSpriteStart(param1:Event) : void
      {
         this.m_beingMoved = true;
         this.updateFeedback();
      }
      
      override protected function onSpriteStop(param1:Event) : void
      {
         this.m_beingMoved = false;
         this.updateFeedback();
         this.updateContractDurationDecoEffect();
         this.updateFarmCampDurationTargetProgress();
         this.updateResearchAccelerationDecoEffect();
      }
      
      private function get effectAOE() : Object
      {
         var _loc1_:int = ZGlobal.gameSettings.getInt("maxBuildingSize",5);
         var _loc2_:int = ZGlobal.gameSettings.getInt("decorationsMaxAOE",5);
         var _loc3_:Point = entityPos;
         var _loc4_:Point = _loc3_.clone();
         _loc3_.x -= _loc1_ + _loc2_;
         _loc3_.y -= _loc1_ + _loc2_;
         _loc4_.x += gameItem.sizeX + _loc2_;
         _loc4_.y += gameItem.sizeY + _loc2_;
         var _loc5_:Point = new Point(_loc4_.x - _loc3_.x,_loc4_.y - _loc3_.y);
         return {
            "pos":_loc3_,
            "volume":_loc5_
         };
      }
      
      override protected function onEntityTilePosChanged(param1:Point, param2:Point) : void
      {
         var _loc8_:IEntity = null;
         var _loc3_:Object = {
            "x":param2.x,
            "y":param2.y,
            "xLength":gameItem.sizeX,
            "yLength":gameItem.sizeY
         };
         var _loc4_:Object = {
            "shape":_loc3_,
            "targets":this.m_decoTargets,
            "gameItem":gameItem,
            "results":[]
         };
         var _loc5_:WorldEvent = new WorldEvent(DecorationsManager.TARGET_MOVED,_loc4_);
         var _loc6_:Object = this.effectAOE;
         var _loc7_:Array = [];
         BuildManager.instance.getObjectIDsOverlappingVolume(_loc6_.pos,_loc6_.volume,_loc7_);
         for each(_loc8_ in _loc7_)
         {
            _loc8_.eventDispatcher.dispatchEvent(_loc5_.clone());
         }
         this.m_sources = _loc4_.results;
         this.updateFeedback();
      }
      
      private function updateContractDurationDecoEffect() : void
      {
         var _loc1_:BuildingFSMComponent = owner.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
         var _loc2_:BehaviorState = _loc1_.stateMachine.getState(_loc1_.stateMachine.currentStateName) as BehaviorState;
         var _loc3_:Number = this.getContractDurationPercentage();
         _loc2_.updateProgress(_loc3_ - this.m_contractDurationEffect);
         this.m_contractDurationEffect = _loc3_;
      }
      
      private function updateFarmCampDurationTargetProgress() : void
      {
         var _loc2_:BuildingFSMComponent = null;
         var _loc3_:BehaviorState = null;
         var _loc1_:int = this.getFarmCampDurationPercentage();
         if(this.m_farmCampDurationEffect != _loc1_ && FarmCampManager.instance.isActive())
         {
            _loc2_ = owner.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
            _loc3_ = _loc2_.stateMachine.getState(_loc2_.stateMachine.currentStateName) as BehaviorState;
            GlobalEngine.info("Time Updated","Now");
            _loc3_.updateProgress(_loc1_ - this.m_farmCampDurationEffect);
            this.m_farmCampDurationEffect = _loc1_;
         }
      }
      
      private function updateResearchAccelerationDecoEffect() : void
      {
         var _loc1_:BuildingFSMComponent = owner.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
         var _loc2_:BehaviorState = _loc1_.stateMachine.getState(_loc1_.stateMachine.currentStateName) as BehaviorState;
         var _loc3_:Number = this.getResearchAccelerationPercentage();
         _loc2_.updateProgress(_loc3_ - this.m_researchAccelerationEffect);
         this.m_researchAccelerationEffect = _loc3_;
      }
   }
}

