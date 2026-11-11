package core.managers.animationManager
{
   import core.ZGlobal;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.events.WorldEvent;
   
   public class AnimationManager extends EventDispatcher
   {
      
      public static var instance:AnimationManager = new AnimationManager();
      
      public static const ACTIVATE:String = "activate_anim";
      
      private var m_animations:Dictionary = null;
      
      private var m_zoomCullValue:Number = 0;
      
      private var m_active:Boolean = true;
      
      public function AnimationManager()
      {
         super();
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:Animation = null;
         this.m_zoomCullValue = ZGlobal.gameSettings.getNumber("animationCullZoom");
         this.m_animations = new Dictionary();
         for each(_loc2_ in param1)
         {
            _loc3_ = _loc2_.@name.toString();
            _loc4_ = new Animation(_loc2_);
            this.m_animations[_loc3_] = _loc4_;
         }
      }
      
      public function getAnimation(param1:String) : Animation
      {
         return this.m_animations[param1];
      }
      
      public function zoom(param1:Number) : void
      {
         if(this.m_active)
         {
            if(param1 < this.m_zoomCullValue)
            {
               this.m_active = false;
               dispatchEvent(new WorldEvent(ACTIVATE,this.m_active));
            }
         }
         else if(param1 >= this.m_zoomCullValue)
         {
            this.m_active = true;
            dispatchEvent(new WorldEvent(ACTIVATE,this.m_active));
         }
      }
   }
}

