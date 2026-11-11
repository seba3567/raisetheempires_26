package core.gamemode
{
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class MoveGridPing implements IPointerAttachment
   {
      
      private var m_cursorBracketsClass:Class = MoveGridPing_m_cursorBracketsClass;
      
      private var m_displayObject:DisplayObject = null;
      
      public function MoveGridPing()
      {
         super();
      }
      
      public function init(param1:Class) : void
      {
         this.m_displayObject = new this.m_cursorBracketsClass();
         this.m_displayObject.visible = false;
         GridPointer.instance.addEventListener(GridPointer.SET_DESTINATION,this.onDestinationSet);
      }
      
      public function get displayObjects() : Array
      {
         return [this.m_displayObject];
      }
      
      public function dispose() : void
      {
         TweenLite.killTweensOf(this.m_displayObject);
         this.m_displayObject = null;
         GridPointer.instance.removeEventListener(GridPointer.SET_DESTINATION,this.onDestinationSet);
      }
      
      public function updateColours(param1:Function) : void
      {
      }
      
      private function onDestinationSet(param1:Event) : void
      {
         this.m_displayObject.x = this.m_displayObject.width * 0.5;
         this.m_displayObject.y = this.m_displayObject.height * 0.5;
         this.m_displayObject.scaleX = this.m_displayObject.scaleY = 0;
         this.m_displayObject.visible = true;
         TweenLite.to(this.m_displayObject,0.5,{
            "scaleX":1,
            "scaleY":1,
            "x":0,
            "y":0,
            "onComplete":this.onTweenComplete
         });
      }
      
      private function onTweenComplete() : void
      {
         this.m_displayObject.visible = false;
      }
   }
}

