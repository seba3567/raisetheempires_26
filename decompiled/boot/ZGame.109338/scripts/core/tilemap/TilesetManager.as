package core.tilemap
{
   import core.managers.BuildManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import init.CompleteMonitor;
   
   public class TilesetManager extends EventDispatcher
   {
      
      public static const ANIMATING_WATER:Boolean = false;
      
      public static var instance:TilesetManager = new TilesetManager();
      
      private var m_tileSets:Dictionary = null;
      
      private var m_completeMonitor:CompleteMonitor = null;
      
      public function TilesetManager()
      {
         super();
      }
      
      public function initFromXML(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc4_:Tileset = null;
         this.m_tileSets = new Dictionary();
         this.m_completeMonitor = new CompleteMonitor();
         this.m_completeMonitor.addEventListener(Event.COMPLETE,this.onTileLoadsComplete);
         for each(_loc2_ in param1.tilesets.tileset)
         {
            _loc4_ = new Tileset();
            this.m_completeMonitor.addDispatcher(_loc4_);
            this.m_tileSets[_loc2_.@name.toString()] = _loc4_;
         }
         for each(_loc3_ in param1.tilesets.tileset)
         {
            _loc4_.load(_loc3_);
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:Tileset = null;
         this.m_completeMonitor = null;
         for each(_loc1_ in this.m_tileSets)
         {
            _loc1_.dispose();
         }
         this.m_tileSets = null;
      }
      
      public function getTileset(param1:String) : Tileset
      {
         return this.m_tileSets[param1];
      }
      
      public function loadTileAnimation(param1:String, param2:String, param3:Function) : void
      {
         this.m_tileSets[param1].loadTileAnimation(param2,param3);
      }
      
      public function populateBuildData(param1:String, param2:String, param3:String, param4:Point) : void
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc5_:Tileset = this.m_tileSets[param1];
         var _loc6_:int = _loc5_.tileWidth;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         while(_loc8_ < _loc6_)
         {
            _loc9_ = 0;
            while(_loc9_ < _loc6_)
            {
               _loc7_ = _loc5_.getBuildData(param2,_loc6_ - 1 - _loc8_,_loc9_);
               _loc10_ = param4.x * _loc6_ + _loc9_;
               _loc11_ = param4.y * _loc6_ + _loc8_;
               BuildManager.instance.setIslandCode(_loc10_,_loc11_,param3);
               BuildManager.instance.setBuildType(_loc10_,_loc11_,_loc7_);
               _loc9_++;
            }
            _loc8_++;
         }
      }
      
      protected function onTileLoadsComplete(param1:Event) : void
      {
         this.m_completeMonitor.removeEventListener(Event.COMPLETE,this.onTileLoadsComplete);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

