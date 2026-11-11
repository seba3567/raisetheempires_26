package displays.screens.neighborScreen
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import core.ZGlobal;
   import core.managers.tutorialManager.TutorialManager;
   import displays.popups.ReactivationGiftPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   
   public class ContextualMenuWrapperBase extends MovieClip
   {
      
      private var m_grid:UserGrid;
      
      private var m_mc:MovieClip;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer;
      
      private var m_continueInvasion:Boolean = false;
      
      public function ContextualMenuWrapperBase(param1:NeighborSlot, param2:UserGrid, param3:Class)
      {
         super();
         this.m_grid = param2;
         this.m_mc = new param3();
         this.m_mc.neighborSlot = param1;
         addChild(this.m_mc);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         TweenLite.from(this,0.2,{
            "scaleY":0.25,
            "ease":Back.easeOut,
            "onComplete":this.onTweenComplete
         });
      }
      
      public function get mc() : MovieClip
      {
         return this.m_mc;
      }
      
      public function get uid() : String
      {
         return this.m_mc.neighborSlot.uid;
      }
      
      protected function get continueInvasion() : Boolean
      {
         return this.m_continueInvasion;
      }
      
      protected function set continueInvasion(param1:Boolean) : void
      {
         this.m_continueInvasion = param1;
      }
      
      public function dispose() : void
      {
         this.onDispose();
         TweenLite.killTweensOf(this);
         if(this.m_mc)
         {
            removeChild(this.m_mc);
            this.m_mc = null;
         }
      }
      
      protected function get grid() : UserGrid
      {
         return this.m_grid;
      }
      
      protected function get buttonSounds() : ButtonMouseEventSoundContainer
      {
         return this.m_buttonSounds;
      }
      
      protected function onDispose() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
      }
      
      protected function onVisitClick(param1:MouseEvent) : void
      {
         if(TutorialManager.instance.neighborBarEnabled)
         {
            if(ZGlobal.neighborReactivationNeeded(this.uid))
            {
               ReactivationGiftPopup.show(this.uid);
            }
            else
            {
               this.grid.onVisitClick(this.mc.neighborSlot,this.getDebugContext());
            }
         }
         else
         {
            TutorialManager.instance.showInvalidVisitPopup();
         }
      }
      
      protected function getDebugContext() : String
      {
         return null;
      }
      
      private function onTweenComplete() : void
      {
         scaleY = 1;
      }
   }
}

