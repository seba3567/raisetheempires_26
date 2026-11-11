package Weapon_FX_fla
{
   import fl.motion.AnimatorFactory3D;
   import fl.motion.MotionBase;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol820")]
   public dynamic class Carrier_Fire_ProjectileB_Blur_84 extends MovieClip
   {
      
      public var __id52_:MovieClip;
      
      public var __initial3DPosition___id52_Export3D1_:Array;
      
      public var __animFactory___id52_Export3D1:AnimatorFactory3D;
      
      public var __motion___id52_Export3D1:MotionBase;
      
      public function Carrier_Fire_ProjectileB_Blur_84()
      {
         super();
         if(this.__motion___id52_Export3D1 == null)
         {
            this.__motion___id52_Export3D1 = new MotionBase();
            this.__motion___id52_Export3D1.duration = 20;
            this.__motion___id52_Export3D1.overrideTargetTransform();
            this.__motion___id52_Export3D1.addPropertyArray("x",[0]);
            this.__motion___id52_Export3D1.addPropertyArray("y",[0]);
            this.__motion___id52_Export3D1.addPropertyArray("scaleX",[2]);
            this.__motion___id52_Export3D1.addPropertyArray("scaleY",[2]);
            this.__motion___id52_Export3D1.addPropertyArray("skewX",[0]);
            this.__motion___id52_Export3D1.addPropertyArray("skewY",[0]);
            this.__motion___id52_Export3D1.addPropertyArray("z",[0]);
            this.__motion___id52_Export3D1.addPropertyArray("rotationX",[0]);
            this.__motion___id52_Export3D1.addPropertyArray("rotationY",[0]);
            this.__motion___id52_Export3D1.addPropertyArray("rotationZ",[0]);
            this.__motion___id52_Export3D1.addPropertyArray("blendMode",["normal"]);
            this.__motion___id52_Export3D1.addPropertyArray("alphaMultiplier",[0,0.052632,0.105263,0.157895,0.210526,0.263158,0.315789,0.368421,0.421052,0.473684,0.526316,0.578947,0.631579,0.68421,0.736842,0.789474,0.842105,0.894737,0.947368,1]);
            this.__animFactory___id52_Export3D1 = new AnimatorFactory3D(this.__motion___id52_Export3D1);
            this.__animFactory___id52_Export3D1.transformationPoint = new Point(-2.8,-2.3);
            this.__animFactory___id52_Export3D1.sceneName = "Carrier_Fire_ProjectileB_Blur";
            this.__initial3DPosition___id52_Export3D1_ = new Array(0,0,0);
            this.__animFactory___id52_Export3D1.addTargetInfo(this,"__id52_",0,true,10,true,this.__initial3DPosition___id52_Export3D1_);
         }
      }
   }
}

