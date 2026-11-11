package as3isolib.display.renderers
{
   import as3isolib.core.IsoDisplayObject;
   import as3isolib.core.as3isolib_internal;
   import as3isolib.display.scene.IIsoScene;
   import flash.utils.Dictionary;
   
   use namespace as3isolib_internal;
   
   public class DefaultSceneLayoutRenderer implements ISceneLayoutRenderer
   {
      
      private var depth:uint;
      
      private var visited:Dictionary = new Dictionary();
      
      private var scene:IIsoScene;
      
      private var dependency:Dictionary;
      
      private var collisionDetectionFunc:Function = null;
      
      public function DefaultSceneLayoutRenderer()
      {
         super();
      }
      
      public function renderScene(param1:IIsoScene) : void
      {
         var _loc7_:IsoDisplayObject = null;
         var _loc8_:IsoDisplayObject = null;
         var _loc9_:Array = null;
         var _loc10_:IsoDisplayObject = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:uint = 0;
         var _loc20_:uint = 0;
         this.scene = param1;
         this.dependency = new Dictionary();
         var _loc2_:Array = param1.displayListChildren;
         var _loc3_:uint = _loc2_.length;
         var _loc4_:Array = [];
         var _loc5_:uint = 0;
         while(_loc5_ < _loc3_)
         {
            _loc8_ = _loc2_[_loc5_];
            _loc4_.push(_loc8_.x);
            _loc4_.push(_loc8_.y);
            _loc4_.push(_loc8_.z);
            _loc4_.push(_loc8_.width);
            _loc4_.push(_loc8_.length);
            _loc4_.push(_loc8_.height);
            _loc5_++;
         }
         var _loc6_:uint = 0;
         while(_loc6_ < _loc3_)
         {
            _loc9_ = [];
            _loc10_ = _loc2_[_loc6_];
            _loc11_ = _loc10_.x;
            _loc12_ = _loc10_.y;
            _loc13_ = _loc10_.width;
            _loc14_ = _loc10_.length;
            _loc15_ = _loc10_.height;
            _loc16_ = _loc11_ + _loc13_;
            _loc17_ = _loc12_ + _loc14_;
            _loc18_ = _loc10_.z + _loc15_;
            _loc19_ = 0;
            _loc20_ = 0;
            while(_loc20_ < _loc3_)
            {
               if(_loc6_ != _loc20_)
               {
                  if(this.collisionDetectionFunc != null)
                  {
                     this.collisionDetectionFunc.call(null,_loc10_,_loc2_[_loc20_]);
                  }
                  if(_loc11_ == _loc4_[_loc19_] && _loc12_ == _loc4_[_loc19_ + 1] && _loc13_ == _loc4_[_loc19_ + 3] && _loc14_ == _loc4_[_loc19_ + 4] && _loc4_[_loc19_ + 5] > 0)
                  {
                     if(_loc15_ > _loc4_[_loc19_ + 5])
                     {
                        _loc9_.push(_loc2_[_loc20_]);
                     }
                  }
                  else if(_loc4_[_loc19_] < _loc16_ && _loc4_[_loc19_ + 1] < _loc17_ && _loc4_[_loc19_ + 2] < _loc18_)
                  {
                     _loc9_.push(_loc2_[_loc20_]);
                  }
               }
               _loc20_++;
               _loc19_ += 6;
            }
            this.dependency[_loc10_] = _loc9_;
            _loc6_++;
         }
         this.depth = 0;
         for each(_loc7_ in _loc2_)
         {
            if(true !== this.visited[_loc7_])
            {
               this.place(_loc7_);
            }
         }
         this.visited = new Dictionary();
      }
      
      private function place(param1:IsoDisplayObject) : void
      {
         var _loc2_:IsoDisplayObject = null;
         this.visited[param1] = true;
         for each(_loc2_ in this.dependency[param1])
         {
            if(true !== this.visited[_loc2_])
            {
               this.place(_loc2_);
            }
         }
         if(this.depth != param1.depth)
         {
            this.scene.setChildIndex(param1,this.depth);
         }
         ++this.depth;
      }
      
      public function get collisionDetection() : Function
      {
         return this.collisionDetectionFunc;
      }
      
      public function set collisionDetection(param1:Function) : void
      {
         this.collisionDetectionFunc = param1;
      }
   }
}

