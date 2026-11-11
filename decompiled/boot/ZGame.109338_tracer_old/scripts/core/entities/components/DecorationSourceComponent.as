package core.entities.components
{
   import core.ZGlobal;
   import core.gamemode.GMObjectMove;
   import core.gamemode.GameModeManager;
   import core.gamemode.IsoOutlineRect;
   import core.gameobjects.DecorationItem;
   import core.managers.BuildManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.worlds.AbstractWorld;
   import core.worlds.islandworld.IslandWorld;
   import entity.GameDataComponent;
   import events.TransitionEvent;
   import flash.events.Event;
   import flash.geom.Point;
   import utils.TileUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   
   public class DecorationSourceComponent extends GameEntityComponent
   {
      
      private var m_item:DecorationItem;
      
      private var m_rect:IsoOutlineRect;
      
      private var m_aoeShape:Object;
      
      private var m_tooltipProperty:PropertyReference = new PropertyReference("@controller.toolTip");
      
      public function DecorationSourceComponent()
      {
         super();
      }
      
      private function get size() : Point
      {
         if(this.m_aoeShape)
         {
            return new Point(this.m_aoeShape.xLength,this.m_aoeShape.yLength);
         }
         return new Point(0,0);
      }
      
      override protected function onAdd() : void
      {
         this.m_item = ZGlobal.gameSettings.getItemByCode(gameItem.code,DecorationItem) as DecorationItem;
         this.updateShape();
         var _loc1_:AbstractWorld = ZGlobal.game.getWorld(IslandWorld.ID);
         if(_loc1_)
         {
            _loc1_.addEventListener(AbstractWorld.LOAD_OBJECTS_COMPLETE,this.onLoadObjectsComplete,false,0,true);
         }
         owner.eventDispatcher.addEventListener(GameDataComponent.ID_SET,this.onIDSet,false,0,true);
         owner.eventDispatcher.addEventListener(GameDataComponent.CREW_UPDATED,this.onCrewUpdated,false,0,true);
         owner.eventDispatcher.addEventListener(DecorationsManager.TARGET_MOVED,this.onTargetMoved,false,0,true);
         owner.eventDispatcher.addEventListener(TransitionEvent.TRANSITION,this.onTransition,false,0,true);
         this.updateTooltip();
         super.onAdd();
      }
      
      override protected function onRemove() : void
      {
         this.broadcastEntityEvent(this.aoePos(entityPos),new WorldEvent(DecorationsManager.SOURCE_REMOVED,{
            "id":id,
            "forPlacement":false
         }));
         var _loc1_:AbstractWorld = ZGlobal.game.getWorld(IslandWorld.ID);
         if(_loc1_)
         {
            _loc1_.removeEventListener(AbstractWorld.LOAD_OBJECTS_COMPLETE,this.onLoadObjectsComplete);
         }
         owner.eventDispatcher.removeEventListener(GameDataComponent.ID_SET,this.onIDSet);
         owner.eventDispatcher.removeEventListener(GameDataComponent.CREW_UPDATED,this.onCrewUpdated);
         owner.eventDispatcher.removeEventListener(DecorationsManager.TARGET_MOVED,this.onTargetMoved);
         owner.eventDispatcher.removeEventListener(TransitionEvent.TRANSITION,this.onTransition);
         this.disposeRect();
         super.onRemove();
      }
      
      private function onLoadObjectsComplete(param1:Event) : void
      {
         this.broadcastPresence(false);
      }
      
      private function broadcastEntityEvent(param1:Point, param2:WorldEvent) : void
      {
         var _loc4_:IEntity = null;
         if(param2.type == DecorationsManager.SOURCE_PLACED)
         {
            param2.eventData.isBuilt = this.canUpdateTooltip;
         }
         var _loc3_:Array = new Array();
         BuildManager.instance.getObjectIDsOverlappingVolume(param1,this.size,_loc3_);
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_ != owner)
            {
               _loc4_.eventDispatcher.dispatchEvent(param2.clone());
            }
         }
         DecorationsManager.instance.dispatchEvent(param2.clone());
      }
      
      private function aoePos(param1:Point = null) : Point
      {
         var _loc2_:Point = param1 ? param1 : entityPos;
         return new Point(_loc2_.x - this.m_item.aoe,_loc2_.y - this.m_item.aoe);
      }
      
      private function broadcastPresence(param1:Boolean, param2:Point = null) : void
      {
         if(param2)
         {
            this.broadcastEntityEvent(this.aoePos(param2),new WorldEvent(DecorationsManager.SOURCE_REMOVED,{
               "id":id,
               "forPlacement":param1
            }));
         }
         this.broadcastEntityEvent(this.aoePos(),new WorldEvent(DecorationsManager.SOURCE_PLACED,{
            "id":id,
            "forPlacement":param1,
            "data":this.m_item
         }));
      }
      
      override protected function onEntityTilePosChanged(param1:Point, param2:Point) : void
      {
         this.broadcastPresence(true,param1);
         this.updateRectPos();
         this.updateShape();
      }
      
      override protected function onSpriteStart(param1:Event) : void
      {
         this.disposeRect();
         var _loc2_:Point = this.size;
         this.m_rect = new IsoOutlineRect(_loc2_.x,_loc2_.y);
         this.m_rect.setColor(DecorationsManager.instance.getFeedbackColor(this.m_item),true);
         this.updateRectPos();
         super.onSpriteStart(param1);
      }
      
      override protected function onSpriteStop(param1:Event) : void
      {
         this.broadcastPresence(false);
         this.disposeRect();
         super.onSpriteStop(param1);
      }
      
      private function updateRectPos() : void
      {
         var _loc1_:Point = null;
         var _loc2_:Point = null;
         var _loc3_:GMObjectMove = null;
         var _loc4_:Boolean = false;
         if(this.m_rect)
         {
            _loc1_ = entityPos;
            _loc2_ = new Point(_loc1_.x,_loc1_.y);
            _loc2_.x -= this.m_item.aoe;
            _loc2_.y -= this.m_item.aoe;
            this.m_rect.setPosition(_loc2_);
            _loc3_ = GameModeManager.instance.getTopGameMode() as GMObjectMove;
            _loc4_ = Boolean(_loc3_) && _loc3_.isCurrentPlacementValid;
            this.m_rect.container.visible = _loc4_;
         }
      }
      
      private function disposeRect() : void
      {
         if(this.m_rect)
         {
            this.m_rect.dispose();
            this.m_rect = null;
         }
      }
      
      private function onIDSet(param1:WorldEvent) : void
      {
         var _loc2_:int = int(param1.eventData.oldID);
         var _loc3_:int = int(param1.eventData.newID);
         if(m_lastPos)
         {
            this.broadcastEntityEvent(this.aoePos(m_lastPos),new WorldEvent(DecorationsManager.SOURCE_REMOVED,{
               "id":_loc2_,
               "forPlacement":false
            }));
         }
         this.broadcastEntityEvent(this.aoePos(),new WorldEvent(DecorationsManager.SOURCE_PLACED,{
            "id":_loc3_,
            "forPlacement":false,
            "data":this.m_item
         }));
      }
      
      private function onTransition(param1:TransitionEvent) : void
      {
         this.broadcastPresence(false);
         this.updateTooltip();
      }
      
      private function onTargetMoved(param1:WorldEvent) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         var _loc2_:Object = param1.eventData.shape;
         if(TileUtil.tileOverlapCheck(_loc2_,this.m_aoeShape))
         {
            _loc3_ = this.m_item.getEffectsData(param1.eventData.targets);
            if(_loc3_.length > 0)
            {
               _loc4_ = {
                  "id":id,
                  "effectsData":_loc3_,
                  "isBuilt":this.canUpdateTooltip
               };
               param1.eventData.results.push(_loc4_);
            }
         }
      }
      
      private function get effectsStrings() : String
      {
         var _loc6_:XML = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc1_:Array = [];
         var _loc2_:XMLList = this.m_item.effectsXML;
         var _loc3_:GameDataComponent = GameDataComponent.getGameDataComponent(owner);
         var _loc4_:Boolean = Boolean(_loc3_) && Boolean(_loc3_.crewCount);
         var _loc5_:String = _loc4_ ? DecorationsManager.LABEL_AMOUNT_CREWED : DecorationsManager.LABEL_AMOUNT_NORMAL;
         for each(_loc6_ in _loc2_)
         {
            if(_loc6_.attribute(_loc5_) != undefined)
            {
               _loc8_ = DecorationsManager.instance.getEffectVariantAmount(_loc6_.attribute(_loc5_).toString(),_loc6_.@effect.toString());
               _loc9_ = "DecoPlace_Base_" + _loc6_.@effect.toString();
               _loc10_ = ZGameUtils.ZlocT("Decorations",_loc9_,{"amount":_loc8_});
               _loc1_.push(_loc10_);
            }
         }
         return _loc1_.join("\n");
      }
      
      private function get tooltipString() : String
      {
         var _loc1_:String = this.m_item.defaultTooltip();
         var _loc2_:String = this.effectsStrings;
         if(this.m_item.code == "DB11")
         {
            return _loc1_;
         }
         return _loc1_ + "\n" + _loc2_;
      }
      
      private function get canUpdateTooltip() : Boolean
      {
         var _loc1_:BuildingFSMComponent = null;
         if(!this.m_item.getStateMachineName(null))
         {
            return true;
         }
         _loc1_ = owner.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
         if(Boolean(_loc1_) && _loc1_.isBuilt)
         {
            return true;
         }
         return false;
      }
      
      private function updateTooltip() : void
      {
         var _loc1_:String = null;
         if(this.canUpdateTooltip)
         {
            _loc1_ = this.tooltipString;
            owner.setProperty(this.m_tooltipProperty,_loc1_);
         }
      }
      
      private function onCrewUpdated(param1:WorldEvent) : void
      {
         this.updateTooltip();
      }
      
      private function updateShape() : void
      {
         var _loc1_:Point = this.aoePos();
         this.m_aoeShape = {
            "x":_loc1_.x,
            "y":_loc1_.y,
            "xLength":this.m_item.sizeX + 2 * this.m_item.aoe,
            "yLength":this.m_item.sizeY + 2 * this.m_item.aoe
         };
      }
   }
}

