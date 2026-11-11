package core.entities.components
{
   import core.ZGlobal;
   import core.managers.BountyCenterManager;
   import core.player.IPVPPlayer;
   import core.ui.components.PortraitSlidePick.PortraitSlidePick;
   import displays.popups.GenericCountdownClock;
   import fl.containers.UILoader;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class BountyCenterPick extends PortraitSlidePick
   {
      
      protected var m_pickClass:Class;
      
      protected var m_clock:GenericCountdownClock;
      
      public function BountyCenterPick(param1:Number, param2:Class)
      {
         this.m_pickClass = param2;
         super(null,param1);
      }
      
      override protected function getPickClass() : Class
      {
         return this.m_pickClass;
      }
      
      override protected function onCreatePickAsset(param1:IPVPPlayer) : void
      {
         if(m_pick.card_mc.clock_mc)
         {
            this.m_clock = new GenericCountdownClock(m_pick.card_mc.clock_mc,BountyCenterManager.instance.activatedTimeRemaining + GlobalEngine.serverTime / 1000);
         }
         if(m_pick.bubble.generic_tf)
         {
            m_pick.bubble.generic_tf.visible = false;
         }
         TextFieldUtil.compactTextField(m_pick.card_mc.title_tf,ZGameUtils.ZlocT("Dialogs","ActivatedGuitarPickName"));
         if(m_pick.bubble.action_icon)
         {
            m_pick.bubble.action_icon.visible = false;
         }
         if(m_pick.bubble.bubble_mc)
         {
            m_pick.bubble.bubble_mc.visible = false;
         }
         if(m_pick.bubble.player.mindControlSwirl_mc)
         {
            m_pick.bubble.player.mindControlSwirl_mc.visible = false;
         }
         if(m_pick.card_mc.title01_tf)
         {
            m_pick.card_mc.title01_tf.visible = false;
         }
         if(m_pick.card_mc.title02_tf)
         {
            m_pick.card_mc.title02_tf.visible = false;
         }
         if(m_pick.card_mc.green_btn_0)
         {
            m_pick.card_mc.green_btn_0.visible = false;
         }
         if(m_pick.card_mc.green_btn_1)
         {
            m_pick.card_mc.green_btn_1.visible = false;
         }
         if(m_pick.card_mc.green_btn_2)
         {
            m_pick.card_mc.green_btn_2.visible = false;
         }
         if(m_pick.card_mc.orange_btn)
         {
            m_pick.card_mc.orange_btn.visible = false;
         }
      }
      
      override protected function getPortraitURL(param1:IPVPPlayer) : String
      {
         return ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/LibertyBond_48.png");
      }
      
      override protected function get neighborID() : String
      {
         return "0";
      }
      
      override protected function get portraitUILoader() : UILoader
      {
         return portraitBubble.player.portrait_mc;
      }
      
      override protected function get yOffset() : int
      {
         return -100;
      }
      
      override protected function setPickZoom(param1:Number) : void
      {
         var _loc2_:Number = 0.8 / param1;
         m_pick.scaleX = m_pick.scaleY = _loc2_;
      }
   }
}

