package core.ui
{
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import core.gamemode.GameModeManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import events.IsoViewEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import zlabs.Zlab;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class FloatingText extends Sprite
   {
      
      private var m_text:TextField = null;
      
      private var m_disposeOnComplete:Boolean = false;
      
      private var m_movieClip:MovieClip = null;
      
      private var m_onDispose:Function = null;
      
      private var m_scale:Number = 1;
      
      private var m_fadeOutSeconds:Number = 0.25;
      
      private var m_useWorldZoom:Boolean = true;
      
      private var m_useParentExtents:Boolean = false;
      
      private var m_floatTime:Number = 2;
      
      public function FloatingText(param1:DisplayObjectContainer, param2:Class = null)
      {
         super();
         mouseEnabled = false;
         mouseChildren = false;
         this.m_movieClip = param2 == null ? new LootText() : new param2();
         this.m_text = this.m_movieClip.text_tf;
         this.m_text.visible = false;
         addChild(this.m_text);
         param1.addChild(this);
      }
      
      public function set position(param1:Pt) : void
      {
         x = param1.x;
         y = param1.y;
      }
      
      public function set color(param1:int) : void
      {
         this.m_text.textColor = param1;
      }
      
      public function set scale(param1:Number) : void
      {
         this.m_scale = param1;
         scaleX = scaleY = this.m_scale * (this.m_useWorldZoom ? this.getScaleAccordingToZoom(0) : 1);
      }
      
      public function set useWorldZoom(param1:Boolean) : void
      {
         this.m_useWorldZoom = param1;
         if(this.m_useWorldZoom)
         {
            GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         }
      }
      
      public function set useParentExtents(param1:Boolean) : void
      {
         this.m_useParentExtents = param1;
      }
      
      public function set onDispose(param1:Function) : void
      {
         this.m_onDispose = param1;
      }
      
      protected function get buffer() : int
      {
         return 0;
      }
      
      public function getScaleAccordingToZoom(param1:Number) : Number
      {
         var _loc2_:IsoViewComponent = null;
         if(param1 == 0)
         {
            _loc2_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
            param1 = _loc2_.currentZoom;
         }
         if(param1 < 0.5)
         {
            param1 *= 1 + (0.5 - param1) / 0.25 * 1;
         }
         return 1 / param1;
      }
      
      public function dispose() : void
      {
         TweenLite.killTweensOf(this);
         if(null != this.m_text)
         {
            parent.removeChild(this);
            removeChild(this.m_text);
            this.m_text = null;
         }
         if(null != this.m_onDispose)
         {
            this.m_onDispose();
            this.m_onDispose = null;
         }
         this.m_movieClip = null;
         if(this.m_useWorldZoom)
         {
            GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         }
      }
      
      public function set fadeOutSeconds(param1:Number) : void
      {
         this.m_fadeOutSeconds = param1;
      }
      
      public function set disposeOnComplete(param1:Boolean) : void
      {
         this.m_disposeOnComplete = param1;
      }
      
      public function set duration(param1:Number) : void
      {
         this.m_floatTime = param1;
      }
      
      protected function getDuration() : Number
      {
         return this.m_floatTime;
      }
      
      public function set text(param1:String) : void
      {
         var _loc4_:int = 0;
         this.m_text.x = 0;
         this.m_text.y = 0;
         TextFieldUtil.processSingleLineTextField(this.m_text,param1,15);
         this.m_text.visible = true;
         var _loc2_:Number = this.m_text.textWidth;
         x -= _loc2_ * 0.5;
         if(!this.m_useWorldZoom)
         {
            if(this.m_useParentExtents)
            {
               if(x + parent.x < this.buffer)
               {
                  x = -parent.x + this.buffer;
               }
               else
               {
                  _loc4_ = (x + parent.x + _loc2_) * parent.scaleX - Zlab.mainStage.stageWidth;
                  if(_loc4_ > 0)
                  {
                     x -= _loc4_;
                  }
               }
            }
            else if(x < this.buffer)
            {
               x = this.buffer;
            }
         }
         var _loc3_:Number = this.getDuration();
         TweenLite.to(this,_loc3_,{
            "y":"-100",
            "onComplete":this.onTextRiseComplete
         });
         if(this.m_fadeOutSeconds > 0)
         {
            TweenLite.to(this,this.m_fadeOutSeconds,{
               "alpha":0,
               "overwrite":false,
               "delay":_loc3_ - this.m_fadeOutSeconds
            });
         }
      }
      
      private function onZoom(param1:IsoViewEvent) : void
      {
         scaleX = scaleY = this.m_scale * this.getScaleAccordingToZoom(param1.value);
      }
      
      private function onTextRiseComplete() : void
      {
         if(this.m_disposeOnComplete)
         {
            this.dispose();
         }
         else
         {
            this.m_text.visible = false;
         }
      }
   }
}

