package transactions
{
   import displays.popups.GenericPopup;
   import entity.GameDataComponent;
   import transactions.utils.ZGameTransactionUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.PopupManager;
   
   public class TWorldState extends TZGameTransaction
   {
      
      protected var m_save:Object = null;
      
      protected var m_entity:IEntity = null;
      
      public function TWorldState(param1:IEntity)
      {
         var _loc2_:GameDataComponent = null;
         super();
         this.m_entity = param1;
         if(this.m_entity)
         {
            _loc2_ = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
            this.m_save = _loc2_.getSaveObject();
         }
      }
      
      public function get entity() : IEntity
      {
         return this.m_entity;
      }
      
      public function get itemName() : String
      {
         return this.m_save.itemName;
      }
      
      public function get state() : int
      {
         return this.m_save.state;
      }
      
      override public function perform() : void
      {
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:GameDataComponent = null;
         if(Config.DEBUG_MODE)
         {
            _loc2_ = GameDataComponent.getGameDataComponent(this.m_entity);
            if(null != _loc2_ && _loc2_.id != param1.id)
            {
               PopupManager.instance.push(new GenericPopup("Object ID out of sync client:" + _loc2_.id + " server:" + param1.id));
            }
         }
      }
      
      protected function signedWorldAction(param1:String, ... rest) : void
      {
         this.addChecksumToParams(rest);
         signedCall("WorldService.performAction",param1,modifiedData(this.m_save),rest);
         m_functionName = "WorldService.performAction:" + param1;
      }
      
      private function addChecksumToParams(param1:Array) : void
      {
         var _loc2_:int = int(param1.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(null != param1[_loc3_])
            {
               param1[_loc3_].ch = ZGameTransactionUtils.getCheckSum(param1[_loc3_]);
            }
            _loc3_++;
         }
      }
   }
}

