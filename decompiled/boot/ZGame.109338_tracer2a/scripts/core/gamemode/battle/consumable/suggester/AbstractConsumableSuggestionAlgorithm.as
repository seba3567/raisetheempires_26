package core.gamemode.battle.consumable.suggester
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   
   public class AbstractConsumableSuggestionAlgorithm implements IConsumableSuggestion
   {
      
      public static const NO_CONSUMABLE_SUGGESTABLE:String = "noConsumableSuggestable";
      
      protected var m_playerFleet:Fleet;
      
      protected var m_enemyFleet:Fleet;
      
      protected var m_forceIfSuggested:Boolean;
      
      protected var m_weight:Number = NaN;
      
      protected var m_algorithmName:String = "error";
      
      protected var m_consumableCode:String = "error";
      
      protected var m_consumableMessage:String = "error";
      
      public function AbstractConsumableSuggestionAlgorithm(param1:Boolean)
      {
         super();
         this.m_forceIfSuggested = param1;
      }
      
      public function get algorithmName() : String
      {
         throw Error(" get algorithmName MUST be overridden ");
      }
      
      public function get weight() : Number
      {
         return this.m_weight;
      }
      
      public function set playerFleet(param1:Fleet) : void
      {
         this.m_playerFleet = param1;
      }
      
      public function set enemyFleet(param1:Fleet) : void
      {
         this.m_enemyFleet = param1;
      }
      
      public function get consumableCode() : String
      {
         var _loc3_:ConsumableItem = null;
         var _loc4_:ConsumableItem = null;
         var _loc5_:String = null;
         var _loc1_:String = NO_CONSUMABLE_SUGGESTABLE;
         var _loc2_:Array = this.m_consumableCode.split(",");
         for each(_loc5_ in _loc2_)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc5_,ConsumableItem) as ConsumableItem;
            if(_loc3_ != null)
            {
               if((_loc4_ == null || _loc3_.requiredLevel > _loc4_.requiredLevel) && _loc3_.requiredLevel <= ZGlobal.player.level)
               {
                  _loc4_ = _loc3_;
                  _loc1_ = _loc4_.code;
               }
            }
         }
         return _loc1_;
      }
      
      public function get consumableMessage() : String
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc1_:String = NO_CONSUMABLE_SUGGESTABLE;
         var _loc2_:Array = this.m_consumableMessage.split(",");
         if(_loc2_.length > 1)
         {
            _loc3_ = this.m_consumableCode.split(",");
            _loc4_ = _loc3_.indexOf(this.consumableCode);
            if(_loc4_ >= _loc2_.length)
            {
               throw Error("There is no consumable messages suggestion for: " + this.consumableCode);
            }
            _loc1_ = _loc2_[_loc4_];
         }
         else
         {
            _loc1_ = this.m_consumableMessage;
         }
         return _loc1_;
      }
      
      public function get forceIfSuggested() : Boolean
      {
         return this.m_forceIfSuggested;
      }
      
      public function calculateSuggestionWeight() : void
      {
         throw Error("Abstract. Do not use. Must Override calculateSuggestionWeight. No Super Calls");
      }
      
      public function dispose() : void
      {
      }
      
      protected function cycleThroughAttributesAndSetMemberVars(param1:XML) : void
      {
         var attr:XML = null;
         var p_suggestionData:XML = param1;
         if(p_suggestionData == null)
         {
            throw Error("Suggestion Data XML is null");
         }
         for each(attr in p_suggestionData.@*)
         {
            try
            {
               this.setMemberVar("m_" + attr.name().toString(),attr.toString());
            }
            catch(e:Error)
            {
               throw Error("XML Attribute: m_" + attr.name() + " was not found. Maybe Typo?");
            }
         }
      }
      
      protected function setMemberVar(param1:String, param2:Object) : void
      {
         throw Error("Abstract. Do not use. Must Override setMemberVar. No Super Calls");
      }
   }
}

