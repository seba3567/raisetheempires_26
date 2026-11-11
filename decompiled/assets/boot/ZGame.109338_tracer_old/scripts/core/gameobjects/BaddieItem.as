package core.gameobjects
{
   import core.ZGlobal;
   
   public class BaddieItem extends GameItem
   {
      
      public function BaddieItem(param1:XML)
      {
         super(param1);
      }
      
      public function get fleetType() : String
      {
         var _loc1_:XML = null;
         var _loc2_:String = null;
         var _loc3_:GameItem = null;
         var _loc4_:int = 0;
         var _loc5_:* = m_xml.baddie;
         for each(_loc1_ in _loc5_)
         {
            _loc2_ = _loc1_.attribute("item");
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
            return _loc3_.subType;
         }
         return UnitItem.NAVY;
      }
      
      public function addUnitsToFleet(param1:Fleet, param2:Array) : void
      {
         var _loc3_:Object = null;
         for each(_loc3_ in param2)
         {
            param1.addUnit(_loc3_.code);
         }
      }
      
      public function get items() : Array
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Number = NaN;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in m_xml.baddie)
         {
            _loc3_ = 100;
            _loc4_ = _loc2_.attribute("item");
            _loc5_ = _loc2_.attribute("position");
            _loc6_ = 1;
            _loc7_ = _loc2_.attribute("health");
            if(_loc7_.length > 0)
            {
               _loc3_ = parseInt(_loc7_);
            }
            _loc8_ = _loc2_.attribute("strengthMult");
            if(_loc8_.length > 0)
            {
               _loc6_ = parseFloat(_loc8_);
               _loc6_ = Math.max(0,_loc6_);
            }
            _loc1_.push({
               "code":_loc4_,
               "position":_loc5_,
               "health":_loc3_,
               "strengthMult":_loc6_
            });
         }
         return _loc1_;
      }
   }
}

