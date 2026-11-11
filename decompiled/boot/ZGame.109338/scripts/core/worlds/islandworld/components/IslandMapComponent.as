package core.worlds.islandworld.components
{
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.managers.BuildManager;
   import core.player.Player;
   import core.tilemap.TilesetTerrain;
   import core.ui.UIManager;
   import core.ui.menuitem.SettingsUIItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import events.IsoViewEvent;
   import flash.display.CapsStyle;
   import flash.display.JointStyle;
   import flash.display.LineScaleMode;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import utils.BitArray;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   import zlabs.utils.StringUtils;
   
   public class IslandMapComponent extends EntityComponent
   {
      
      public var isoViewPropRef:PropertyReference = null;
      
      private var m_gameIslands:Dictionary;
      
      private var m_islands:Array = null;
      
      private var m_previousLocation:Pt = null;
      
      private var m_expansions:Array = null;
      
      private var m_expansionIndexes:Array = null;
      
      private var m_expansionSprite:Sprite = null;
      
      public var m_displaySprite:Sprite;
      
      public function IslandMapComponent()
      {
         super();
         this.m_displaySprite = new Sprite();
         this.m_displaySprite.mouseEnabled = false;
         this.m_displaySprite.mouseChildren = false;
      }
      
      public function create(param1:int, param2:int, param3:int) : void
      {
         BuildManager.instance.ignoreRemoves = false;
         BuildManager.instance.setMapSize(param1,param2);
         this.dispose();
         this.m_expansionSprite = new Sprite();
         var _loc4_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         Sprite(_loc4_.backgroundContainer).addChild(this.m_expansionSprite);
         this.createIslands(param1,param2,this.happyDays(param3));
      }
      
      public function setInitialViewParams() : void
      {
         var _loc1_:Island = null;
         this.setCameraPosition();
         for each(_loc1_ in this.m_gameIslands)
         {
            _loc1_.updateAvatarPos();
         }
         this.updateExpansion(ZGlobal.hostPlayer.expansions);
      }
      
      private function happyDays(param1:int) : int
      {
         var _loc2_:Array = [this["happyDays1"],this["happyDays2"],this["happyDays3"]];
         var _loc3_:* = 0;
         param1 >>= _loc2_[_loc3_++]();
         param1 ^= _loc2_[_loc3_++]();
         return param1 >> _loc2_[_loc3_++]();
      }
      
      private function happyDays1() : int
      {
         return 5;
      }
      
      private function happyDays2() : int
      {
         return 3951936;
      }
      
      private function happyDays3() : int
      {
         return 1;
      }
      
      private function createIslands(param1:int, param2:int, param3:int) : void
      {
         var _loc7_:XML = null;
         var _loc8_:Boolean = false;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Island = null;
         var _loc4_:int = 0;
         this.m_islands = new Array();
         this.m_gameIslands = new Dictionary();
         var _loc5_:XML = ZGlobal.gameSettings.getXML();
         var _loc6_:int = 0;
         for each(_loc7_ in _loc5_.islands.island)
         {
            _loc8_ = (param3 & 1 << _loc6_) != 0;
            _loc9_ = _loc7_.@code;
            if(_loc7_.@name.indexOf("Water") < 0)
            {
               _loc10_ = _loc7_.@name;
               _loc11_ = new Island(_loc7_,param1);
               _loc11_.unlocked = _loc8_;
               _loc11_.id = _loc10_;
               this.m_gameIslands[_loc11_.code] = _loc11_;
            }
            this.m_islands.push(new TilesetTerrain(_loc7_,param1,_loc9_,this.m_displaySprite));
            _loc6_++;
         }
      }
      
      public function getAllIslands() : Dictionary
      {
         return this.m_gameIslands;
      }
      
      public function getIslandByCode(param1:String) : Island
      {
         return this.m_gameIslands[param1];
      }
      
      public function getIslandByPoint(param1:int, param2:int, param3:Boolean = true) : Island
      {
         var _loc4_:Island = null;
         for each(_loc4_ in this.m_gameIslands)
         {
            if(_loc4_.containsPoint(param1,param2,param3))
            {
               return _loc4_;
            }
         }
         return null;
      }
      
      public function updateExpansion(param1:BitArray) : void
      {
         var _loc2_:Island = null;
         var _loc3_:TilesetTerrain = null;
         for each(_loc2_ in this.m_gameIslands)
         {
            _loc2_.updateExpansion(param1);
         }
         for each(_loc3_ in this.m_islands)
         {
            _loc3_.updateExpansion(param1);
         }
      }
      
      private function drawOutline() : void
      {
         var _loc5_:Pt = null;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:Pt = null;
         this.m_expansions = new Array();
         this.m_expansionIndexes = new Array();
         ZGlobal.hostPlayer.expansions.iterate(this.addExpansionToList);
         this.m_expansionSprite.graphics.clear();
         this.m_expansionSprite.graphics.lineStyle(12,4210752,1,false,LineScaleMode.NORMAL,CapsStyle.ROUND,JointStyle.ROUND);
         var _loc1_:int = BuildManager.instance.width / 8;
         var _loc2_:Array = [-_loc1_,1,_loc1_,-1];
         var _loc3_:Array = [new Pt(0,0),new Pt(1,0),new Pt(1,1),new Pt(0,1)];
         var _loc4_:int = 0;
         for each(_loc5_ in this.m_expansions)
         {
            _loc6_ = int(this.m_expansionIndexes[_loc4_]);
            _loc7_ = [_loc5_.clone(),_loc5_.clone(),_loc5_.clone(),_loc5_.clone()];
            _loc8_ = 0;
            for each(_loc9_ in _loc7_)
            {
               _loc9_.x += _loc3_[_loc8_].x;
               _loc9_.y += _loc3_[_loc8_].y;
               _loc9_ = IsoMath.isoToScreen(_loc9_);
               _loc9_.x *= ZGlobal.cellSize * 8;
               _loc9_.y *= ZGlobal.cellSize * 8;
               _loc8_++;
            }
            _loc8_ = 0;
            while(_loc8_ < 4)
            {
               if(!ZGlobal.hostPlayer.expansions.isBitSet(_loc6_ + _loc2_[_loc8_]))
               {
                  this.m_expansionSprite.graphics.moveTo(_loc7_[_loc8_].x,_loc7_[_loc8_].y);
                  this.m_expansionSprite.graphics.lineTo(_loc7_[(_loc8_ + 1) % 4].x,_loc7_[(_loc8_ + 1) % 4].y);
               }
               _loc8_++;
            }
            _loc4_++;
         }
      }
      
      private function addExpansionToList(param1:int) : void
      {
         var _loc4_:int = 0;
         var _loc2_:int = BuildManager.instance.width / 8;
         var _loc3_:Array = [1,-1,_loc2_,-_loc2_];
         for each(_loc4_ in _loc3_)
         {
            if(!ZGlobal.hostPlayer.expansions.isBitSet(param1 + _loc4_))
            {
               this.m_expansionIndexes.push(param1);
               this.m_expansions.push(MathUtils.expansionIndexToGrid(param1,BuildManager.instance.width));
               break;
            }
         }
      }
      
      private function setCameraPosition() : void
      {
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         var _loc4_:Point = null;
         var _loc5_:SettingsUIItem = null;
         var _loc6_:String = null;
         var _loc1_:IsoViewComponent = owner.lookupComponentByType(IsoViewComponent) as IsoViewComponent;
         if(this.m_previousLocation != null && !ZGlobal.isVisiting())
         {
            _loc1_.centerOnPt(new Pt(this.m_previousLocation.x,this.m_previousLocation.y,0),false);
            _loc1_.zoom(this.m_previousLocation.z);
            this.m_previousLocation = null;
         }
         else
         {
            if(this.m_previousLocation == null && ZGlobal.isVisiting())
            {
               this.m_previousLocation = _loc1_.currentPt;
               this.m_previousLocation.z = _loc1_.currentZoom;
            }
            if(ZGlobal.isStartCameraPosSet() && !ZGlobal.isVisiting())
            {
               _loc2_ = ZGlobal.getStartCameraPos();
               ZGlobal.setStartCameraPos(null);
            }
            else if(ZGlobal.isStartVisitingCameraPosSet() && ZGlobal.isVisiting())
            {
               _loc2_ = ZGlobal.getStartVisitingCameraPos();
               ZGlobal.setStartVisitingCameraPos(null);
            }
            else
            {
               _loc6_ = "cameraStartingPosition";
               if(ZGlobal.hostPlayer.uid == Player.FAKE_PLAYER_ID)
               {
                  _loc6_ = "cameraStartingPositionAdvisor";
               }
               _loc2_ = ZGlobal.gameSettings.getString(_loc6_);
            }
            _loc3_ = ZGlobal.gameSettings.defaultZoom;
            _loc4_ = StringUtils.parsePoint(_loc2_);
            _loc1_.centerOnPt(MathUtils.tileToWorld(_loc4_.x,_loc4_.y,0,ZGlobal.cellSize));
            _loc1_.zoom(_loc3_);
            _loc5_ = SettingsUIItem(UIManager.instance.getMenuItemByName(SettingsUIItem.ITEM_ID));
            if(_loc5_)
            {
               _loc5_.setZoomToDefault();
            }
            GameModeManager.instance.dispatchEvent(new IsoViewEvent(IsoViewEvent.ISOVIEW_ZOOM,_loc3_));
         }
      }
      
      public function getIslandXML(param1:String) : XML
      {
         var _loc3_:XML = null;
         var _loc2_:XML = ZGlobal.gameSettings.getXML();
         for each(_loc3_ in _loc2_.islands.island)
         {
            if(_loc3_.@name == param1)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      private function getTilesetTerrainIndexByCode(param1:String) : int
      {
         var _loc4_:XML = null;
         var _loc2_:XML = ZGlobal.gameSettings.getXML();
         var _loc3_:int = 0;
         for each(_loc4_ in _loc2_.islands.island)
         {
            if(_loc4_.@code == param1)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      public function isUnlocked(param1:String) : Boolean
      {
         var _loc2_:Island = null;
         for each(_loc2_ in this.m_gameIslands)
         {
            if(_loc2_.isOwnedByLocalPlayer())
            {
               if(param1 == "any" || param1 == _loc2_.code)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function setUnlocked(param1:String, param2:Boolean) : void
      {
         var _loc3_:Island = this.m_gameIslands[param1];
         if(_loc3_)
         {
            _loc3_.unlocked = param2;
         }
      }
      
      public function getCenter(param1:String) : Point
      {
         var _loc2_:Island = this.m_gameIslands[param1];
         if(_loc2_)
         {
            return _loc2_.center;
         }
         return null;
      }
      
      public function getNextCodeToUnlock() : String
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc1_:XML = ZGlobal.gameSettings.getXML();
         for each(_loc2_ in _loc1_.islands.island)
         {
            _loc3_ = _loc2_.@code.toString();
            if(null != this.m_gameIslands[_loc3_] && !this.m_gameIslands[_loc3_].isOwnedByLocalPlayer())
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function dispose() : void
      {
         var _loc1_:TilesetTerrain = null;
         var _loc2_:Island = null;
         if(this.m_islands != null)
         {
            for each(_loc1_ in this.m_islands)
            {
               _loc1_.dispose();
            }
            this.m_islands = null;
         }
         if(null != this.m_gameIslands)
         {
            for each(_loc2_ in this.m_gameIslands)
            {
               _loc2_.dispose();
            }
            this.m_gameIslands = null;
         }
         if(null != this.m_expansionSprite)
         {
            this.m_expansionSprite.parent.removeChild(this.m_expansionSprite);
            this.m_expansionSprite = null;
         }
      }
   }
}

