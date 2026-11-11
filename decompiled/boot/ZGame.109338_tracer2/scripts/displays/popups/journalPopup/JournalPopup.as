package displays.popups.journalPopup
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.IslandGroupItem;
   import core.managers.WorldResourceManager;
   import core.worlds.strategicWorld.StrategicMap;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.cinema.IntroReplayCinematics;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.BlurFilter;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.WindowManager;
   
   public class JournalPopup extends GallantPopup
   {
      
      private static var m_textPos:Number = 0;
      
      private var m_loaders:Array = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_episodes:Dictionary = null;
      
      private var m_activeCards:Array = null;
      
      public function JournalPopup()
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Journal.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
         TextFieldUtil.processTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","Journal_Title"));
         this.m_loaders = new Array();
         this.m_episodes = new Dictionary();
         this.m_activeCards = new Array();
         this.screen.zoomscreen.visible = false;
         this.screen.zoomscreen.exit_bt.addEventListener(MouseEvent.CLICK,this.onCloseZoomScreen);
         this.m_buttonSounds.addButton(this.screen.zoomscreen.exit_bt,ButtonSound.DEFAULT);
         this.setUpMovie();
         this.loadIcons();
         if(m_textPos == 0)
         {
            m_textPos = this.screen.zoomscreen.description_tf.y;
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:EventDispatcher = null;
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
         for each(_loc2_ in this.m_activeCards)
         {
            _loc2_.removeEventListener(MouseEvent.CLICK,this.onIconClicked);
            _loc2_.removeEventListener(MouseEvent.CLICK,this.onMovieIcon);
         }
         this.m_activeCards = null;
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.screen.zoomscreen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCloseZoomScreen);
         super.deinitDialog();
      }
      
      private function setUpMovie() : void
      {
         var _loc1_:String = "card0";
         var _loc2_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/images/ui/Episodes/Journal.swf/Intro.png"),this.screen.cards_mc[_loc1_].icon);
         this.m_loaders.push(_loc2_);
         this.screen.cards_mc[_loc1_].buttonMode = true;
         this.screen.cards_mc[_loc1_].useHandCursor = true;
         this.screen.cards_mc[_loc1_].icon.addEventListener(MouseEvent.CLICK,this.onMovieIcon);
         this.m_activeCards.push(this.screen.cards_mc[_loc1_].icon);
         this.m_buttonSounds.addButton(this.screen.cards_mc[_loc1_].icon,ButtonSound.DEFAULT);
      }
      
      private function loadIcons() : void
      {
         var _loc3_:uint = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:IslandGroupItem = null;
         var _loc7_:StrategicMap = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:XML = null;
         var _loc11_:ImageLoader = null;
         var _loc1_:Dictionary = new Dictionary();
         var _loc2_:XML = null;
         for each(_loc2_ in ZGlobal.gameSettings.getXML().episodes.episode)
         {
            _loc4_ = _loc2_.@id;
            _loc5_ = _loc2_.@journalUnlock;
            if(_loc5_)
            {
               _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc5_,IslandGroupItem) as IslandGroupItem;
               _loc7_ = ZGlobal.player.campaign.getMap(_loc5_);
               _loc1_[_loc4_] = _loc7_.progressIsland >= _loc6_.numIslands;
            }
            else
            {
               _loc1_[_loc4_] = true;
            }
         }
         _loc3_ = 1;
         for each(_loc2_ in ZGlobal.gameSettings.getXML().episodes.episode)
         {
            _loc8_ = _loc2_.@id;
            _loc9_ = "card" + _loc3_.toString();
            _loc10_ = ZGlobal.gameSettings.getEpisodeData(_loc8_);
            this.m_episodes[_loc9_] = _loc10_;
            _loc11_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc10_.@thumb.toString()),this.screen.cards_mc[_loc9_].icon);
            this.m_loaders.push(_loc11_);
            if(!_loc1_[_loc8_])
            {
               this.screen.cards_mc[_loc9_].icon.filters = [new BlurFilter(8,8)];
               this.screen.cards_mc[_loc9_].transform.colorTransform = ZGameUtils.DarkerTransform;
            }
            else
            {
               this.screen.cards_mc[_loc9_].buttonMode = true;
               this.screen.cards_mc[_loc9_].useHandCursor = true;
               this.screen.cards_mc[_loc9_].icon.filters = [];
               this.screen.cards_mc[_loc9_].transform.colorTransform = ZGameUtils.ClearTransform;
               this.screen.cards_mc[_loc9_].icon.addEventListener(MouseEvent.CLICK,this.onIconClicked);
               this.m_activeCards.push(this.screen.cards_mc[_loc9_].icon);
               this.m_buttonSounds.addButton(this.screen.cards_mc[_loc9_].icon,ButtonSound.DEFAULT);
            }
            _loc3_++;
         }
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen;
      }
      
      private function onMovieIcon(param1:MouseEvent) : void
      {
         var _loc2_:IntroReplayCinematics = new IntroReplayCinematics();
         WindowManager.instance.playCinematics(_loc2_);
      }
      
      private function onIconClicked(param1:MouseEvent) : void
      {
         this.screen.zoomscreen.visible = true;
         this.screen.exit_bt.visible = false;
         this.screen.title_tf.visible = false;
         var _loc2_:String = this.m_episodes[param1.currentTarget.parent.name].@icon;
         var _loc3_:ImageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc2_),this.screen.zoomscreen.iconLoader);
         this.m_loaders.push(_loc3_);
         TextFieldUtil.processTextField(this.screen.zoomscreen.title_tf,ZGameUtils.ZlocT("Episodes",this.m_episodes[param1.currentTarget.parent.name].@title));
         var _loc4_:String = WorldResourceManager.instance.getResourceFriendlyNameFromIndex(ZGlobal.player.rareResourceType,GameItem.MENU_FRIENDLYNAME);
         var _loc5_:Object = {
            "empire_name":ZGlobal.player.worldName,
            "user_name":ZGlobal.player.firstName,
            "rare":_loc4_
         };
         TextFieldUtil.processTextField(this.screen.zoomscreen.description_tf,ZGameUtils.ZlocT("Episodes",this.m_episodes[param1.currentTarget.parent.name].@desc,_loc5_));
         ZGameUtils.alignTextVertically(this.screen.zoomscreen.description_tf,null,m_textPos);
      }
      
      private function onCloseZoomScreen(param1:MouseEvent) : void
      {
         this.screen.zoomscreen.iconLoader.unload();
         this.screen.zoomscreen.visible = false;
         this.screen.exit_bt.visible = true;
         this.screen.title_tf.visible = true;
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         close();
      }
   }
}

