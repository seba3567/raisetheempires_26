package PU_Letter_fla
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol58")]
   public dynamic class dossier_mc_1 extends MovieClip
   {
      
      public var villainPortrait_mc:MovieClip;
      
      public var height_tf:TextField;
      
      public var exit_bt:SimpleButton;
      
      public var role2_tf:TextField;
      
      public var stamp_mc:MovieClip;
      
      public var generic_tf:TextField;
      
      public var role_tf:TextField;
      
      public var accept_bt:MovieClip;
      
      public var name_tf:TextField;
      
      public var hint_tf:TextField;
      
      public var age_tf:TextField;
      
      public var title_tf:TextField;
      
      public function dossier_mc_1()
      {
         super();
         addFrameScript(11,this.frame12);
      }
      
      internal function frame12() : *
      {
         stop();
      }
   }
}

