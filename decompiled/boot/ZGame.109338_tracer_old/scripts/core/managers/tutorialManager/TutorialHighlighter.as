package core.managers.tutorialManager
{
   import com.greensock.TweenMax;
   import core.gamemode.GameModeManager;
   import events.IsoViewEvent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import rendering.rendering2d.MovieController;
   import zlabs.Zlab;
   
   public class TutorialHighlighter
   {
      
      private const DRAW_DISPLAY_OBJECT_HIGHLIGHT:int = 0;
      
      private const DRAW_MOVIE_CLIP_HIGHLIGHT:int = 1;
      
      private const DRAW_STANDARD_HIGHLIGHT:int = 2;
      
      private var m_drawHighlightType:int = 2;
      
      private var m_movieController:MovieController = null;
      
      private var m_arrow:TutorialArrow = null;
      
      private var m_target:DisplayObject = null;
      
      private var m_center:Boolean = false;
      
      private var m_centerVert:Boolean = false;
      
      private var m_rotation:Number = 0;
      
      private var m_offset:Point = null;
      
      private var m_useEntityOffset:Boolean = false;
      
      private var m_attachToStage:Boolean = false;
      
      public function TutorialHighlighter()
      {
         super();
         this.m_arrow = new TutorialArrow();
         this.m_movieController = new MovieController(this.m_arrow);
         this.m_movieController.fps = 15;
         this.m_arrow.mouseEnabled = false;
         this.m_arrow.mouseChildren = false;
         this.m_arrow.visible = false;
         Zlab.inputManager.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen,false,0,true);
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onViewChanged,false,0,true);
         Zlab.mainStage.addEventListener(Event.RESIZE,this.onReposition);
      }
      
      public function dispose() : void
      {
         if(this.m_arrow.parent)
         {
            this.m_arrow.parent.removeChild(this.m_arrow);
         }
         this.m_movieController.dispose();
         this.m_movieController = null;
         this.m_arrow = null;
      }
      
      private function setTarget(param1:Object) : void
      {
         if(!this.m_arrow)
         {
            return;
         }
         if(this.m_arrow.parent)
         {
            this.m_arrow.parent.removeChild(this.m_arrow);
         }
         if(null != param1)
         {
            this.m_arrow.visible = true;
         }
         else
         {
            TweenMax.killTweensOf(this.m_arrow);
            this.m_arrow.visible = false;
         }
      }
      
      public function setDisplayObject(param1:DisplayObject, param2:Boolean = true, param3:Number = 0, param4:Boolean = false, param5:Point = null) : void
      {
         this.m_target = param1;
         this.m_center = param2;
         this.m_centerVert = param4;
         this.m_rotation = param3;
         this.m_offset = param5;
         this.m_drawHighlightType = this.DRAW_DISPLAY_OBJECT_HIGHLIGHT;
         this.drawHighlight();
      }
      
      private function drawDisplayObjectHighlight() : void
      {
         if(!this.m_arrow || !this.m_target)
         {
            return;
         }
         this.m_arrow.rotation = this.m_rotation;
         var _loc1_:Rectangle = this.m_target.getRect(Zlab.mainStage);
         var _loc2_:Number = _loc1_.x;
         var _loc3_:Number = _loc1_.y;
         if(this.m_center)
         {
            this.m_arrow.x = _loc2_ + _loc1_.width / 2 - this.m_arrow.width / 2;
         }
         else
         {
            this.m_arrow.x = _loc2_ - this.m_arrow.width / 2;
         }
         if(this.m_centerVert)
         {
            this.m_arrow.y = _loc3_ + _loc1_.height / 2;
            this.m_arrow.y += this.m_arrow.width - this.m_arrow.height;
            if(this.m_rotation == -90)
            {
               this.m_arrow.x = _loc2_ - this.m_arrow.width;
            }
            else if(this.m_rotation == 90)
            {
               this.m_arrow.x = _loc2_ + this.m_arrow.width;
            }
         }
         else
         {
            this.m_arrow.y = _loc3_ - this.m_arrow.height;
         }
         if(this.m_offset)
         {
            this.m_arrow.x += this.m_offset.x;
            this.m_arrow.y += this.m_offset.y;
         }
         Zlab.mainStage.addChild(this.m_arrow);
      }
      
      public function setMovieClip(param1:MovieClip, param2:Boolean = false, param3:Boolean = true, param4:Boolean = false, param5:Point = null, param6:Number = 0) : void
      {
         this.m_target = param1;
         this.m_useEntityOffset = param2;
         this.m_center = param3;
         this.m_attachToStage = param4;
         this.m_offset = param5;
         this.m_rotation = param6;
         this.m_drawHighlightType = this.DRAW_MOVIE_CLIP_HIGHLIGHT;
         this.drawHighlight();
      }
      
      private function drawMovieClipHighlight() : void
      {
         var _loc1_:Rectangle = null;
         if(!this.m_arrow || !this.m_target)
         {
            return;
         }
         this.m_arrow.rotation = this.m_rotation;
         if(this.m_useEntityOffset)
         {
            this.m_arrow.x = 0 - this.m_target.width / 10 - this.m_arrow.width / 2;
            this.m_arrow.y = 0 - this.m_arrow.height;
         }
         else
         {
            if(this.m_center)
            {
               this.m_arrow.x = 0 + this.m_target.width / 2 - this.m_arrow.width / 2;
            }
            else
            {
               this.m_arrow.x = 0 - this.m_arrow.width / 2;
            }
            this.m_arrow.y = 0 - this.m_arrow.height;
         }
         if(this.m_offset)
         {
            this.m_arrow.x += this.m_offset.x;
            this.m_arrow.y += this.m_offset.y;
         }
         if(this.m_attachToStage)
         {
            _loc1_ = this.m_target.getRect(Zlab.mainStage);
            this.m_arrow.x += _loc1_.x;
            this.m_arrow.y += _loc1_.y;
            Zlab.mainStage.addChild(this.m_arrow);
         }
         else
         {
            MovieClip(this.m_target).addChild(this.m_arrow);
         }
      }
      
      public function setArt(param1:DisplayObjectContainer, param2:Point = null) : void
      {
         this.m_target = param1;
         this.m_offset = param2;
         this.m_drawHighlightType = this.DRAW_STANDARD_HIGHLIGHT;
         this.drawHighlight();
      }
      
      private function drawArtHighlight() : void
      {
         if(!this.m_arrow || !this.m_target)
         {
            return;
         }
         this.m_arrow.x = this.m_target.x + this.m_target.width / 2 - this.m_arrow.width / 2;
         this.m_arrow.y = this.m_target.y - this.m_arrow.height;
         if(this.m_offset)
         {
            this.m_arrow.x += this.m_offset.x;
            this.m_arrow.y += this.m_offset.y;
         }
         this.m_target.parent.addChild(this.m_arrow);
      }
      
      private function drawHighlight() : void
      {
         this.setTarget(this.m_target);
         switch(this.m_drawHighlightType)
         {
            case this.DRAW_DISPLAY_OBJECT_HIGHLIGHT:
               this.drawDisplayObjectHighlight();
               break;
            case this.DRAW_MOVIE_CLIP_HIGHLIGHT:
               this.drawMovieClipHighlight();
               break;
            case this.DRAW_STANDARD_HIGHLIGHT:
               this.drawArtHighlight();
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

