package core.gamemode.prebattle
{
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.ZGameButton;
   import flash.display.MovieClip;
   import utils.TextFieldUtil;
   
   public class PreBattleFightButton extends ZGameButton
   {
      
      private static const FRAME_NORMAL:int = 1;
      
      private static const FRAME_PULSING:int = 2;
      
      public function PreBattleFightButton(param1:MovieClip, param2:Function = null, param3:Number = 1.1)
      {
         super(param1,param2,param3);
         TutorialManager.instance.addToUIElements(m_target.button_mc);
         TutorialManager.instance.registerUIItem(m_target.button_mc,"CombatFight");
      }
      
      override public function set text(param1:String) : void
      {
         super.text = param1;
         TextFieldUtil.processTextField(m_target.button_mc.glow_mc.generic_tf,param1);
      }
      
      override public function set pulse(param1:Boolean) : void
      {
         if(param1)
         {
            m_target.button_mc.gotoAndPlay(FRAME_PULSING);
         }
         else
         {
            m_target.button_mc.gotoAndStop(FRAME_NORMAL);
         }
      }
   }
}

