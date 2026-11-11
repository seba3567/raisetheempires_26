package displays.popups
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.FightMeterManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class FightMeterBragPopup extends ZGamePopUp
   {
      
      private var m_shareBt:ZGameButton;
      
      private var m_okayBt:ZGameButton;
      
      private var m_fightMeterIconLoader:ImageLoader = null;
      
      public function FightMeterBragPopup()
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/FightMeterBrag.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.initDialog();
         addChild(m_window);
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.m_okayBt = new ZGameButton(this.screen.brag_bt,this.onClickOkay);
         this.m_shareBt = new ZGameButton(this.screen.share_bt,this.onClickBragAndShare);
         this.setupText();
      }
      
      private function setupText() : void
      {
         var _loc1_:String = "assets/game/GeneralAssetGroup_UI.swf/GreenEnergy_01_96.png";
         TextFieldUtil.compactTextField(this.screen.description_tf,ZGameUtils.ZlocT("Dialogs","FightMeterDescription"));
         TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","FightMeterHeader"));
         this.m_fightMeterIconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc1_),this.screen.icon);
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode("EN9",GameItem) as GameItem;
         if(_loc2_)
         {
            TextFieldUtil.compactTextField(this.screen.rewardName_tf,_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         }
         this.m_okayBt.text = ZGameUtils.ZlocT("Dialogs","Okay");
         this.m_shareBt.text = ZGameUtils.ZlocT("Dialogs","Share");
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function onClickOkay(param1:Event) : void
      {
         this.m_okayBt.dispose();
         super.close();
      }
      
      private function clearEvents() : void
      {
         if(this.m_shareBt)
         {
            this.m_shareBt.dispose();
         }
         if(this.m_okayBt)
         {
            this.m_okayBt.dispose();
         }
      }
      
      private function onClickBragAndShare(param1:Event) : void
      {
         this.clearEvents();
         close();
         var _loc2_:String = ZGlobal.player.name;
         var _loc3_:int = FightMeterManager.instance.levelTarget;
         ViralsManager.instance.sendFeed("FightMeter",{
            "player":_loc2_,
            "total":_loc3_
         },null);
      }
   }
}

