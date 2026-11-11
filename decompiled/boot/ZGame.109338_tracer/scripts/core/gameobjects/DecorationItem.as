package core.gameobjects
{
   import core.managers.decorationsManager.DecorationsManager;
   
   public class DecorationItem extends GameItem
   {
      
      private var m_decorationXML:XML;
      
      public function DecorationItem(param1:XML)
      {
         super(param1);
         this.m_decorationXML = m_xml.decoration[0];
      }
      
      public function get aoe() : int
      {
         return this.m_decorationXML.@aoe;
      }
      
      public function doesAffect(param1:Array) : Boolean
      {
         var _loc2_:Array = this.getEffectsData(param1);
         return _loc2_.length > 0;
      }
      
      public function get effectsXML() : XMLList
      {
         return this.m_decorationXML.effect;
      }
      
      public function get effectStrings() : Array
      {
         var _loc2_:XML = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this.m_decorationXML.effect)
         {
            if(_loc2_.@effect != undefined)
            {
               _loc1_.push(_loc2_.@effect.toString());
            }
         }
         return _loc1_;
      }
      
      public function getEffectsData(param1:Array) : Array
      {
         var _loc3_:XML = null;
         var _loc2_:Array = [];
         for each(_loc3_ in this.m_decorationXML.effect)
         {
            if(param1.indexOf(_loc3_.@target.toString()) > -1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function get effectFeedbackType() : int
      {
         if(this.m_decorationXML.effect.length() > 1 || this.code == "DB08")
         {
            return DecorationsManager.EFFECT_FEEDBACK_PREMIUM;
         }
         var _loc1_:String = this.m_decorationXML.effect[0].@effect.toString();
         switch(_loc1_)
         {
            case "referenceItemCost":
               return DecorationsManager.EFFECT_FEEDBACK_REFERENCEITEM_COST;
            case "contractYield":
               return DecorationsManager.EFFECT_FEEDBACK_CONTRACT_YIELD;
            case "crewTendBuff":
               return DecorationsManager.EFFECT_FEEDBACK_CREW_HARVEST_BUFF;
            case "maturationYield":
               return DecorationsManager.EFFECT_FEEDBACK_MATURING_YIELD;
            default:
               return DecorationsManager.EFFECT_FEEDBACK_MATURING_YIELD;
         }
      }
   }
}

