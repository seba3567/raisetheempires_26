package core.managers.worldEventManager
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.ui.interactiveClip.InteractiveClip;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class BaseWorldEvent
   {
      
      private var m_xml:XML = null;
      
      private var m_clip:MovieClip = null;
      
      private var m_added:Boolean = false;
      
      private var m_button:InteractiveClip = null;
      
      private var m_visible:Boolean = true;
      
      public function BaseWorldEvent(param1:XML)
      {
         super();
         this.m_xml = param1;
         Zlab.resourceManager.load(ZGlobal.getAssetURL("assets/ui/WorldEvent.swf"),SWFResource,this.onLoadComplete,this.onLoadFail);
         UIDispatcher.instance.addEventListener(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,this.onIslandModeActive);
      }
      
      public function dispose() : void
      {
         if(this.m_clip)
         {
            this.hideComplete();
            this.m_clip.parent.removeChild(this.m_clip);
            this.m_button.dispose();
            this.m_button = null;
            this.m_clip = null;
         }
         UIDispatcher.instance.removeEventListener(UIDispatcher.UI_PLAYER_ISLAND_MODE_ACTIVE,this.onIslandModeActive);
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         this.m_clip = param1.clip;
         this.addClip();
      }
      
      protected function addClip() : void
      {
         this.m_added = true;
         this.m_clip.x = 150;
         this.m_clip.y = -this.m_clip.height;
         this.m_clip.visible = this.m_visible;
         if(this.m_clip.visible)
         {
            this.show();
         }
         this.m_button = new InteractiveClip(this.m_clip,this.onClicked);
         this.setDesc();
         if(this.m_xml.@icon != undefined)
         {
            ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_xml.@icon),this.clip.icon);
         }
         PlayerStatsUIItem.getPlayerStats().addChild(this.m_clip);
      }
      
      protected function get xml() : XML
      {
         return this.m_xml;
      }
      
      protected function get clip() : MovieClip
      {
         return this.m_clip.screen;
      }
      
      public function get data() : String
      {
         return null;
      }
      
      protected function setDesc() : void
      {
      }
      
      protected function onClicked() : void
      {
      }
      
      private function onLoadFail(param1:SWFResource) : void
      {
         Logger.print(this,"Failed to load \'" + param1.filename + "\'");
      }
      
      private function onIslandModeActive(param1:WorldEvent) : void
      {
         this.m_visible = param1.eventData.active;
         if(this.m_clip)
         {
            this.m_clip.visible = this.m_visible;
            if(this.m_visible)
            {
               this.show();
            }
            else
            {
               this.hideComplete();
            }
         }
      }
      
      protected function show() : void
      {
         this.m_clip.y = -this.m_clip.height;
         Zlab.processManager.schedule(1000,this,this.slideToShow);
      }
      
      private function slideToShow() : void
      {
         this.m_clip.visible = true;
         TweenLite.to(this.m_clip,1,{"y":53});
         Zlab.processManager.schedule(1000 + 15000,this,this.hide);
      }
      
      protected function hide() : void
      {
         TweenLite.to(this.m_clip,1,{
            "y":-this.m_clip.height,
            "onComplete":this.hideComplete
         });
      }
      
      protected function hideComplete() : void
      {
         Zlab.processManager.removeScheduledObject(this,this.slideToShow);
         Zlab.processManager.removeScheduledObject(this,this.hide);
         TweenLite.killTweensOf(this.m_clip);
         this.m_clip.visible = false;
      }
      
      public function showParClock() : void
      {
      }
      
      public function hideParClock() : void
      {
      }
   }
}

