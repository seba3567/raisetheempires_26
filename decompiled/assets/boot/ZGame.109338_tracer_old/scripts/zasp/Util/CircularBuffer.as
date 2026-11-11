package zasp.Util
{
   public class CircularBuffer
   {
      
      private var arr:Array = null;
      
      private var ins:int = 0;
      
      private var num:int = 0;
      
      public function CircularBuffer(param1:int)
      {
         super();
         this.arr = new Array(param1);
         this.ins = 0;
         this.num = 0;
      }
      
      public static function test() : void
      {
         var len:int;
         var happy:Boolean = true;
         var buf:CircularBuffer = null;
         var str1:String = "string1";
         var str2:String = "string2";
         var pop1:Object = null;
         var pop2:Object = null;
         buf = new CircularBuffer(0);
         if(0 != buf.capacity)
         {
            throw new Error("a1");
         }
         if(0 != buf.length)
         {
            throw new Error("b1");
         }
         try
         {
            buf.push(10);
            happy = false;
         }
         catch(expected:Error)
         {
         }
         if(!happy)
         {
            throw new Error("c1");
         }
         try
         {
            buf.pop();
            happy = false;
         }
         catch(expected:Error)
         {
         }
         if(!happy)
         {
            throw new Error("d1");
         }
         buf = new CircularBuffer(1);
         if(1 != buf.capacity)
         {
            throw new Error("a2");
         }
         if(0 != buf.length)
         {
            throw new Error("b2");
         }
         buf.push(str1);
         try
         {
            buf.push(10);
            happy = false;
         }
         catch(expected:Error)
         {
         }
         if(!happy)
         {
            throw new Error("c2");
         }
         pop1 = buf.pop();
         if(str1 != pop1)
         {
            throw new Error("d2");
         }
         try
         {
            buf.pop();
            happy = false;
         }
         catch(expected:Error)
         {
         }
         if(!happy)
         {
            throw new Error("e2");
         }
         buf = new CircularBuffer(2);
         if(2 != buf.capacity)
         {
            throw new Error("a3");
         }
         if(0 != buf.length)
         {
            throw new Error("b3");
         }
         buf.push(str1);
         pop1 = buf.pop();
         if(str1 != pop1)
         {
            throw new Error("c3");
         }
         buf.push(str2);
         pop2 = buf.pop();
         if(str2 != pop2)
         {
            throw new Error("d3");
         }
         buf.push(str1);
         buf.push(str2);
         try
         {
            buf.push(3);
            happy = false;
         }
         catch(expected:Error)
         {
         }
         if(!happy)
         {
            throw new Error("e3");
         }
         pop1 = buf.pop();
         pop2 = buf.pop();
         if(str1 != pop1)
         {
            throw new Error("f3");
         }
         if(str2 != pop2)
         {
            throw new Error("g3");
         }
         try
         {
            buf.pop();
            happy = false;
         }
         catch(expected:Error)
         {
         }
         if(!happy)
         {
            throw new Error("h3");
         }
         buf = new CircularBuffer(2);
         if(2 != buf.capacity)
         {
            throw new Error("a4");
         }
         if(0 != buf.length)
         {
            throw new Error("b4");
         }
         buf.push(str1);
         pop1 = buf.pop();
         if(str1 != pop1)
         {
            throw new Error("c4");
         }
         buf.push(str2);
         pop2 = buf.pop();
         if(str2 != pop2)
         {
            throw new Error("d4");
         }
         buf.push(str1);
         buf.push(str2);
         try
         {
            buf.push(3);
            happy = false;
         }
         catch(expected:Error)
         {
         }
         if(!happy)
         {
            throw new Error("e4");
         }
         len = buf.length;
         buf.capacity = 1 + buf.capacity;
         if(buf.length != len)
         {
            throw new Error("len4.1");
         }
         buf.push(3);
         if(str1 != buf.pop())
         {
            throw new Error("f4.a");
         }
         if(str2 != buf.pop())
         {
            throw new Error("f4.b");
         }
         if(3 != buf.pop())
         {
            throw new Error("f4.c");
         }
         buf.push(1);
         buf.push(2);
         try
         {
            buf.capacity = 1;
            happy = false;
         }
         catch(expected:Error)
         {
         }
         if(!happy)
         {
            throw new Error("g4");
         }
      }
      
      public function get capacity() : int
      {
         return this.arr.length;
      }
      
      public function set capacity(param1:int) : void
      {
         var _loc2_:CircularBuffer = new CircularBuffer(param1);
         while(this.length > 0)
         {
            _loc2_.push(this.pop());
         }
         this.arr = _loc2_.arr;
         this.ins = _loc2_.ins;
         this.num = _loc2_.num;
      }
      
      public function get length() : int
      {
         return this.num;
      }
      
      public function push(param1:Object) : void
      {
         if(this.num >= this.arr.length)
         {
            throw new Error("overflow");
         }
         this.arr[this.ins] = param1;
         this.num += 1;
         this.ins = (this.ins + 1) % this.arr.length;
      }
      
      public function pop() : Object
      {
         if(this.num <= 0)
         {
            throw new Error("underflow");
         }
         var _loc1_:int = (this.arr.length + this.ins - this.num) % this.arr.length;
         var _loc2_:Object = this.arr[_loc1_];
         this.arr[_loc1_] = 0;
         --this.num;
         return _loc2_;
      }
      
      public function elementAt(param1:int) : Object
      {
         if(param1 < 0 || param1 >= this.num)
         {
            throw new Error("out of range");
         }
         var _loc2_:int = (this.arr.length + this.ins - this.num + param1) % this.arr.length;
         return this.arr[_loc2_];
      }
   }
}

