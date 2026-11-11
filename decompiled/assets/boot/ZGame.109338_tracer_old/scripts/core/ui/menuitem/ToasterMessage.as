package core.ui.menuitem
{
   public class ToasterMessage
   {
      
      public var text:String;
      
      public var targetId:String;
      
      public var doesQueue:Boolean;
      
      public var imgURL:String = "";
      
      public function ToasterMessage(param1:String = null, param2:String = null)
      {
         super();
         this.text = param1;
         this.targetId = param2;
      }
   }
}

