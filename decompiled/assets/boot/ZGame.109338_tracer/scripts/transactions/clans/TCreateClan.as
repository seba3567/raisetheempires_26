package transactions.clans
{
   import Engine.Transactions.Transaction;
   import core.managers.AlliancesManager;
   import core.ui.UIManager;
   import core.ui.menuitem.FriendsBarUIItem;
   
   public class TCreateClan extends Transaction
   {
      
      private var m_clanName:String;
      
      private var m_crestId:int;
      
      public function TCreateClan(param1:String, param2:int)
      {
         super();
         this.m_clanName = param1;
         this.m_crestId = param2;
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.createClan",this.m_clanName,this.m_crestId);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:FriendsBarUIItem = null;
         if(param1 != null)
         {
            AlliancesManager.instance.init(param1);
            _loc2_ = UIManager.instance.getMenuItemByName(FriendsBarUIItem.ITEM_ID) as FriendsBarUIItem;
            if(_loc2_)
            {
               _loc2_.showAllianceUI();
            }
         }
      }
   }
}

