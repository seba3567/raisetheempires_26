package transactions
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import entity.GameDataComponent;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class TDecorationPlace extends TWorldState
   {
      
      private var m_params:Object = new Object();
      
      private var m_code:String = null;
      
      public function TDecorationPlace(param1:IEntity, param2:Boolean = false, param3:int = 0, param4:Object = null)
      {
         this.m_params.isGift = param2;
         this.m_params.isStorageWithdrawal = param3;
         this.m_params.isInventoryWithdrawal = 0;
         if(param4)
         {
            this.m_params.statsInfo = param4;
         }
         var _loc5_:GameDataComponent = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
         this.m_code = _loc5_.gameData.code;
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("place",this.m_params);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_PLACED,this.m_code));
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(this.m_code,GameItem) as GameItem;
         if(_loc2_.isResourceOrder())
         {
            TransactionManager.addTransaction(new TSuperOre());
         }
      }
   }
}

