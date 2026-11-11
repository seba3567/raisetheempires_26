package core.worlds.islandworld.components
{
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.gamemode.avatar.AvatarComponent;
   import core.gameobjects.GameItem;
   import core.managers.BuildManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.factory.IslandViewFactory;
   import entity.BuildingEntity;
   import entity.EntityInit;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import rendering.renderingIso.QuadSpatialManager;
   import utils.BitArray;
   import zlabs.Zlab;
   import zlabs.core.PBGroup;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   import zlabs.utils.StringUtils;
   
   public class Island
   {
      
      public static const ISLAND_LINES:String = "islandLines";
      
      private var map:Array;
      
      private var _height:Number;
      
      private var _width:Number;
      
      private var m_bounds:Rectangle;
      
      private var m_unlocked:Boolean = false;
      
      private var m_code:String;
      
      private var m_id:String;
      
      private var m_avatar:IEntity;
      
      private var m_avatarPos:Pt;
      
      private var m_expansions:Array = null;
      
      public function Island(param1:XML, param2:Number)
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:Point = null;
         super();
         this.m_code = param1.attribute("code");
         this.map = new Array();
         for each(_loc3_ in param1.tile)
         {
            _loc4_ = _loc3_.@type.toString();
            _loc5_ = StringUtils.parsePoint(_loc3_.@pos);
            this.map.push(_loc5_);
         }
         this.m_bounds = this.createBoundingRect();
         this.m_avatarPos = this.getAvatarPos(param1.@avatarPos.toString());
      }
      
      public function updateExpansion(param1:BitArray) : void
      {
         var _loc2_:uint = 0;
         if(null == this.m_avatar)
         {
            for each(_loc2_ in this.m_expansions)
            {
               if(param1.isBitSet(_loc2_))
               {
                  this.unlocked = true;
                  break;
               }
            }
         }
      }
      
      private function getAvatarPos(param1:String) : Pt
      {
         var _loc2_:Point = null;
         if(param1.length > 0)
         {
            _loc2_ = StringUtils.parsePoint(param1);
            return new Pt(_loc2_.x,_loc2_.y);
         }
         return new Pt(this.center.x,this.center.y);
      }
      
      private function createBoundingRect() : Rectangle
      {
         var _loc7_:Point = null;
         var _loc8_:uint = 0;
         this.m_expansions = new Array();
         var _loc1_:int = int.MAX_VALUE;
         var _loc2_:int = int.MIN_VALUE;
         var _loc3_:int = int.MAX_VALUE;
         var _loc4_:int = int.MIN_VALUE;
         var _loc5_:int = 0;
         while(_loc5_ < this.map.length)
         {
            _loc7_ = this.map[_loc5_];
            _loc8_ = MathUtils.gridToExpansionIndex(_loc7_.x,_loc7_.y,BuildManager.instance.width);
            if(this.m_expansions.indexOf(_loc8_) < 0)
            {
               this.m_expansions.push(_loc8_);
            }
            _loc7_.x *= 4;
            _loc7_.y *= 4;
            _loc1_ = Math.min(_loc1_,_loc7_.x);
            _loc2_ = Math.max(_loc2_,_loc7_.x + 4);
            _loc3_ = Math.min(_loc3_,_loc7_.y);
            _loc4_ = Math.max(_loc4_,_loc7_.y + 4);
            _loc5_++;
         }
         return new Rectangle(_loc1_,_loc3_,_loc2_ - _loc1_,_loc4_ - _loc3_);
      }
      
      public function updateAvatarPos() : void
      {
         var _loc1_:Point = null;
         var _loc2_:BuildingSpatialComponent = null;
         if(null != this.m_avatar)
         {
            this.m_avatarPos = MathUtils.tileToWorld(this.m_avatarPos.x,this.m_avatarPos.y,0,ZGlobal.cellSize);
            _loc1_ = BuildManager.instance.getNearestFreeLocation(this.m_avatarPos.x,this.m_avatarPos.y);
            _loc1_.x += ZGlobal.cellSize * 0.25;
            _loc1_.y += ZGlobal.cellSize * 0.25;
            _loc2_ = BuildingSpatialComponent(this.m_avatar.lookupComponentByType(BuildingSpatialComponent));
            _loc2_.position = new Vector3D(_loc1_.x,_loc1_.y,this.m_avatarPos.z);
            this.m_avatarPos = MathUtils.worldToTile(new Pt(_loc1_.x,_loc1_.y),ZGlobal.cellSize);
         }
      }
      
      private function createAvatar() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:PBGroup = null;
         var _loc3_:QuadSpatialManager = null;
         var _loc4_:IsoViewComponent = null;
         var _loc5_:IsoScene = null;
         var _loc6_:EntityInit = null;
         if(!this.m_avatar)
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode("AV1",GameItem) as GameItem;
            _loc2_ = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
            _loc3_ = ViewManager.instance.getComponentFromName(IslandWorld.ID,IslandViewFactory.AREA_OBJECTS) as QuadSpatialManager;
            _loc4_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
            _loc5_ = IsoScene(_loc4_.getSceneByID("gameScene"));
            _loc6_ = new EntityInit();
            _loc6_.m_isoScene = _loc5_;
            _loc6_.m_spatialComponent = _loc3_;
            _loc6_.m_item = _loc1_;
            _loc6_.m_position = this.m_avatarPos;
            _loc6_.m_group = _loc2_;
            this.m_avatar = BuildingEntity.createEntity(_loc6_);
         }
      }
      
      private function removeAvatar() : void
      {
         if(null != this.m_avatar)
         {
            this.m_avatar.destroy();
            this.m_avatar = null;
         }
      }
      
      public function get avatar() : AvatarComponent
      {
         if(this.m_avatar)
         {
            return this.m_avatar.lookupComponentByType(AvatarComponent) as AvatarComponent;
         }
         return null;
      }
      
      public function dispose() : void
      {
         this.removeAvatar();
         this.m_avatarPos = null;
      }
      
      public function containsPoint(param1:int, param2:int, param3:Boolean = true) : Boolean
      {
         var _loc6_:String = null;
         var _loc4_:Number = Number(param1) + 0.5;
         var _loc5_:Number = Number(param2) + 0.5;
         if(this.m_bounds.contains(_loc4_,_loc5_))
         {
            if(BuildManager.instance.getIslandCode(param1,param2) == this.m_code)
            {
               if(param3)
               {
                  _loc6_ = BuildManager.instance.LAND_OR_COAST_STR;
               }
               else
               {
                  _loc6_ = BuildManager.instance.LAND_OR_WATER_OR_COAST_STR;
               }
               if(BuildManager.instance.getBuildType(param1,param2,_loc6_))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get topLeft() : Point
      {
         return this.m_bounds.topLeft;
      }
      
      public function get center() : Point
      {
         var _loc1_:Point = this.topLeft;
         _loc1_.x += (this.m_bounds.width - 1) / 2;
         _loc1_.y += (this.m_bounds.height - 1) / 2;
         return _loc1_;
      }
      
      public function get code() : String
      {
         return this.m_code;
      }
      
      public function set id(param1:String) : void
      {
         this.m_id = param1;
      }
      
      public function get id() : String
      {
         return this.m_id;
      }
      
      public function isOwnedByLocalPlayer() : Boolean
      {
         return ZGlobal.visitMode == ZGlobal.MODE_HOME;
      }
      
      public function set unlocked(param1:Boolean) : void
      {
         this.m_unlocked = param1;
         if(this.isOwnedByLocalPlayer() && this.m_unlocked)
         {
            this.createAvatar();
         }
      }
   }
}

