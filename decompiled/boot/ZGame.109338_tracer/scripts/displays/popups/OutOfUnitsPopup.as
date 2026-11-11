package displays.popups
{
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import fl.containers.UILoader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class OutOfUnitsPopup extends ZGamePopUp
   {
      
      private var m_shareBtn:ZGameButton = null;
      
      private var m_imageLoaders:Array = null;
      
      private var m_theater:String = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function OutOfUnitsPopup(param1:String)
      {
         this.m_theater = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_OutOfResources.swf"));
      }
      
      public static function display(param1:String) : void
      {
         WindowManager.instance.push(new OutOfUnitsPopup(param1));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         initDialog();
         var _loc2_:Class = param1.getAssetClass("MainScreen_mc");
         m_window = new _loc2_();
         addChild(m_window);
         this.contentWidth = m_window.frame_mc.width;
         this.contentHeight = m_window.frame_mc.height;
         centerWithinStage(Zlab.mainStage);
         TextFieldUtil.processTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","OutOfUnitsTitle"));
         TextFieldUtil.processTextField(m_window.bubble_tf,ZGameUtils.ZlocT("Dialogs","OutOfUnitsDescription"));
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_shareBtn = new ZGameButton(m_window.accept_bt,this.onAccept);
         this.m_shareBtn.text = ZGameUtils.ZlocT("Dialogs","Continue");
         this.m_buttonSounds.addButton(this.m_shareBtn.m_overlay,ButtonSound.DEFAULT);
         m_window.exit_bt.visible = false;
         this.displayIcons(this.iconsForTheater(this.m_theater));
         TextFieldUtil.processTextField(m_window.desc_tf,this.instructionForTheater(this.m_theater));
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function dispose() : void
      {
         deinitDialog();
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_shareBtn.dispose();
         this.m_shareBtn = null;
         this.disposeLoaders();
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.dispose();
         super.close(param1);
      }
      
      private function addLoader(param1:String, param2:UILoader) : void
      {
         this.m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(param1),param2));
      }
      
      private function displayIcons(param1:Array) : void
      {
         this.disposeLoaders();
         this.m_imageLoaders = new Array();
         m_window.steps_2_mc.visible = m_window.steps_3_mc.visible = false;
         switch(param1.length)
         {
            case 2:
               m_window.steps_2_mc.visible = true;
               this.addLoader(param1[0],m_window.steps_2_mc.icon0_mc);
               this.addLoader(param1[1],m_window.steps_2_mc.icon1_mc);
               break;
            case 3:
               m_window.steps_3_mc.visible = true;
               this.addLoader(param1[0],m_window.steps_3_mc.icon0_mc);
               this.addLoader(param1[1],m_window.steps_3_mc.icon1_mc);
               this.addLoader(param1[2],m_window.steps_3_mc.icon2_mc);
         }
      }
      
      private function disposeLoaders() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_imageLoaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_imageLoaders = null;
      }
      
      protected function onAccept(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function iconsForTheater(param1:String) : Array
      {
         switch(param1)
         {
            case UnitItem.AIR:
               return ["assets/game/quests/Quests_Icons_0.swf/AirForceFactoryLvl01_96.png","assets/game/quests/Quests_Icons_0.swf/AirFighterLvl01_96.png"];
            case UnitItem.NAVY:
               return ["assets/game/quests/Quests_Icons_0.swf/NavyFactoryLvl01_96.png","assets/game/quests/Quests_Icons_0.swf/SeaAntiShipLvl01_96.png"];
            default:
               return ["assets/game/quests/Quests_Icons_0.swf/ArmyFactoryLvl01_96.png","assets/game/quests/Quests_Icons_0.swf/LandAntiTankLvl01_96.png"];
         }
      }
      
      private function instructionForTheater(param1:String) : String
      {
         switch(param1)
         {
            case UnitItem.AIR:
               return ZGameUtils.ZlocT("Dialogs","OutOfUnitsAirInstruction");
            case UnitItem.NAVY:
               return ZGameUtils.ZlocT("Dialogs","OutOfUnitsNavyInstruction");
            default:
               return ZGameUtils.ZlocT("Dialogs","OutOfUnitsArmyInstruction");
         }
      }
   }
}

