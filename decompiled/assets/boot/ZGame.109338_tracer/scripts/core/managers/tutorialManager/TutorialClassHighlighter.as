package core.managers.tutorialManager
{
   import com.greensock.TweenMax;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import events.IsoViewEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.geom.Point;
   import rendering.rendering2d.MovieController;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.SWFResource;
   
   public class TutorialClassHighlighter
   {
      
      private var m_movieController:MovieController = null;
      
      private var m_highlight:MovieClip = null;
      
      private var m_displayOnLoad:Boolean = false;
      
      private var m_target:DisplayObject = null;
      
      private var m_offset:Point = null;
      
      private var m_scale:Number = 1;
      
      private var m_attachToTarget:Boolean = false;
      
      public function TutorialClassHighlighter()
      {
         super();
         Zlab.resourceManager.load(ZGlobal.getAssetURL("assets/game/consumables/Consumables.swf"),SWFResource,this.onSWFLoadComplete,this.onSWFLoadFailed);
         Zlab.inputManager.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen,false,0,true);
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onViewChanged,false,0,true);
         Zlab.mainStage.addEventListener(Event.RESIZE,this.onReposition);
      }
      
      public function dispose() : void
      {
         if(Boolean(this.m_highlight) && Boolean(this.m_highlight.parent))
         {
            this.m_highlight.parent.removeChild(this.m_highlight);
         }
         this.m_target = null;
         this.m_offset = null;
         this.m_highlight = null;
      }
      
      private function onSWFLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = param1.getAssetClass("TutorialHighlight_MC");
         if(_loc2_)
         {
            this.m_highlight = new _loc2_() as MovieClip;
            this.m_highlight.mouseEnabled = false;
            this.m_highlight.mouseChildren = false;
         }
         else
         {
            Logger.error(this,"onSWFLoadFailed","unable to load class TutorialHighlight_MC");
         }
         if(this.m_displayOnLoad && Boolean(this.m_highlight))
         {
            this.drawHighlight();
         }
      }
      
      private function onSWFLoadFailed(param1:SWFResource) : void
      {
         Logger.error(this,"onSWFLoadFailed","unable to load swf " + param1.filename);
      }
      
      private function setTarget(param1:Object) : void
      {
         if(this.m_highlight.parent)
         {
            this.m_highlight.parent.removeChild(this.m_highlight);
         }
         if(null != param1)
         {
            this.m_highlight.visible = true;
         }
         else
         {
            TweenMax.killTweensOf(this.m_highlight);
            this.m_highlight.visible = false;
         }
      }
      
      public function setDisplayObject(param1:DisplayObject, param2:Point = null, param3:Number = 1, param4:Boolean = false) : void
      {
         this.m_target = param1;
         this.m_offset = param2;
         this.m_scale = param3;
         this.m_attachToTarget = param4;
         if(!this.m_highlight)
         {
            this.m_displayOnLoad = true;
            return;
         }
         this.setTarget(param1);
         this.drawHighlight();
      }
      
      private function drawHighlight() : void
      {
         var _loc1_:Point = null;
         if(!this.m_target)
         {
            return;
         }
         this.setTarget(this.m_target);
         if(!this.m_attachToTarget)
         {
            _loc1_ = ZGameUtils.localToLocal(this.m_target,Zlab.mainStage);
            this.m_highlight.x = _loc1_.x;
            this.m_highlight.y = _loc1_.y;
         }
         else
         {
            this.m_highlight.x = 0;
            this.m_highlight.y = 0;
         }
         if(this.m_offset)
         {
            this.m_highlight.x += this.m_offset.x;
            this.m_highlight.y += this.m_offset.y;
         }
         this.m_highlight.scaleX *= this.m_scale;
         this.m_highlight.scaleY *= this.m_scale;
         if(!this.m_attachToTarget)
         {
            Zlab.mainStage.addChild(this.m_highlight);
         }
         else
         {
            this.m_target.parent.addChild(this.m_highlight);
         }
      }
      
      private function onFullScreen(param1:FullScreenEvent) : void
      {
         this.drawHighlight();
      }
      
      private function onReposition(param1:Event) : void
      {
         this.drawHighlight();
      }
      
      private function onViewChanged(param1:Event) : void
      {
         this.drawHighlight();
      }
   }
}

