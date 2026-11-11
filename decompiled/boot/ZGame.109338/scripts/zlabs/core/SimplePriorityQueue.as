package zlabs.core
{
   import flash.utils.Dictionary;
   
   public class SimplePriorityQueue
   {
      
      private var _heap:Array;
      
      private var _size:int;
      
      private var _count:int;
      
      private var _posLookup:Dictionary;
      
      public function SimplePriorityQueue(param1:int)
      {
         super();
         this._heap = new Array(this._size = param1 + 1);
         this._posLookup = new Dictionary(true);
         this._count = 0;
      }
      
      public function get front() : IPrioritizable
      {
         return this._heap[1];
      }
      
      public function get maxSize() : int
      {
         return this._size;
      }
      
      public function enqueue(param1:IPrioritizable) : Boolean
      {
         if(this._count + 1 < this._size)
         {
            ++this._count;
            this._heap[this._count] = param1;
            this._posLookup[param1] = this._count;
            this.walkUp(this._count);
            return true;
         }
         return false;
      }
      
      public function dequeue() : IPrioritizable
      {
         var _loc1_:* = undefined;
         if(this._count >= 1)
         {
            _loc1_ = this._heap[1];
            delete this._posLookup[_loc1_];
            this._heap[1] = this._heap[this._count];
            this.walkDown(1);
            delete this._heap[this._count];
            --this._count;
            return _loc1_;
         }
         return null;
      }
      
      public function reprioritize(param1:IPrioritizable, param2:int) : Boolean
      {
         if(!this._posLookup[param1])
         {
            return false;
         }
         var _loc3_:int = param1.priority;
         param1.priority = param2;
         var _loc4_:int = int(this._posLookup[param1]);
         if(param2 > _loc3_)
         {
            this.walkUp(_loc4_);
         }
         else
         {
            this.walkDown(_loc4_);
         }
         return true;
      }
      
      public function remove(param1:IPrioritizable) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:* = undefined;
         if(this._count >= 1)
         {
            _loc2_ = int(this._posLookup[param1]);
            _loc3_ = this._heap[_loc2_];
            delete this._posLookup[_loc3_];
            this._heap[_loc2_] = this._heap[this._count];
            this.walkDown(_loc2_);
            delete this._heap[this._count];
            delete this._posLookup[this._count];
            --this._count;
            return true;
         }
         return false;
      }
      
      public function contains(param1:*) : Boolean
      {
         var _loc2_:int = 1;
         while(_loc2_ <= this._count)
         {
            if(this._heap[_loc2_] === param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function clear() : void
      {
         this._heap = new Array(this._size);
         this._posLookup = new Dictionary(true);
         this._count = 0;
      }
      
      public function get size() : int
      {
         return this._count;
      }
      
      public function isEmpty() : Boolean
      {
         return this._count == 0;
      }
      
      public function toArray() : Array
      {
         return this._heap.slice(1,this._count + 1);
      }
      
      public function toString() : String
      {
         return "[SimplePriorityQueue, size=" + this._size + "]";
      }
      
      public function dump() : String
      {
         if(this._count == 0)
         {
            return "SimplePriorityQueue (empty)";
         }
         var _loc1_:String = "SimplePriorityQueue\n{\n";
         var _loc2_:int = this._count + 1;
         var _loc3_:int = 1;
         while(_loc3_ < _loc2_)
         {
            _loc1_ += "\t" + this._heap[_loc3_] + "\n";
            _loc3_++;
         }
         return _loc1_ + "\n}";
      }
      
      private function walkUp(param1:int) : void
      {
         var _loc3_:IPrioritizable = null;
         var _loc2_:int = param1 >> 1;
         var _loc4_:IPrioritizable = this._heap[param1];
         var _loc5_:int = _loc4_.priority;
         while(_loc2_ > 0)
         {
            _loc3_ = this._heap[_loc2_];
            if(_loc5_ - _loc3_.priority <= 0)
            {
               break;
            }
            this._heap[param1] = _loc3_;
            this._posLookup[_loc3_] = param1;
            param1 = _loc2_;
            _loc2_ >>= 1;
         }
         this._heap[param1] = _loc4_;
         this._posLookup[_loc4_] = param1;
      }
      
      private function walkDown(param1:int) : void
      {
         var _loc3_:IPrioritizable = null;
         var _loc2_:int = param1 << 1;
         var _loc4_:IPrioritizable = this._heap[param1];
         var _loc5_:int = _loc4_.priority;
         while(_loc2_ < this._count)
         {
            if(_loc2_ < this._count - 1)
            {
               if(this._heap[_loc2_].priority - this._heap[int(_loc2_ + 1)].priority < 0)
               {
                  _loc2_++;
               }
            }
            _loc3_ = this._heap[_loc2_];
            if(_loc5_ - _loc3_.priority >= 0)
            {
               break;
            }
            this._heap[param1] = _loc3_;
            this._posLookup[_loc3_] = param1;
            this._posLookup[_loc4_] = _loc2_;
            param1 = _loc2_;
            _loc2_ <<= 1;
         }
         this._heap[param1] = _loc4_;
         this._posLookup[_loc4_] = param1;
      }
   }
}

