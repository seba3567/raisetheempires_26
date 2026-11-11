package core.ui.menuitem
{
   import displays.ImageLoaderFactory;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   
   public class PlayerStatsIcon extends PlayerStatsIconBase
   {
      
      private var m_iconImage:String;
      
      public function PlayerStatsIcon(param1:MovieClip, param2:Number, param3:Number, param4:Number, param5:Number, param6:String = null)
      {
         super(param1,param2,param3,param4,param5);
         this.m_iconImage = param6;
         if(this.m_iconImage != null)
         {
            ImageLoaderFactory.CreateImageLoader(this.m_iconImage,iconMC.imageHolder_mc,this.onImageLoaded);
         }
      }
      
      private function onImageLoaded(param1:String, param2:BitmapData) : void
      {
         m_origWidth = param2.width;
         m_origHeight = param2.height;
      }
   }
}

