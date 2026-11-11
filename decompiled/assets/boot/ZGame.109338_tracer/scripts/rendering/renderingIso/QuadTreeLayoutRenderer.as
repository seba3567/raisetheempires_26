package rendering.renderingIso
{
   import as3isolib.display.renderers.ISceneLayoutRenderer;
   import as3isolib.display.scene.IIsoScene;
   import flash.display.Sprite;
   import zlabs.utils.quadTree.QuadTreePositionItem;
   
   public class QuadTreeLayoutRenderer implements ISceneLayoutRenderer
   {
      
      private static var visibleObjectCount:Number;
      
      private var m_areaComponents:Array = null;
      
      private var doList:Array;
      
      private var itemList:Array;
      
      private var bSortAll:Boolean = false;
      
      private var cur:int;
      
      public function QuadTreeLayoutRenderer()
      {
         super();
         this.itemList = new Array();
         this.m_areaComponents = new Array();
      }
      
      public static function getVisibleObjectCount() : Number
      {
         return visibleObjectCount;
      }
      
      public function get collisionDetection() : Function
      {
         return null;
      }
      
      public function set collisionDetection(param1:Function) : void
      {
      }
      
      public function addAreaComponent(param1:QuadSpatialManager) : void
      {
         this.m_areaComponents.push(param1);
      }
      
      public function sortAllObjects(param1:IIsoScene) : void
      {
         this.bSortAll = true;
      }
      
      public function renderScene(param1:IIsoScene) : void
      {
         var _loc4_:QuadSpatialManager = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:Sprite = param1.container;
         var _loc3_:int = 0;
         loop0:
         for each(_loc4_ in this.m_areaComponents)
         {
            if(this.bSortAll)
            {
               this.doList = [];
               _loc4_.getAllItems(this.doList);
            }
            else
            {
               this.doList = _loc4_.getUnCulledItems();
            }
            this.quickSort(this.doList);
            _loc5_ = visibleObjectCount = this.doList.length;
            _loc6_ = 0;
            while(true)
            {
               if(_loc6_ >= _loc5_)
               {
                  _loc3_ += _loc5_;
                  this.doList = null;
                  continue loop0;
               }
               if(this.doList[_loc6_].parent == null)
               {
                  break;
               }
               this.cur = this.doList[_loc6_].isoSpriteIndex();
               if(_loc6_ + _loc3_ != this.cur)
               {
                  _loc2_.swapChildrenAt(_loc6_ + _loc3_,this.cur);
               }
               _loc6_++;
            }
            return;
         }
         if(this.bSortAll)
         {
            this.bSortAll = false;
            this.itemList.length = 0;
         }
      }
      
      public function dispose() : void
      {
         this.m_areaComponents = null;
         this.doList.length = 0;
         this.doList = null;
      }
      
      private function quickSort(param1:Array) : void
      {
         param1.sortOn("screenY",Array.NUMERIC);
      }
      
      private function insertionSort(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = 0;
         var _loc5_:QuadTreePositionItem = null;
         var _loc4_:int = int(param1.length);
         _loc2_ = 1;
         while(_loc2_ < _loc4_)
         {
            _loc5_ = param1[_loc2_];
            _loc3_ = int(_loc2_ - 1);
            while(_loc3_ >= 0 && _loc5_.length < param1[_loc3_].length)
            {
               param1[_loc3_ + 1] = param1[_loc3_];
               _loc3_--;
            }
            param1[_loc3_ + 1] = _loc5_;
            _loc2_++;
         }
      }
   }
}

