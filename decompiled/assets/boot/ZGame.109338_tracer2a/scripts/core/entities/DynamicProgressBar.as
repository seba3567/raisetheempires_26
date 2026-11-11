package core.entities
{
   import core.ZGlobal;
   import flash.display.Shape;
   import utils.TextFieldUtil;
   import zgame.assets.ui.AssetGroup_UI.DynamicProgressBarClip;
   
   public class DynamicProgressBar extends ProgressBar implements IDynamicProgressBar
   {
      
      private static const MINIMUN_DELTA_RESIZE:Number = 10;
      
      private var m_iconOffset:Number;
      
      private var m_bkgdOffset:Number;
      
      private var m_overlayOffset:Number;
      
      private var m_originalBarWidth:Number;
      
      private var m_currentTextWidth:Number;
      
      private var m_barMask:Shape = null;
      
      public function DynamicProgressBar()
      {
         super();
      }
      
      override protected function initialize() : void
      {
         m_progressDisplayObject = new DynamicProgressBarClip();
         addChild(m_progressDisplayObject);
         this.m_iconOffset = m_progressDisplayObject.icon_mc.x - m_progressDisplayObject.bar.x;
         this.m_bkgdOffset = m_progressDisplayObject.bgl_mc.x - m_progressDisplayObject.bar.x;
         this.m_overlayOffset = m_progressDisplayObject.overlayl_mc.x - m_progressDisplayObject.bar.x;
         this.m_originalBarWidth = m_progressDisplayObject.bar.width;
         this.configureForTextWidth(0);
      }
      
      override public function destroy() : void
      {
         this.clearBarMask();
         super.destroy();
      }
      
      override public function setPosition(param1:Number, param2:Number) : void
      {
         this.x = param1;
         this.y = -param2;
      }
      
      override public function updateProgressBarPercentage(param1:String, param2:Number = 0) : void
      {
         TextFieldUtil.processTextField(m_progressDisplayObject.label_tf,param1);
         var _loc3_:Number = Number(m_progressDisplayObject.label_tf.textWidth);
         if(Math.abs(_loc3_ - this.m_currentTextWidth) > MINIMUN_DELTA_RESIZE)
         {
            this.configureForTextWidth(_loc3_);
         }
         m_progressDisplayObject.bar.width = m_actionBarWidth * param2;
      }
      
      private function configureForTextWidth(param1:Number) : void
      {
         this.m_currentTextWidth = param1;
         param1 += ZGlobal.gameSettings.getInt("progressBarWidthMargin") * 2;
         param1 = Math.max(param1,ZGlobal.gameSettings.getInt("progressBarMinWidth"));
         param1 = Math.min(param1,ZGlobal.gameSettings.getInt("progressBarMaxWidth"));
         m_actionBarWidth = param1;
         var _loc2_:Number = -m_actionBarWidth * 0.5;
         m_progressDisplayObject.bar.x = _loc2_;
         m_progressDisplayObject.icon_mc.x = _loc2_ + this.m_iconOffset;
         m_progressDisplayObject.bgl_mc.x = _loc2_ + this.m_bkgdOffset;
         m_progressDisplayObject.overlayl_mc.x = _loc2_ + this.m_overlayOffset;
         var _loc3_:Number = _loc2_ - (this.m_originalBarWidth - m_actionBarWidth);
         m_progressDisplayObject.bgr_mc.x = _loc3_ + this.m_bkgdOffset;
         m_progressDisplayObject.overlayr_mc.x = _loc3_ + this.m_overlayOffset;
         this.clearBarMask();
         this.m_barMask = new Shape();
         this.m_barMask.graphics.beginFill(0);
         this.m_barMask.graphics.drawRoundRect(0,0,m_actionBarWidth,m_progressDisplayObject.bar.height,8);
         this.m_barMask.x = m_progressDisplayObject.bar.x;
         this.m_barMask.y = m_progressDisplayObject.bar.y;
         m_progressDisplayObject.bar.mask = this.m_barMask;
         addChild(this.m_barMask);
      }
      
      private function clearBarMask() : void
      {
         if(this.m_barMask)
         {
            m_progressDisplayObject.bar.mask = null;
            removeChild(this.m_barMask);
            this.m_barMask = null;
         }
      }
   }
}

