package displays.screens
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class CategoryDialogTab
   {
      
      private static const FRAME_UP:int = 1;
      
      private static const FRAME_OVER:int = 2;
      
      private static const FRAME_SELECT:int = 4;
      
      private var m_clip:MovieClip = null;
      
      private var m_index:int;
      
      private var m_xml:XML = null;
      
      private var m_onClick:Function = null;
      
      private var m_enabled:Boolean = true;
      
      private var m_selected:Boolean = false;
      
      private var m_iconLoader:ImageLoader = null;
      
      public function CategoryDialogTab(param1:MovieClip, param2:int, param3:XML, param4:Function)
      {
         super();
         this.m_clip = param1;
         this.m_index = param2;
         this.m_xml = param3;
         this.m_onClick = param4;
         this.m_clip.hit_mc.alpha = 0;
         this.m_clip.hit_mc.addEventListener(MouseEvent.ROLL_OVER,this.onMouseEnter,false,0,true);
         this.m_clip.hit_mc.addEventListener(MouseEvent.ROLL_OUT,this.onMouseExit,false,0,true);
         TextFieldUtil.compactTextField(this.m_clip.tooltip_mc.generic_tf,ZGameUtils.ZlocT("Dialogs",this.m_xml.@displayKey),{
            "maxLines":1,
            "minScale":0.4,
            "onFail":"return"
         });
         TextFieldUtil.processTextField(this.m_clip.selected_tf,ZGameUtils.ZlocT("Dialogs",this.m_xml.@displayKey));
         if(this.m_xml.@icon != undefined)
         {
            this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_xml.@icon),this.m_clip.icon.icon);
         }
         if(this.m_onClick != null)
         {
            this.m_clip.hit_mc.addEventListener(MouseEvent.CLICK,this.m_onClick,false,0,true);
         }
         this.m_clip.tooltip_mc.alpha = 0;
         this.m_clip.selected_tf.visible = false;
         if(this.m_clip.new_mc)
         {
            this.m_clip.new_mc.visible = false;
         }
      }
      
      public function destroy() : void
      {
         if(this.m_iconLoader)
         {
            this.m_iconLoader.destroy();
         }
         this.m_clip.hit_mc.removeEventListener(MouseEvent.ROLL_OVER,this.onMouseEnter);
         this.m_clip.hit_mc.removeEventListener(MouseEvent.ROLL_OUT,this.onMouseExit);
         if(this.m_onClick != null)
         {
            this.m_clip.hit_mc.removeEventListener(MouseEvent.CLICK,this.m_onClick);
         }
      }
      
      public function get clip() : MovieClip
      {
         return this.m_clip;
      }
      
      public function get overlay() : MovieClip
      {
         return this.m_clip.hit_mc;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this.m_enabled = param1;
         this.m_clip.hit_mc.visible = this.m_enabled;
      }
      
      public function get enabled() : Boolean
      {
         return this.m_enabled;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this.m_selected = param1;
         this.m_clip.gotoAndStop(this.m_selected ? FRAME_SELECT : FRAME_UP);
         this.m_clip.selected_tf.visible = param1;
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      public function get xml() : XML
      {
         return this.m_xml;
      }
      
      public function showNewText(param1:Boolean) : void
      {
         if(this.m_clip.new_mc)
         {
            this.m_clip.new_mc.visible = param1;
         }
      }
      
      private function onMouseEnter(param1:MouseEvent) : void
      {
         if(this.m_enabled && !this.m_selected)
         {
            this.m_clip.gotoAndStop(FRAME_OVER);
            this.showTooltip(true);
         }
      }
      
      private function onMouseExit(param1:MouseEvent) : void
      {
         if(this.m_enabled)
         {
            this.m_clip.gotoAndStop(this.m_selected ? FRAME_SELECT : FRAME_UP);
            this.showTooltip(false);
         }
      }
      
      private function showTooltip(param1:Boolean) : void
      {
         TweenLite.killTweensOf(this.m_clip.tooltip_mc);
         if(param1)
         {
            TweenLite.to(this.m_clip.tooltip_mc,0.5,{"alpha":1});
         }
         else
         {
            this.m_clip.tooltip_mc.alpha = 0;
         }
      }
   }
}

