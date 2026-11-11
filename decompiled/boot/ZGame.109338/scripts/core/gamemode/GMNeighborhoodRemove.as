package core.gamemode
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.PopulationManager;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import flash.events.MouseEvent;
   import transactions.TNeighborhoodRemove;
   import zlabs.entity.IEntity;
   
   public class GMNeighborhoodRemove extends GMObjectPlace
   {
      
      protected var m_entiry:IEntity;
      
      protected var m_block:int;
      
      public function GMNeighborhoodRemove(param1:String, param2:IEntity, param3:Object, param4:int)
      {
         m_object = param3;
         this.m_entiry = param2;
         this.m_block = param4;
         super(param1,MarketEvent.SOURCE_NONE,false,null,param3);
      }
      
      override public function onMouseUp(param1:MouseEvent) : Boolean
      {
         var _loc3_:GameDataComponent = null;
         var _loc4_:TNeighborhoodRemove = null;
         var _loc5_:GameItem = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:Boolean = super.onMouseUp(param1);
         if(m_objectPlacedSuccess)
         {
            _loc3_ = GameDataComponent(m_selectedObjectProxy.getMapResource().lookupComponentByType(GameDataComponent));
            _loc4_ = new TNeighborhoodRemove(this.m_entiry,_loc3_.getSaveObject(),this.m_block);
            TransactionManager.addTransaction(_loc4_,true);
            _loc5_ = ZGlobal.gameSettings.getItemByName(_loc3_.getSaveObject().itemName,GameItem) as GameItem;
            _loc6_ = _loc5_.workers;
            _loc7_ = _loc5_.workersCap;
            if(Boolean(_loc6_) && _loc6_.length > 0)
            {
               _loc8_ = parseInt(_loc6_);
            }
            if(Boolean(_loc7_) && _loc7_.length > 0)
            {
               _loc9_ = parseInt(_loc7_);
            }
            if(Boolean(_loc8_) || Boolean(_loc9_))
            {
               PopulationManager.instance.updateMaxWorkers(-_loc8_,-_loc9_);
            }
         }
         return _loc2_;
      }
   }
}

