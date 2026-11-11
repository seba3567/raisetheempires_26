package
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol20")]
   public dynamic class card extends MovieClip
   {
      
      public var icon:UILoader;
      
      public var discount_tf:TextField;
      
      public var value_tf:TextField;
      
      public var sizer_mc:MovieClip;
      
      public var icon_01:UILoader;
      
      public var itemName_tf:TextField;
      
      public var ok_bt:MovieClip;
      
      public var generic_tf:TextField;
      
      public var underlay_mc:MovieClip;
      
      public function card()
      {
         super();
      }
   }
}

