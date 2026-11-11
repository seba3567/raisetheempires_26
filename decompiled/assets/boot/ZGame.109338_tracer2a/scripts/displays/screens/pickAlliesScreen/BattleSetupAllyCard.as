package displays.screens.pickAlliesScreen
{
   import core.player.IAlly;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   
   public class BattleSetupAllyCard
   {
      
      protected var m_clip:MovieClip = null;
      
      protected var m_ally:IAlly = null;
      
      protected var m_imageLoader:ImageLoader = null;
      
      public function BattleSetupAllyCard(param1:MovieClip)
      {
         super();
         this.m_clip = param1;
         this.displayAlly(null);
      }
      
      public function dispose() : void
      {
         this.releaseLoader();
         this.m_clip = null;
         this.m_ally = null;
      }
      
      public function get clip() : MovieClip
      {
         return this.m_clip;
      }
      
      public function get ally() : IAlly
      {
         return this.m_ally;
      }
      
      public function get sizer() : MovieClip
      {
         return this.m_clip.sizer_mc;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this.m_clip.visible = param1;
      }
      
      public function displayAlly(param1:IAlly, param2:Boolean = false) : void
      {
         if(Boolean(param1) && param1 == this.m_ally)
         {
            return;
         }
         this.releaseLoader();
         if(param1)
         {
            this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(param1.imageUrl,this.m_clip.allyIcon.icon);
         }
         this.m_ally = param1;
      }
      
      private function releaseLoader() : void
      {
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
      }
   }
}

