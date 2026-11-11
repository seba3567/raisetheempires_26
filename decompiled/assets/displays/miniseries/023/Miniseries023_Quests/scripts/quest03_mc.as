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
   
   [Embed(source="/_assets/assets.swf", symbol="symbol97")]
   public dynamic class quest03_mc extends MovieClip
   {
      
      public var __motion_panelBottomAssets_mcExport3D1:MotionBase;
      
      public var panelBottomAssets_mc:MovieClip;
      
      public var panelTop_mc:MovieClip;
      
      public var __animFactory_panelBottomAssets_mcExport3D1:AnimatorFactory3D;
      
      public var ____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_:Vector.<Number>;
      
      public var __animFactory_panelTop_mcExport3D1:AnimatorFactory3D;
      
      public var __motion_panelTop_mcExport3D1:MotionBase;
      
      public var exit_bt:SimpleButton;
      
      public var ____motion_panelTop_mcExport3D1_mat3DVec_0_:Vector.<Number>;
      
      public function quest03_mc()
      {
         super();
         if(this.__motion_panelTop_mcExport3D1 == null)
         {
            this.__motion_panelTop_mcExport3D1 = new MotionBase();
            this.__motion_panelTop_mcExport3D1.duration = 1;
            this.__motion_panelTop_mcExport3D1.overrideTargetTransform();
            this.__motion_panelTop_mcExport3D1.addPropertyArray("blendMode",["layer"]);
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_ = new Vector.<Number>(16);
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[0] = 1;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[1] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[2] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[3] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[4] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[5] = 0.878966;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[6] = 0.235518;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[7] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[8] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[9] = -0.258819;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[10] = 0.965926;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[11] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[12] = 397.450012;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[13] = 361.120697;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[14] = 21.870211;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[15] = 1;
            this.__motion_panelTop_mcExport3D1.addPropertyArray("matrix3D",new Array(new Matrix3D(this.____motion_panelTop_mcExport3D1_mat3DVec_0_)));
            this.__animFactory_panelTop_mcExport3D1 = new AnimatorFactory3D(this.__motion_panelTop_mcExport3D1);
            this.__animFactory_panelTop_mcExport3D1.sceneName = "quest03_mc";
            this.__animFactory_panelTop_mcExport3D1.addTargetInfo(this,"panelTop_mc",0,true,0,true,null);
         }
         if(this.__motion_panelBottomAssets_mcExport3D1 == null)
         {
            this.__motion_panelBottomAssets_mcExport3D1 = new MotionBase();
            this.__motion_panelBottomAssets_mcExport3D1.duration = 1;
            this.__motion_panelBottomAssets_mcExport3D1.overrideTargetTransform();
            this.__motion_panelBottomAssets_mcExport3D1.addPropertyArray("blendMode",["normal"]);
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_ = new Vector.<Number>(16);
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[0] = 1;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[1] = 0;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[2] = 0;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[3] = 0;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[4] = 0;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[5] = 0.984808;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[6] = -0.173648;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[7] = 0;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[8] = 0;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[9] = 0.173648;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[10] = 0.984808;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[11] = 0;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[12] = 150.25;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[13] = 412.004883;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[14] = 23.485939;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[15] = 1;
            this.__motion_panelBottomAssets_mcExport3D1.addPropertyArray("matrix3D",new Array(new Matrix3D(this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_)));
            this.__animFactory_panelBottomAssets_mcExport3D1 = new AnimatorFactory3D(this.__motion_panelBottomAssets_mcExport3D1);
            this.__animFactory_panelBottomAssets_mcExport3D1.sceneName = "quest03_mc";
            this.__animFactory_panelBottomAssets_mcExport3D1.addTargetInfo(this,"panelBottomAssets_mc",0,true,0,true,null);
         }
      }
   }
}

