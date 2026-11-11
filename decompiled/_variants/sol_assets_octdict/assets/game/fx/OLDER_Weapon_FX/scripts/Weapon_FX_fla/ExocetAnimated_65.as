package Weapon_FX_fla
{
   import fl.motion.AnimatorFactory3D;
   import fl.motion.MotionBase;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol860")]
   public dynamic class ExocetAnimated_65 extends MovieClip
   {
      
      public var __id59_:MovieClip;
      
      public var __animFactory___id59_Export3D1:AnimatorFactory3D;
      
      public var __motion___id59_Export3D1:MotionBase;
      
      public var __initial3DPosition___id59_Export3D1_:Array;
      
      public function ExocetAnimated_65()
      {
         super();
         if(this.__motion___id59_Export3D1 == null)
         {
            this.__motion___id59_Export3D1 = new MotionBase();
            this.__motion___id59_Export3D1.duration = 45;
            this.__motion___id59_Export3D1.overrideTargetTransform();
            this.__motion___id59_Export3D1.addPropertyArray("x",[0,1.82159,3.64318,5.46477,7.28636,9.10795,10.9295,12.7511,14.5727,16.3943,18.2159,20.0375,21.8591,23.6807,25.5023,27.3239,29.1454,30.967,32.7886,34.6102,36.4318,38.2534,40.075,41.8966,43.7182,45.5398,47.3613,49.1829,51.0045,52.8261,54.6477,56.4693,58.2909,60.1125,61.9341,63.7557,65.5773,67.3989,69.2204,71.042,72.8636,74.6852,76.5068,78.3284,80.15]);
            this.__motion___id59_Export3D1.addPropertyArray("y",[0,-2.59754e-8,-5.19508e-8,-7.79263e-8,-1.03902e-7,-1.29877e-7,-1.55853e-7,-1.81828e-7,-2.07803e-7,-2.33779e-7,-2.59754e-7,-2.8573e-7,-3.11705e-7,-3.37681e-7,-3.63656e-7,-3.89632e-7,-4.15607e-7,-4.41583e-7,-4.67558e-7,-4.93533e-7,-5.19509e-7,-5.45484e-7,-5.7146e-7,-5.97435e-7,-6.23411e-7,-6.49386e-7,-6.75362e-7,-7.01337e-7,-7.27313e-7,-7.53288e-7,-7.79263e-7,-8.05239e-7,-8.31214e-7,-8.5719e-7,-8.83165e-7,-9.09141e-7,-9.35116e-7,-9.61092e-7,-9.87067e-7,-0.00000101304,-0.00000103902,-0.00000106499,-0.00000109097,-0.00000111694,-0.00000114292]);
            this.__motion___id59_Export3D1.addPropertyArray("scaleX",[1.68]);
            this.__motion___id59_Export3D1.addPropertyArray("scaleY",[2.3]);
            this.__motion___id59_Export3D1.addPropertyArray("skewX",[0]);
            this.__motion___id59_Export3D1.addPropertyArray("skewY",[0]);
            this.__motion___id59_Export3D1.addPropertyArray("z",[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
            this.__motion___id59_Export3D1.addPropertyArray("rotationX",[0]);
            this.__motion___id59_Export3D1.addPropertyArray("rotationY",[0]);
            this.__motion___id59_Export3D1.addPropertyArray("rotationZ",[0]);
            this.__motion___id59_Export3D1.addPropertyArray("blendMode",["layer"]);
            this.__animFactory___id59_Export3D1 = new AnimatorFactory3D(this.__motion___id59_Export3D1);
            this.__animFactory___id59_Export3D1.transformationPoint = new Point(-75.35,0);
            this.__animFactory___id59_Export3D1.sceneName = "ExocetAnimated";
            this.__initial3DPosition___id59_Export3D1_ = new Array(-0.7,46.45,0);
            this.__animFactory___id59_Export3D1.addTargetInfo(this,"__id59_",0,true,0,true,this.__initial3DPosition___id59_Export3D1_);
         }
      }
   }
}

