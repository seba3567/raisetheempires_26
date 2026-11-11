package Engine.Classes
{
   import flash.display.Sprite;
   
   public class ViewportLayer extends Sprite
   {
      
      protected var m_priority:Number;
      
      public function ViewportLayer(param1:String, param2:Number = 0)
      {
         name = param1;
         this.priority = param2;
         super();
      }
      
      public function set priority(param1:Number) : void
      {
         this.m_priority = param1;
      }
      
      public function get priority() : Number
      {
         return this.m_priority;
      }
   }
}

