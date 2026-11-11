package zlabs.core
{
   public class PBSet extends PBObject
   {
      
      protected var items:Array = [];
      
      public function PBSet()
      {
         super();
      }
      
      public function getItem(param1:int) : PBObject
      {
         if(this.items == null)
         {
            return null;
         }
         if(param1 < 0 || param1 >= this.items.length)
         {
            return null;
         }
         return this.items[param1];
      }
      
      public function get length() : int
      {
         return this.items ? int(this.items.length) : 0;
      }
      
      public function contains(param1:PBObject) : Boolean
      {
         if(this.items == null)
         {
            throw new Error("Accessing destroy()\'ed set.");
         }
         return this.items.indexOf(param1) != -1;
      }
      
      public function add(param1:PBObject) : Boolean
      {
         if(param1 == this)
         {
            return false;
         }
         if(this.items == null)
         {
            throw new Error("Accessing destroy()\'ed set.");
         }
         if(this.contains(param1))
         {
            return false;
         }
         param1.noteInSet(this);
         this.items.push(param1);
         return true;
      }
      
      public function remove(param1:PBObject) : Boolean
      {
         if(param1 == this)
         {
            return false;
         }
         if(this.items == null)
         {
            param1.noteOutOfSet(this);
            return true;
         }
         var _loc2_:int = this.items.indexOf(param1);
         if(_loc2_ == -1)
         {
            return false;
         }
         param1.noteOutOfSet(this);
         this.items.splice(_loc2_,1);
         return true;
      }
      
      public function clear() : void
      {
         while(this.items.length)
         {
            (this.items.pop() as PBObject).destroy();
         }
      }
      
      override public function destroy() : void
      {
         if(this.items == null)
         {
            throw new Error("Accessing destroy()\'ed set.");
         }
         super.destroy();
         while(this.items.length)
         {
            this.remove(this.items.pop() as PBObject);
         }
         this.items = null;
      }
   }
}

