package core.player
{
   import core.managers.WorldResourceManager;
   import core.resource.ResourceInfo;
   import dispatchers.EnergyDispatcher;
   import dispatchers.ResourceDispatcher;
   import events.EnergyUpdatedEvent;
   import events.ResourceUpdatedEvent;
   import flash.utils.Dictionary;
   
   public class PlayerResources
   {
      
      private var m_resourceAmountsMap:Dictionary = new Dictionary();
      
      private var m_cappingFuncs:Dictionary = null;
      
      public function PlayerResources()
      {
         super();
      }
      
      public function init(param1:Object) : void
      {
         var _loc2_:ResourceInfo = null;
         var _loc3_:String = null;
         this.m_cappingFuncs = new Dictionary();
         for each(_loc2_ in WorldResourceManager.instance.resourceInfo)
         {
            this.m_resourceAmountsMap[_loc2_.type] = 0;
         }
         for(_loc3_ in param1)
         {
            if(_loc3_ != "energy")
            {
               this.updateResourceAmount(_loc3_,param1[_loc3_]);
            }
         }
         EnergyDispatcher.instance.addEventListener(EnergyUpdatedEvent.ENERGY,this.updateEnergy);
      }
      
      protected function updateEnergy(param1:EnergyUpdatedEvent) : void
      {
         if(this.resourceAmounts["energy"] != param1.newAmount)
         {
            this.updateResourceAmount("energy",param1.newAmount - param1.oldAmount);
         }
      }
      
      public function get resourceAmounts() : Dictionary
      {
         return this.m_resourceAmountsMap;
      }
      
      public function set resourceAmounts(param1:Dictionary) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            this.setResourceAmount(_loc2_,param1[_loc2_]);
         }
      }
      
      public function checkResourceAmount(param1:String, param2:int) : Boolean
      {
         if(this.m_resourceAmountsMap[param1] + param2 < 0)
         {
            return false;
         }
         return true;
      }
      
      public function updateResourceAmount(param1:String, param2:int) : void
      {
         if(!this.checkResourceAmount(param1,param2))
         {
            return;
         }
         var _loc3_:int = int(this.m_resourceAmountsMap[param1]);
         var _loc4_:int = this.cap(param1,_loc3_ + param2);
         param2 = _loc4_ - _loc3_;
         this.m_resourceAmountsMap[param1] += param2;
         ResourceDispatcher.instance.dispatchEvent(new ResourceUpdatedEvent(param1,_loc3_,_loc4_));
      }
      
      public function setResourceAmount(param1:String, param2:int) : void
      {
         param2 = this.cap(param1,param2);
         var _loc3_:int = int(this.m_resourceAmountsMap[param1]);
         ResourceDispatcher.instance.dispatchEvent(new ResourceUpdatedEvent(param1,_loc3_,param2));
         this.m_resourceAmountsMap[param1] = param2;
      }
      
      private function cap(param1:String, param2:int) : int
      {
         if(null != this.m_cappingFuncs[param1])
         {
            param2 = int(this.m_cappingFuncs[param1](param2));
         }
         return param2;
      }
   }
}

