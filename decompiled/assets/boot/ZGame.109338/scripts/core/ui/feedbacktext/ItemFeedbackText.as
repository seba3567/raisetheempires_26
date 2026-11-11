package core.ui.feedbacktext
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   
   public class ItemFeedbackText extends QuantifiedFeedbackText
   {
      
      private var m_code:String = null;
      
      public function ItemFeedbackText(param1:String, param2:int)
      {
         super(param2);
         this.m_code = param1;
      }
      
      override public function get friendlyName() : String
      {
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(this.m_code,GameItem) as GameItem;
         return amount + " " + _loc1_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME);
      }
   }
}

