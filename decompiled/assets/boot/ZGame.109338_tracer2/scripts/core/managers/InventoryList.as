package core.managers
{
   public class InventoryList implements ItemListInterface
   {
      
      public static var instance:InventoryList = new InventoryList();
      
      private var m_items:Array;
      
      private var m_itemsByEffectiveness:Array;
      
      public function InventoryList()
      {
         super();
         this.m_items = new Array();
         this.m_itemsByEffectiveness = new Array();
      }
      
      public function get items() : Array
      {
         return this.m_items;
      }
      
      public function get itemsByEffectiveness() : Array
      {
         return this.m_itemsByEffectiveness;
      }
      
      public function addItems(param1:XMLList) : void
      {
         var _loc5_:String = null;
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         var _loc4_:XML = null;
         for each(_loc4_ in param1)
         {
            if(_loc4_.@storable != "false")
            {
               _loc5_ = _loc4_.@code.toString();
               this.m_items.push(_loc5_);
               if(_loc4_.unit != undefined)
               {
                  _loc3_.push(_loc4_);
               }
               else
               {
                  _loc2_.push(_loc5_);
               }
            }
         }
         _loc3_.sort(this.compareUnitItem);
         for each(_loc4_ in _loc3_)
         {
            this.m_itemsByEffectiveness.push(_loc4_.@code.toString());
         }
         this.m_itemsByEffectiveness = this.m_itemsByEffectiveness.concat(_loc2_);
      }
      
      private function compareUnitItem(param1:XML, param2:XML) : int
      {
         var _loc3_:int = int(param1.unit.@strength);
         var _loc4_:int = int(param2.unit.@strength);
         if(_loc3_ > _loc4_)
         {
            return 1;
         }
         if(_loc3_ < _loc4_)
         {
            return -1;
         }
         return 0;
      }
   }
}

