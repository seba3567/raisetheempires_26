package displays.popups.miniSeriesDialogBubble
{
   import core.ZGlobal;
   import core.gameobjects.HookItem;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MiniSeriesDialogBubble extends GallantPopup
   {
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_callback:Function = null;
      
      private var m_userData:String = null;
      
      private var m_button:ZGameButton = null;
      
      private var m_loader:ImageLoader = null;
      
      private var m_advisorId:String = null;
      
      private var m_iconImageLoader:ImageLoader = null;
      
      public function MiniSeriesDialogBubble(param1:Function, param2:String, param3:String = null)
      {
         this.m_callback = param1;
         this.m_userData = param2;
         this.m_advisorId = param3;
         var _loc4_:HookItem = ZGlobal.gameSettings.getItemByCode(this.m_userData,HookItem) as HookItem;
         super(ZGlobal.getAssetURL(_loc4_.url));
      }
      
      override protected function initializeScreen() : void
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         super.initializeScreen();
         var _loc1_:HookItem = ZGlobal.gameSettings.getItemByCode(this.m_userData,HookItem) as HookItem;
         var _loc2_:Object = ZGameUtils.callFunctionFromXml(_loc1_.textReplacements);
         TextFieldUtil.compactTextField(this.screen.generic_tf,ZGameUtils.localizedStringForToken(_loc1_.text,null,_loc2_),{
            "minScale":0.65,
            "maxLines":8
         });
         if(_loc1_.isMegaseries)
         {
            _loc3_ = _loc1_.megaseriesDialgoText;
            TextFieldUtil.compactTextField(this.screen.generic_tf,ZGameUtils.ZlocT("Megaseries",String(_loc3_[0]).split(":")[1]));
            TextFieldUtil.compactTextField(this.screen.generic_tf1,ZGameUtils.ZlocT("Megaseries",String(_loc3_[1]).split(":")[1]));
            TextFieldUtil.compactTextField(this.screen.generic_tf2,ZGameUtils.ZlocT("Megaseries",String(_loc3_[2]).split(":")[1]));
         }
         if(this.screen.restart_bt)
         {
            this.m_button = new ZGameButton(this.screen.restart_bt,this.onExit);
         }
         else if(this.screen.exit_bt)
         {
            this.m_button = new ZGameButton(this.screen.exit_bt,this.onExit);
         }
         this.m_button.text = ZGameUtils.ZlocT("QuestTrees","GoNow");
         if(this.screen.restart_bt)
         {
            this.screen.exit_bt.visible = false;
         }
         if(this.screen.playerIcon)
         {
            _loc4_ = ZGameUtils.callFunctionFromXml(_loc1_.playerImage);
            if((Boolean(_loc4_)) && _loc4_ != "")
            {
               this.m_iconImageLoader = ImageLoaderFactory.CreateImageLoader(_loc4_,this.screen.playerIcon);
               this.m_iconImageLoader.smooth = true;
            }
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
      }
      
      override protected function deinitDialog() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_button.dispose();
         this.m_button = null;
         if(this.m_loader)
         {
            this.m_loader.destroy();
         }
         if(this.m_iconImageLoader)
         {
            this.m_iconImageLoader.destroy();
         }
         super.deinitDialog();
      }
      
      protected function get screen() : MovieClip
      {
         return m_window.window_mc;
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         close();
         this.m_callback(this.m_userData);
      }
   }
}

