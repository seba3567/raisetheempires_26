package
{
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol36")]
   public dynamic class ResourceCard extends MovieClip
   {
      
      public var locked_mc:MovieClip;
      
      public var detail_mc:MovieClip;
      
      public var highlightSelect_mc:MovieClip;
      
      public var build_bt:MovieClip;
      
      public var sizer_mc:MovieClip;
      
      public var level_tf:TextField;
      
      public var itemName_tf:TextField;
      
      public var buy_bt:MovieClip;
      
      public var icon:UILoader;
      
      public function ResourceCard()
      {
         super();
      }
   }
}

