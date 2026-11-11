package transactions
{
   import Engine.Transactions.Transaction;
   import core.gameobjects.GameItem;
   import entity.GameDataComponent;
   import zlabs.entity.IEntity;
   
   public class TVisitorHelp extends Transaction
   {
      
      private var m_neighborID:String = "";
      
      private var m_objID:int = 0;
      
      private var m_visitorHelpType:String;
      
      private var m_owner:IEntity;
      
      private var m_referenceItem:String;
      
      public function TVisitorHelp(param1:String, param2:int, param3:String, param4:IEntity, param5:String)
      {
         super();
         this.m_neighborID = param1;
         this.m_objID = param2;
         this.m_visitorHelpType = param3;
         this.m_owner = param4;
         this.m_referenceItem = param5;
      }
      
      public function get visitorHelpType() : String
      {
         return this.m_visitorHelpType;
      }
      
      public function get owner() : IEntity
      {
         return this.m_owner;
      }
      
      public function get gameItem() : GameItem
      {
         var _loc1_:GameDataComponent = GameDataComponent.getGameDataComponent(this.m_owner);
         if(_loc1_)
         {
            return _loc1_.gameData;
         }
         return null;
      }
      
      public function get referenceItem() : String
      {
         return this.m_referenceItem;
      }
      
      override public function perform() : void
      {
         signedCall("VisitorService.help",this.m_neighborID,this.m_objID,this.m_visitorHelpType);
      }
   }
}

