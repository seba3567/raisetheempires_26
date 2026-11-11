package Miniseries025_Main_fla
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
   
   [Embed(source="/_assets/assets.swf", symbol="symbol105")]
   public dynamic class DailyQuest_mc_1 extends MovieClip
   {
      
      public var __motion_panelBottomAssets_mcExport3D1:MotionBase;
      
      public var panelBottomAssets_mc:MovieClip;
      
      public var __animFactory_reward_mcExport3D1:AnimatorFactory3D;
      
      public var __animFactory_panelTop_mcExport3D1:AnimatorFactory3D;
      
      public var __animFactory_panelBottomAssets_mcExport3D1:AnimatorFactory3D;
      
      public var exit_bt:SimpleButton;
      
      public var ____motion_panelTop_mcExport3D1_mat3DVec_0_:Vector.<Number>;
      
      public var playAgain_shadow_mc:MovieClip;
      
      public var panelTop_mc:MovieClip;
      
      public var playAgain_bt:MovieClip;
      
      public var reward_mc:MovieClip;
      
      public var ____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_:Vector.<Number>;
      
      public var __motion_reward_mcExport3D1:MotionBase;
      
      public var __motion_panelTop_mcExport3D1:MotionBase;
      
      public var maxPlays_tf:TextField;
      
      public var ____motion_reward_mcExport3D1_mat3DVec_0_:Vector.<Number>;
      
      public function DailyQuest_mc_1()
      {
         super();
         if(this.__motion_panelTop_mcExport3D1 == null)
         {
            this.__motion_panelTop_mcExport3D1 = new MotionBase();
            this.__motion_panelTop_mcExport3D1.duration = 1;
            this.__motion_panelTop_mcExport3D1.overrideTargetTransform();
            this.__motion_panelTop_mcExport3D1.addPropertyArray("blendMode",["normal"]);
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_ = new Vector.<Number>(16);
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[0] = 1;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[1] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[2] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[3] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[4] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[5] = 0.869327;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[6] = 0.232936;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[7] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[8] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[9] = -0.258819;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[10] = 0.965926;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[11] = 0;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[12] = 293.75;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[13] = 185.750793;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[14] = 21.261984;
            this.____motion_panelTop_mcExport3D1_mat3DVec_0_[15] = 1;
            this.__motion_panelTop_mcExport3D1.addPropertyArray("matrix3D",new Array(new Matrix3D(this.____motion_panelTop_mcExport3D1_mat3DVec_0_)));
            this.__animFactory_panelTop_mcExport3D1 = new AnimatorFactory3D(this.__motion_panelTop_mcExport3D1);
            this.__animFactory_panelTop_mcExport3D1.sceneName = "DailyQuest_mc";
            this.__animFactory_panelTop_mcExport3D1.addTargetInfo(this,"panelTop_mc",0,true,0,true,null);
         }
         if(this.__motion_reward_mcExport3D1 == null)
         {
            this.__motion_reward_mcExport3D1 = new MotionBase();
            this.__motion_reward_mcExport3D1.duration = 1;
            this.__motion_reward_mcExport3D1.overrideTargetTransform();
            this.__motion_reward_mcExport3D1.addPropertyArray("blendMode",["normal"]);
            this.____motion_reward_mcExport3D1_mat3DVec_0_ = new Vector.<Number>(16);
            this.____motion_reward_mcExport3D1_mat3DVec_0_[0] = 1;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[1] = 0;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[2] = 0;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[3] = 0;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[4] = 0;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[5] = 0.990268;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[6] = -0.139173;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[7] = 0;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[8] = 0;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[9] = 0.139173;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[10] = 0.990268;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[11] = 0;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[12] = 500.450012;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[13] = 300.200378;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[14] = 25.74703;
            this.____motion_reward_mcExport3D1_mat3DVec_0_[15] = 1;
            this.__motion_reward_mcExport3D1.addPropertyArray("matrix3D",new Array(new Matrix3D(this.____motion_reward_mcExport3D1_mat3DVec_0_)));
            this.__animFactory_reward_mcExport3D1 = new AnimatorFactory3D(this.__motion_reward_mcExport3D1);
            this.__animFactory_reward_mcExport3D1.sceneName = "DailyQuest_mc";
            this.__animFactory_reward_mcExport3D1.addTargetInfo(this,"reward_mc",0,true,0,true,null);
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
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[12] = 33.650002;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[13] = 196.472687;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[14] = 35.120346;
            this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_[15] = 1;
            this.__motion_panelBottomAssets_mcExport3D1.addPropertyArray("matrix3D",new Array(new Matrix3D(this.____motion_panelBottomAssets_mcExport3D1_mat3DVec_0_)));
            this.__animFactory_panelBottomAssets_mcExport3D1 = new AnimatorFactory3D(this.__motion_panelBottomAssets_mcExport3D1);
            this.__animFactory_panelBottomAssets_mcExport3D1.sceneName = "DailyQuest_mc";
            this.__animFactory_panelBottomAssets_mcExport3D1.addTargetInfo(this,"panelBottomAssets_mc",0,true,0,true,null);
         }
      }
   }
}

