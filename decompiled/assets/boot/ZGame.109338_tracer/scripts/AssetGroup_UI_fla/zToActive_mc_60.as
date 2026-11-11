package AssetGroup_UI_fla
{
   import fl.motion.AnimatorFactory3D;
   import fl.motion.MotionBase;
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol2058")]
   public dynamic class zToActive_mc_60 extends MovieClip
   {
      
      public var __animFactory_zButtonExport3D1:AnimatorFactory3D;
      
      public var __motion_zButtonExport3D1:MotionBase;
      
      public var __initial3DPosition_activeLoader_mcExport3D1_:Array;
      
      public var zButton:MovieClip;
      
      public var __animFactory_activeLoader_mcExport3D1:AnimatorFactory3D;
      
      public var __motion_activeLoader_mcExport3D1:MotionBase;
      
      public var activeLoader_mc:MovieClip;
      
      public var __initial3DPosition_zButtonExport3D1_:Array;
      
      public function zToActive_mc_60()
      {
         super();
         addFrameScript(8,this.frame9);
         if(this.__motion_zButtonExport3D1 == null)
         {
            this.__motion_zButtonExport3D1 = new MotionBase();
            this.__motion_zButtonExport3D1.duration = 5;
            this.__motion_zButtonExport3D1.overrideTargetTransform();
            this.__motion_zButtonExport3D1.addPropertyArray("x",[0]);
            this.__motion_zButtonExport3D1.addPropertyArray("y",[0]);
            this.__motion_zButtonExport3D1.addPropertyArray("scaleX",[1]);
            this.__motion_zButtonExport3D1.addPropertyArray("scaleY",[1]);
            this.__motion_zButtonExport3D1.addPropertyArray("skewX",[0]);
            this.__motion_zButtonExport3D1.addPropertyArray("skewY",[0]);
            this.__motion_zButtonExport3D1.addPropertyArray("z",[0]);
            this.__motion_zButtonExport3D1.addPropertyArray("rotationX",[0]);
            this.__motion_zButtonExport3D1.addPropertyArray("rotationY",[0,22.5,45,67.5,90]);
            this.__motion_zButtonExport3D1.addPropertyArray("rotationZ",[0]);
            this.__motion_zButtonExport3D1.addPropertyArray("blendMode",["normal"]);
            this.__animFactory_zButtonExport3D1 = new AnimatorFactory3D(this.__motion_zButtonExport3D1);
            this.__animFactory_zButtonExport3D1.sceneName = "zToActive_mc";
            this.__initial3DPosition_zButtonExport3D1_ = new Array(0,0,0);
            this.__animFactory_zButtonExport3D1.addTargetInfo(this,"zButton",0,true,0,true,this.__initial3DPosition_zButtonExport3D1_);
         }
         if(this.__motion_activeLoader_mcExport3D1 == null)
         {
            this.__motion_activeLoader_mcExport3D1 = new MotionBase();
            this.__motion_activeLoader_mcExport3D1.duration = 9;
            this.__motion_activeLoader_mcExport3D1.overrideTargetTransform();
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("x",[0,0,0,0,0,0,0,0,0]);
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("y",[0,0,0,0,0,0,0,0,0]);
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("scaleX",[1,1,1,1,1,1,1,1,1]);
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("scaleY",[1,1,1,1,1,1,1,1,1]);
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("skewX",[0,0,0,0,0,0,0,0,0]);
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("skewY",[0,0,0,0,0,0,0,0,0]);
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("z",[0,0,0,0,0,0,0,0,0]);
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("rotationX",[0]);
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("rotationY",[0,-22.5,-45,-67.5,-90,-67.5,-45,-22.5,0]);
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("rotationZ",[0,0,0,0,0,0,0,0,0]);
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("blendMode",["normal"]);
            this.__motion_activeLoader_mcExport3D1.addPropertyArray("alphaMultiplier",[0,0,0,0,1]);
            this.__animFactory_activeLoader_mcExport3D1 = new AnimatorFactory3D(this.__motion_activeLoader_mcExport3D1);
            this.__animFactory_activeLoader_mcExport3D1.sceneName = "zToActive_mc";
            this.__initial3DPosition_activeLoader_mcExport3D1_ = new Array(0,0,0);
            this.__animFactory_activeLoader_mcExport3D1.addTargetInfo(this,"activeLoader_mc",0,true,0,true,this.__initial3DPosition_activeLoader_mcExport3D1_);
         }
      }
      
      internal function frame9() : *
      {
         stop();
      }
   }
}

