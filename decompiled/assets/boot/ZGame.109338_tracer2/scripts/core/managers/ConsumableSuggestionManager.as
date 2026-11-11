package core.managers
{
   import core.ZGlobal;
   
   public class ConsumableSuggestionManager
   {
      
      public static var instance:ConsumableSuggestionManager = new ConsumableSuggestionManager();
      
      private var m_data:Object = null;
      
      public function ConsumableSuggestionManager()
      {
         super();
      }
      
      public function init() : void
      {
         var consumableSuggestions:XMLList;
         var consumableSuggestion:XML = null;
         var i:int = 0;
         this.m_data = {};
         consumableSuggestions = (ZGlobal.gameSettings.getXML().consumablesuggestions[0] as XML).children();
         i = 0;
         while(i < consumableSuggestions.length())
         {
            consumableSuggestion = consumableSuggestions[i];
            if(consumableSuggestion.@name != undefined && !this.m_data.hasOwnProperty(consumableSuggestion.@name.toString()))
            {
               if("@experiment" in consumableSuggestion)
               {
                  this.m_data[consumableSuggestion.@name.toString()] = consumableSuggestion..variant.(@value == ExperimentsManager.instance.getExperimentVariant(consumableSuggestion.@experiment))[0]..suggestiondata[0];
               }
               else
               {
                  this.m_data[consumableSuggestion.@name.toString()] = consumableSuggestion..variant.(@value == "0")[0]..suggestiondata[0];
               }
            }
            i++;
         }
      }
      
      public function getConsumableSuggestionExperimentVariant(param1:String) : Number
      {
         return ExperimentsManager.instance.getExperimentVariant(param1);
      }
      
      public function getConsumableSuggestionDataXML(param1:String) : XML
      {
         var _loc2_:XML = null;
         if(this.m_data == null)
         {
            this.init();
         }
         if(this.m_data != null && this.m_data.hasOwnProperty(param1))
         {
            _loc2_ = this.m_data[param1] as XML;
         }
         return _loc2_;
      }
   }
}

