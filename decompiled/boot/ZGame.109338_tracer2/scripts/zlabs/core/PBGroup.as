package zlabs.core
{
   public class PBGroup extends PBObject
   {
      
      protected var items:Array = [];
      
      public function PBGroup()
      {
         super();
      }
      
      internal function addToGroup(param1:IPBObject) : Boolean
      {
         this.items.push(param1);
         return true;
      }
      
      internal function removeFromGroup(param1:IPBObject) : Boolean
      {
         var _loc2_:int = this.items.indexOf(param1);
         if(_loc2_ == -1)
         {
            return false;
         }
         this.items.splice(_loc2_,1);
         return true;
      }
      
      public function getItem(param1:int) : IPBObject
      {
         if(param1 < 0 || param1 >= this.items.length)
         {
            return null;
         }
         return this.items[param1];
      }
      
      public function get length() : int
      {
         return this.items.length;
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
         this.clear();
         super.destroy();
      }
   }
}

