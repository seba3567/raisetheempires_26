package core.gamemode.island
{
   import displays.screens.neighborScreen.IPlayerSlot;
   
   public class IslandPlayerSlot implements IPlayerSlot
   {
      
      private var m_uid:String = null;
      
      public function IslandPlayerSlot(param1:String)
      {
         super();
         this.m_uid = param1;
      }
      
      public function get empty() : Boolean
      {
         return false;
      }
      
      public function get uid() : String
      {
         return this.m_uid;
      }
   }
}

