package rendering.rendering2d
{
   import com.greensock.TweenLite;
   import core.worlds.battleWorld.BattleRendererComponent;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.text.TextFieldAutoSize;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class DamageIndicator
   {
      
      private var m_movieClip:MovieClip = null;
      
      private var m_damageIndicator:MovieController = null;
      
      private var m_parent:DisplayObjectContainer = null;
      
      private var m_damageClass:Class = null;
      
      private var m_scale:Number = 1;
      
      private var m_float:Number = 0;
      
      private var m_x:Number = 0;
      
      private var m_y:Number = 0;
      
      private var m_autoSize:Boolean = false;
      
      private var m_invert:Boolean = false;
      
      public function DamageIndicator(param1:Class, param2:DisplayObjectContainer, param3:Boolean)
      {
         super();
         this.m_damageClass = param1;
         this.m_parent = param2;
         this.m_invert = param3;
      }
      
      public function set scale(param1:Number) : void
      {
         this.m_scale = param1;
      }
      
      public function set float(param1:Number) : void
      {
         this.m_float = param1;
      }
      
      public function set autoSize(param1:Boolean) : void
      {
         this.m_autoSize = param1;
      }
      
      public function dispose() : void
      {
         this.m_parent.removeChild(this.m_movieClip);
         this.m_damageIndicator.dispose();
         this.m_damageIndicator = null;
         TweenLite.killTweensOf(this.m_movieClip);
         this.m_movieClip = null;
         this.m_parent = null;
         Zlab.processManager.removeScheduledObject(this);
      }
      
      public function floatingText(param1:String, param2:int, param3:Number, param4:Number) : void
      {
         this.m_x = param3;
         this.m_y = param4;
         Zlab.processManager.schedule(param2,this,this.doFloatingText,param1);
      }
      
      private function doFloatingText(param1:String) : void
      {
         this.m_movieClip = new this.m_damageClass();
         if(this.m_autoSize)
         {
            this.m_movieClip.textBox.title_tf.autoSize = TextFieldAutoSize.CENTER;
         }
         TextFieldUtil.processTextField(this.m_movieClip.textBox.title_tf,param1);
         var _loc2_:Number = this.m_movieClip.textBox.title_tf.width * 0.5 * this.m_scale;
         this.m_movieClip.scaleX = this.m_movieClip.scaleY = this.m_scale;
         this.m_movieClip.x = this.m_x;
         this.m_movieClip.y = this.m_y;
         if(this.m_x + this.m_movieClip.textWidth > BattleRendererComponent.WIDTH)
         {
            this.m_movieClip.x = BattleRendererComponent.WIDTH - _loc2_ * 0.9;
         }
         else if(this.m_x < 0)
         {
            this.m_movieClip.x = _loc2_ * 0.75;
         }
         this.m_parent.addChild(this.m_movieClip);
         if(this.m_invert)
         {
            this.m_movieClip.filters = [ZGameUtils.InvertFilter];
         }
         this.m_damageIndicator = new MovieController(this.m_movieClip);
         this.m_damageIndicator.fps = 15;
         this.m_damageIndicator.mode = MovieController.ONCE;
         this.m_damageIndicator.onComplete = this.onDamageIndicatorComplete;
         if(this.m_float != 0)
         {
            TweenLite.to(this.m_movieClip,2,{"y":this.m_float.toString()});
         }
         this.m_damageClass = null;
      }
      
      private function onDamageIndicatorComplete() : void
      {
         this.dispose();
      }
   }
}

