package core.managers.resourceContractOverridesManager
{
   import flash.utils.Dictionary;
   import utils.CriteriaUtil;
   
   public class ResourceContractOverridesManager
   {
      
      public static var instance:ResourceContractOverridesManager = new ResourceContractOverridesManager();
      
      private var m_overrideXML:XMLList = null;
      
      private var m_overrides:Dictionary = null;
      
      public function ResourceContractOverridesManager()
      {
         super();
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         this.m_overrideXML = param1;
      }
      
      public function getOverride(param1:String) : String
      {
         if(this.m_overrides == null)
         {
            this.cacheOverrides();
         }
         return this.m_overrides[param1];
      }
      
      private function cacheOverrides() : void
      {
         var _loc1_:XML = null;
         this.m_overrides = new Dictionary();
         for each(_loc1_ in this.m_overrideXML)
         {
            if(CriteriaUtil.meetsCriteria(_loc1_.criteria))
            {
               this.m_overrides[_loc1_.@code.toString()] = _loc1_.@override.toString();
            }
         }
      }
   }
}

