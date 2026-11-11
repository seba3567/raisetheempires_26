package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TQuestMarkStarred extends Transaction
   {
      
      private var m_quest:String = "";
      
      private var m_doFav:Boolean = false;
      
      public function TQuestMarkStarred(param1:String, param2:Boolean)
      {
         this.m_doFav = param2;
         this.m_quest = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.doFavQuest",this.m_quest,this.m_doFav);
      }
   }
}

