package core.worlds.battleWorld
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.utils.getDefinitionByName;
   import rendering.rendering2d.MovieController;
   import zlabs.resource.SWFResource;
   
   public class BattleMovie
   {
      
      protected var m_classes:Array = null;
      
      private var m_canvas:DisplayObjectContainer = null;
      
      protected var m_movieClip:MovieClip = null;
      
      protected var m_current:MovieController = null;
      
      public function BattleMovie(param1:DisplayObjectContainer, param2:SWFResource)
      {
         super();
         this.m_canvas = param1;
      }
      
      public function dispose() : void
      {
         this.onComplete();
         this.m_canvas = null;
      }
      
      protected function initMovie(param1:MovieClip, param2:int) : void
      {
      }
      
      protected function triggerMovie(param1:int) : void
      {
         this.onComplete();
         this.m_movieClip = new this.m_classes[param1]();
         this.m_canvas.addChild(this.m_movieClip);
         this.m_movieClip.mouseEnabled = false;
         this.m_movieClip.mouseChildren = false;
         this.initMovie(this.m_movieClip,param1);
         this.m_current = new MovieController(this.m_movieClip);
         this.m_current.fps = 15;
         this.m_current.onComplete = this.onComplete;
         this.m_current.mode = MovieController.ONCE;
      }
      
      protected function onComplete() : void
      {
         if(null != this.m_movieClip)
         {
            this.m_canvas.removeChild(this.m_movieClip);
            this.m_movieClip = null;
         }
         if(null != this.m_current)
         {
            this.m_current.dispose();
            this.m_current = null;
         }
      }
   }
}

