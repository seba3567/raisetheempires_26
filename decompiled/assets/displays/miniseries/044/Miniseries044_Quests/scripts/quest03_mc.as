package
{
   import adobe.utils.*;
   import fl.motion.AnimatorFactory3D;
   import fl.motion.MotionBase;
   import flash.accessibility.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.system.*;
   import flash.text.*;
   import flash.text.engine.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol73")]
   public dynamic class quest03_mc extends MovieClip
   {
      
      public var desc_tf:TextField;
      
      public var requirement3_mc:MovieClip;
      
      public var __motion___id0_Export3D1:MotionBase;
      
      public var accept_bt:MovieClip;
      
      public var __id0_:MovieClip;
      
      public var requirement2_mc:MovieClip;
      
      public var exit_bt:SimpleButton;
      
      public var requirement1_mc:MovieClip;
      
      public var title_tf:TextField;
      
      public var __animFactory___id0_Export3D1:AnimatorFactory3D;
      
      public var ____motion___id0_Export3D1_mat3DVec_0_:Vector.<Number>;
      
      public function quest03_mc()
      {
         super();
         if(this.__motion___id0_Export3D1 == null)
         {
            this.__motion___id0_Export3D1 = new MotionBase();
            this.__motion___id0_Export3D1.duration = 1;
            this.__motion___id0_Export3D1.overrideTargetTransform();
            this.__motion___id0_Export3D1.addPropertyArray("blendMode",["normal"]);
            this.____motion___id0_Export3D1_mat3DVec_0_ = new Vector.<Number>(16);
            this.____motion___id0_Export3D1_mat3DVec_0_[0] = 0.912386;
            this.____motion___id0_Export3D1_mat3DVec_0_[1] = -0.000007;
            this.____motion___id0_Export3D1_mat3DVec_0_[2] = 0;
            this.____motion___id0_Export3D1_mat3DVec_0_[3] = 0;
            this.____motion___id0_Export3D1_mat3DVec_0_[4] = 0.000009;
            this.____motion___id0_Export3D1_mat3DVec_0_[5] = 0.860651;
            this.____motion___id0_Export3D1_mat3DVec_0_[6] = 0;
            this.____motion___id0_Export3D1_mat3DVec_0_[7] = 0;
            this.____motion___id0_Export3D1_mat3DVec_0_[8] = 0;
            this.____motion___id0_Export3D1_mat3DVec_0_[9] = 0;
            this.____motion___id0_Export3D1_mat3DVec_0_[10] = 1;
            this.____motion___id0_Export3D1_mat3DVec_0_[11] = 0;
            this.____motion___id0_Export3D1_mat3DVec_0_[12] = 28.699024;
            this.____motion___id0_Export3D1_mat3DVec_0_[13] = 45.403843;
            this.____motion___id0_Export3D1_mat3DVec_0_[14] = 0;
            this.____motion___id0_Export3D1_mat3DVec_0_[15] = 1;
            this.__motion___id0_Export3D1.addPropertyArray("matrix3D",new Array(new Matrix3D(this.____motion___id0_Export3D1_mat3DVec_0_)));
            this.__animFactory___id0_Export3D1 = new AnimatorFactory3D(this.__motion___id0_Export3D1);
            this.__animFactory___id0_Export3D1.sceneName = "quest03_mc";
            this.__animFactory___id0_Export3D1.addTargetInfo(this,"__id0_",0,true,0,true,null);
         }
      }
   }
}

