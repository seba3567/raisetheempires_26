package sound
{
   import flash.display.DisplayObject;
   
   public class ButtonMouseEventSoundContainer
   {
      
      private var m_buttonSounds:Array = [];
      
      public function ButtonMouseEventSoundContainer()
      {
         super();
      }
      
      public function addButton(param1:DisplayObject, param2:String) : void
      {
         this.m_buttonSounds.push(new ButtonMouseEventSoundHandler(param1,param2));
      }
      
      public function removeButton(param1:DisplayObject) : void
      {
         var _loc3_:ButtonMouseEventSoundHandler = null;
         var _loc2_:uint = 0;
         for each(_loc3_ in this.m_buttonSounds)
         {
            if(_loc3_.Controls(param1))
            {
               _loc3_.Release();
               this.m_buttonSounds.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
      }
      
      public function release() : void
      {
         var _loc1_:ButtonMouseEventSoundHandler = null;
         for each(_loc1_ in this.m_buttonSounds)
         {
            _loc1_.Release();
         }
      }
   }
}

