package core.entities.components
{
   import core.ZGlobal;
   import core.ui.UIManager;
   import core.ui.menuitem.SettingsUIItem;
   import core.views.ViewManager;
   import dispatchers.MessageDispatcher;
   import flash.events.Event;
   import zlabs.Zlab;
   import zlabs.components.LocalDataComponent;
   import zlabs.entity.EntityComponent;
   import zlabs.events.WorldEvent;
   import zlabs.sound.ISoundHandle;
   import zlabs.sound.SoundManager;
   
   public class WorldMusicComponent extends EntityComponent
   {
      
      private static var m_switchToUrl:String = null;
      
      private static var m_switchToHandle:ISoundHandle = null;
      
      private var m_name:String = null;
      
      private var m_handle:ISoundHandle = null;
      
      private var m_url:String = null;
      
      private var m_waitForLoadComplete:Boolean = false;
      
      public function WorldMusicComponent(param1:String, param2:Boolean)
      {
         super();
         this.m_name = param1;
         this.m_waitForLoadComplete = param2;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(ViewManager.ACTIVATE,this.onActivated);
         owner.eventDispatcher.addEventListener(ViewManager.DEACTIVATE,this.onDeactivated);
         if(this.m_waitForLoadComplete)
         {
            UIManager.instance.addEventListener(UIManager.UI_START_MUSIC,this.onTriggeredFromLoad);
         }
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(ViewManager.ACTIVATE,this.onActivated);
         owner.eventDispatcher.removeEventListener(ViewManager.DEACTIVATE,this.onDeactivated);
         UIManager.instance.removeEventListener(UIManager.UI_START_MUSIC,this.onTriggeredFromLoad);
      }
      
      private function onActivated(param1:Event) : void
      {
         if(!this.m_waitForLoadComplete)
         {
            MessageDispatcher.instance.addEventListener(SettingsUIItem.TOGGLE_MUSIC,this.onMusicToggled);
            this.start();
            m_switchToUrl = null;
            m_switchToHandle = null;
         }
      }
      
      private function onTriggeredFromLoad(param1:Event) : void
      {
         if(this.m_waitForLoadComplete)
         {
            UIManager.instance.removeEventListener(UIManager.UI_START_MUSIC,this.onTriggeredFromLoad);
            this.m_waitForLoadComplete = false;
            this.onActivated(param1);
         }
      }
      
      private function onDeactivated(param1:WorldEvent) : void
      {
         MessageDispatcher.instance.removeEventListener(SettingsUIItem.TOGGLE_MUSIC,this.onMusicToggled);
         var _loc2_:WorldMusicComponent = ViewManager.instance.getComponentFromView(param1.eventData as String,WorldMusicComponent) as WorldMusicComponent;
         if(Boolean(_loc2_) && _loc2_.hasSameURL(this))
         {
            m_switchToUrl = this.m_url;
            m_switchToHandle = this.m_handle;
         }
         else
         {
            this.stop();
         }
         this.m_url = null;
         this.m_handle = null;
      }
      
      private function onMusicToggled(param1:WorldEvent) : void
      {
         if(param1.eventData)
         {
            this.stop();
         }
         else
         {
            this.start();
         }
      }
      
      private function hasSameURL(param1:WorldMusicComponent) : Boolean
      {
         var _loc2_:XML = ZGlobal.gameSettings.getSoundXMLByName(this.m_name);
         var _loc3_:XML = ZGlobal.gameSettings.getSoundXMLByName(param1.m_name);
         return _loc2_["@url"] == _loc3_["@url"];
      }
      
      private function stop() : void
      {
         if(null != this.m_handle)
         {
            this.m_handle.stop();
            this.m_handle = null;
         }
      }
      
      private function start() : void
      {
         var _loc2_:XML = null;
         var _loc1_:Object = LocalDataComponent.getLocalData(SoundManager.MUSIC_MIXER_CATEGORY);
         if(_loc1_ == null || _loc1_ == false)
         {
            _loc2_ = ZGlobal.gameSettings.getSoundXMLByName(this.m_name);
            if(_loc2_)
            {
               this.m_url = _loc2_["@url"];
               if(this.m_url == m_switchToUrl)
               {
                  this.m_handle = m_switchToHandle;
               }
               else
               {
                  this.m_handle = Zlab.soundManager.stream(ZGlobal.getAssetURL(this.m_url),SoundManager.MUSIC_MIXER_CATEGORY,0,int.MAX_VALUE);
               }
            }
         }
      }
      
      private function onLoaded(param1:ISoundHandle) : void
      {
         this.m_handle = param1;
      }
   }
}

