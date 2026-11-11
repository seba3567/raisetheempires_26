package core.ui.components.PortraitSlidePick
{
   import core.ZGlobal;
   import flash.display.MovieClip;
   import flash.events.Event;
   import rendering.rendering2d.MovieController;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class PortraitPickDissolveHelperEmbers extends PortraitPickDissolveHelper
   {
      
      private const HIDE_FRAME:int = 14;
      
      private var m_mc:MovieClip;
      
      private var m_controller:MovieController;
      
      public function PortraitPickDissolveHelperEmbers(param1:MovieClip)
      {
         super(param1);
         var _loc2_:String = "assets/displays/screens/Pvp_PicksAndMisc.swf";
         var _loc3_:String = ZGlobal.getAssetURL(_loc2_);
         Zlab.resourceManager.load(_loc3_,SWFResource,this.onLoadComplete);
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = param1.getAssetClass("pickDisolve_MC");
         this.m_mc = new _loc2_();
         m_parent.addChild(this.m_mc);
         this.m_controller = new MovieController(this.m_mc);
         this.m_controller.fps = 15;
         this.m_controller.mode = MovieController.ONCE;
         this.m_controller.onComplete = this.onDoneFrame;
         this.m_mc.addFrameScript(this.HIDE_FRAME,this.onHideFrame);
         this.m_mc.play();
      }
      
      override protected function onDispose() : void
      {
         if(this.m_mc)
         {
            this.m_controller.dispose();
            this.m_controller = null;
            this.m_mc.addFrameScript(this.HIDE_FRAME,null);
            this.m_mc.parent.removeChild(this.m_mc);
            this.m_mc = null;
         }
      }
      
      private function onHideFrame() : void
      {
         dispatchEvent(new Event(HIDE));
      }
      
      private function onDoneFrame() : void
      {
         dispatchEvent(new Event(DONE));
      }
   }
}

