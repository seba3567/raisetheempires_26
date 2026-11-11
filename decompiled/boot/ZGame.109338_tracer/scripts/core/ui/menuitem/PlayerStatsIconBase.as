package core.ui.menuitem
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import core.ui.TextTweener;
   import flash.display.MovieClip;
   
   public class PlayerStatsIconBase
   {
      
      private var m_textTweener:TextTweener = null;
      
      private var m_origX:Number = 0;
      
      private var m_origY:Number = 0;
      
      protected var m_origWidth:Number = 0;
      
      protected var m_origHeight:Number = 0;
      
      protected var m_displayObject:MovieClip;
      
      public function PlayerStatsIconBase(param1:MovieClip, param2:Number, param3:Number, param4:Number, param5:Number)
      {
         super();
         this.m_displayObject = param1;
         this.m_origX = param2;
         this.m_origY = param3;
         this.m_origWidth = param4;
         this.m_origHeight = param5;
         this.m_textTweener = new TextTweener(this.m_displayObject.label_tf,{
            "maxLines":1,
            "minScale":0.5
         });
      }
      
      public function updateText(param1:int) : void
      {
         this.m_textTweener.tweenTo(param1,0.5,null);
      }
      
      public function bloop() : void
      {
         var _loc1_:Number = 1.25;
         var _loc2_:Number = this.iconMC.width * 0.125;
         this.iconMC.scaleX = 1;
         this.iconMC.scaleY = 1;
         this.iconMC.x = this.m_origX;
         TweenMax.killTweensOf(this.iconMC);
         TweenMax.to(this.iconMC,0.2,{
            "scaleX":_loc1_,
            "scaleY":_loc1_,
            "x":(-_loc2_).toString(),
            "yoyo":true,
            "repeat":1,
            "ease":Back.easeIn
         });
      }
      
      protected function get iconMC() : MovieClip
      {
         return this.m_displayObject.icon_mc;
      }
   }
}

