package core.gamemode.mission
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.ui.menuitem.OptionUIItem;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.MissionContractsScreen;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.PU_SpecialForces_Deploy.DeployPanel;
   import zlabs.ZGameBase;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   
   public class StrikeTeamDeployPanel
   {
      
      private var m_window:MovieClip = null;
      
      protected var m_initialized:Boolean = false;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_iconLoader:ImageLoader = null;
      
      private var m_strikeTeam:GameItem = null;
      
      public function StrikeTeamDeployPanel()
      {
         super();
         this.m_window = new DeployPanel();
         Zlab.mainStage.addEventListener(Event.RESIZE,this.onReposition);
      }
      
      public function dispose() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_window.mission_bt.removeEventListener(MouseEvent.CLICK,this.onChangeMission);
         this.m_window.exit_btn.removeEventListener(MouseEvent.CLICK,this.onChangeMission);
         this.m_iconLoader.destroy();
         this.m_iconLoader = null;
         Zlab.mainStage.removeEventListener(Event.RESIZE,this.onReposition);
      }
      
      private function onReposition(param1:Event) : void
      {
         if(this.m_window)
         {
            this.m_window.x = (Zlab.mainStage.stageWidth - this.m_window.width) / 2;
            this.m_window.y = Zlab.mainStage.stageHeight - 2 * this.m_window.height - 8;
         }
      }
      
      public function addPanel(param1:GameItem) : void
      {
         this.m_strikeTeam = param1;
         this.setUpScreen();
         this.onReposition(new Event(Event.RESIZE));
         ZGameBase.layerPopUp.addChild(this.m_window);
      }
      
      public function removePanel() : void
      {
         ZGameBase.layerPopUp.removeChild(this.m_window);
      }
      
      protected function setUpScreen() : void
      {
         if(!this.m_window || this.m_initialized)
         {
            return;
         }
         this.m_initialized = true;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_window.mission_btn.addEventListener(MouseEvent.CLICK,this.onChangeMission,false,0,true);
         TextFieldUtil.processTextField(this.m_window.mission_btn.generic_tf,ZGameUtils.ZlocT("Dialogs","Back"));
         this.m_buttonSounds.addButton(this.m_window.mission_btn,ButtonSound.DEFAULT);
         this.m_window.exit_btn.addEventListener(MouseEvent.CLICK,this.onExitButton,false,0,true);
         TextFieldUtil.processTextField(this.m_window.exit_btn.generic_tf,ZGameUtils.ZlocT("Dialogs","Close"));
         this.m_buttonSounds.addButton(this.m_window.exit_btn,ButtonSound.DEFAULT);
         this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(this.m_strikeTeam.getCachedImage("pickIcon").url,this.m_window.deployCard_mc.icon_mc);
         this.m_iconLoader.smooth = true;
         var _loc1_:int = ZGlobal.player.getNumberOfInventoryItems(this.m_strikeTeam.code);
         TextFieldUtil.processTextField(this.m_window.deployCard_mc.qty_tf,_loc1_.toString());
         TextFieldUtil.processTextField(this.m_window.deployName_tf,this.m_strikeTeam.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         this.m_window.deployText_tf.visible = false;
      }
      
      private function onChangeMission(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new Event(OptionUIItem.EXIT));
         UIDispatcher.instance.dispatchEvent(new WorldEvent(MissionContractsScreen.SHOW_MISSIONCONTRACTS_DIALOG));
      }
      
      private function onExitButton(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new Event(OptionUIItem.EXIT));
      }
      
      protected function textInput(param1:TextEvent) : void
      {
         var _loc2_:String = ZGlobal.gameSettings.getString("invalidNameCharacters");
         var _loc3_:String = param1.text;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            if(_loc3_ == _loc2_.substr(_loc4_,1))
            {
               param1.preventDefault();
            }
            _loc4_++;
         }
      }
   }
}

