package core.tilemap
{
   import as3isolib.geom.Pt;
   import flash.display.Sprite;
   import flash.geom.Point;
   import utils.BitArray;
   import zlabs.debug.Logger;
   import zlabs.utils.StringUtils;
   
   public class TilesetTerrain
   {
      
      private var m_tileImages:Array = null;
      
      private var m_displaySprite:Sprite;
      
      private var m_code:String = "";
      
      public function TilesetTerrain(param1:XML, param2:int, param3:String, param4:Sprite)
      {
         super();
         this.m_displaySprite = param4;
         this.m_code = param3;
         if(param1)
         {
            this.loadIsland(param1,param2);
         }
         else
         {
            Logger.error(this,"TilesetTerrain","can\'t find island XML data for \'" + param1.@name.toString() + "\'");
         }
      }
      
      public function updateExpansion(param1:BitArray) : void
      {
         var _loc2_:TileImage = null;
         for each(_loc2_ in this.m_tileImages)
         {
            _loc2_.updateExpansion(param1,false);
         }
         for each(_loc2_ in this.m_tileImages)
         {
            _loc2_.updateExpansion(param1,true);
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:TileImage = null;
         if(this.m_tileImages)
         {
            for each(_loc1_ in this.m_tileImages)
            {
               _loc1_.dispose();
            }
            this.m_tileImages = null;
         }
         this.m_displaySprite = null;
      }
      
      private function calculateIslandWidth(param1:XML) : Number
      {
         var _loc3_:XML = null;
         var _loc2_:Number = 0;
         for each(_loc3_ in param1.tile)
         {
            _loc2_ += 1;
         }
         return Math.sqrt(_loc2_);
      }
      
      private function loadIsland(param1:XML, param2:int) : void
      {
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:Point = null;
         var _loc3_:Number = this.calculateIslandWidth(param1);
         var _loc4_:String = param1.@tileset.toString();
         this.m_tileImages = new Array();
         for each(_loc5_ in param1.tile)
         {
            _loc6_ = _loc5_.@type.toString();
            _loc7_ = StringUtils.parsePoint(_loc5_.@pos);
            this.createImage(_loc4_,_loc6_,param2,_loc7_);
            this.createBuildData(_loc4_,_loc6_,_loc7_);
         }
      }
      
      private function createImage(param1:String, param2:String, param3:int, param4:Point) : void
      {
         var _loc5_:TileImage = new TileImage(param1,param2,param3,param4,this.m_displaySprite);
         this.m_tileImages.push(_loc5_);
      }
      
      private function createBuildData(param1:String, param2:String, param3:Point) : void
      {
         TilesetManager.instance.populateBuildData(param1,param2,this.m_code,param3);
      }
      
      private function getMeanTilePosition() : Pt
      {
         var _loc2_:TileImage = null;
         var _loc1_:Pt = new Pt(0,0);
         for each(_loc2_ in this.m_tileImages)
         {
            _loc1_.x += _loc2_.bitmap.x;
            _loc1_.y += _loc2_.bitmap.y;
         }
         _loc1_.x /= this.m_tileImages.length;
         _loc1_.y /= this.m_tileImages.length;
         return _loc1_;
      }
   }
}

