package displays.popups
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.player.IPVPPlayer;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import transactions.TSeenStrikeTeamComment;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class SpecialForcesMissionNoticePopup extends GallantPopup
   {
      
      private var m_description:String;
      
      private var m_title:String;
      
      private var m_okButton:ZGameButton;
      
      private var m_portraitLoader:ImageLoader;
      
      private var m_iconLoader:ImageLoader;
      
      private var m_victim:IPVPPlayer;
      
      private var m_missionCode:String;
      
      private var m_comment:String;
      
      public function SpecialForcesMissionNoticePopup(param1:String, param2:String, param3:IPVPPlayer, param4:String, param5:String)
      {
         this.m_description = param1;
         this.m_title = param2;
         this.m_victim = param3;
         this.m_missionCode = param4;
         this.m_comment = param5;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_SpecialForces_Notice.swf"));
      }
      
      private function get mc() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      override protected function initializeScreen() : void
      {
         var _loc3_:String = null;
         super.initializeScreen();
         TextFieldUtil.processTextField(this.mc.green_bt.generic_tf,ZGameUtils.ZlocT("Dialogs","Okay"));
         this.m_okButton = new ZGameButton(this.mc.green_bt,this.exitButtonClicked);
         TextFieldUtil.processTextField(this.mc.description_tf,this.m_description);
         TextFieldUtil.processTextField(this.mc.message_tf,this.m_comment);
         TextFieldUtil.processTextField(this.mc.title_tf,this.m_title);
         TextFieldUtil.processTextField(this.mc.icon_0.name_tf,this.m_victim.firstName);
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByCode(this.m_missionCode,GameItem) as GameItem;
         if(_loc1_)
         {
            _loc3_ = ZGlobal.gameSettings.getImageByName(_loc1_.name,"icon");
            this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(_loc3_,this.mc.icon);
         }
         var _loc2_:String = this.m_victim.portraitURL;
         this.m_portraitLoader = ImageLoaderFactory.CreateImageLoader(_loc2_,this.mc.icon_0.portrait_mc);
         this.contentWidth = this.mc.bg_mc.width;
         this.contentHeight = this.mc.bg_mc.height;
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         StatsManager.count("dialog","specialforces","taunt_receive",this.m_missionCode);
         TransactionManager.addTransaction(new TSeenStrikeTeamComment(this.m_victim.uid),true);
      }
      
      override protected function close(param1:Event = null) : void
      {
         if(this.m_okButton)
         {
            this.m_okButton.dispose();
            this.m_okButton = null;
         }
         this.mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         super.close();
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         this.close();
      }
   }
}

