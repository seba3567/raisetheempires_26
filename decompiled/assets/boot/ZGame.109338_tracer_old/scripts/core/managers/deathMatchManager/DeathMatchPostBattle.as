package core.managers.deathMatchManager
{
   import core.gamemode.GameModeManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import displays.popups.battlewon.BattleWonPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class DeathMatchPostBattle extends BattleWonPopup
   {
      
      private var assetUrl:String = "assets/displays/dialogs/PU_LiveCombatVictory.swf";
      
      private var m_win:Boolean = false;
      
      private var m_score:Number = 0;
      
      private var m_buttons:Array;
      
      public function DeathMatchPostBattle(param1:Boolean, param2:Number, param3:Array, param4:Dictionary)
      {
         this.m_win = param1;
         this.m_score = param2;
         super(param3,param4);
      }
      
      override protected function assetStr() : String
      {
         return this.assetUrl;
      }
      
      private function setupUI() : void
      {
         this.m_buttons = new Array();
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.close);
         if(this.m_win)
         {
            TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","FirstVictoryTitle"));
            this.screen.points_tf.visible = true;
            TextFieldUtil.compactTextField(this.screen.orangeButton_01.generic_tf,ZGameUtils.ZlocT("Dialogs","Share"));
            this.m_buttons.push(new ZGameButton(this.screen.orangeButton_01,this.onButtonClicked));
            this.screen.orangeButton_01.visible = true;
            this.screen.glow_mc.visible = true;
            this.screen.starburst_mc.visible = true;
         }
         else
         {
            TextFieldUtil.compactTextField(this.screen.title_tf,ZGameUtils.ZlocT("Dialogs","DM_PostBattleLost"));
            this.screen.points_tf.visible = false;
            this.screen.orangeButton_01.visible = false;
            this.screen.glow_mc.visible = false;
            this.screen.starburst_mc.visible = false;
            this.screen.title02_tf.visible = false;
            this.screen.message_tf.visible = false;
         }
         TextFieldUtil.compactTextField(this.screen.frags_tf,ZGameUtils.ZlocT("Dialogs","DM_PBYourScore",{"x":this.m_score}));
      }
      
      override protected function setUpPopupUI() : void
      {
         super.setUpPopupUI();
         this.setupUI();
      }
      
      override protected function onButtonClicked(param1:MouseEvent) : void
      {
         ViralsManager.instance.sendFeed("DMPostBattle",{});
         this.close();
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window.victoryCombo_mc;
      }
      
      override protected function allowUnitBuyBack() : Boolean
      {
         return true;
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.close);
         ViewManager.instance.goToView(IslandWorld.ID);
         GameModeManager.instance.setDefaultGameMode();
         super.close();
      }
   }
}

