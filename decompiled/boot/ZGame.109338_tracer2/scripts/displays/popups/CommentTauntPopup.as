package displays.popups
{
   import core.ZGlobal;
   import core.managers.ChallengeModeManager;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class CommentTauntPopup extends CommentPopup
   {
      
      public function CommentTauntPopup(param1:Function = null, param2:Object = null, param3:String = "assets/displays/dialogs/PU_Taunt.swf")
      {
         super(param1,param2,param3);
      }
      
      override protected function setupText() : void
      {
         var _loc1_:String = "CommentTitle";
         var _loc2_:String = "CommentDesc";
         if(ZGlobal.isHome())
         {
            if(ChallengeModeManager.instance.isInChallengeBattle())
            {
               _loc1_ += "Win";
               _loc2_ += "Win";
            }
         }
         else if(ChallengeModeManager.instance.isInChallengeBattle())
         {
            if(ChallengeModeManager.instance.isNeighborAssist())
            {
               _loc1_ += "WhiteKnightWin";
               _loc2_ += "WhiteKnightWin";
            }
            else
            {
               _loc1_ += "Win";
               _loc2_ += "Win";
            }
         }
         TextFieldUtil.processTextField(m_window.popup_mc.title_tf,ZGameUtils.ZlocT("Dialogs",_loc1_));
         TextFieldUtil.processTextField(m_window.popup_mc.description_tf,ZGameUtils.ZlocT("Dialogs",_loc2_,{"num":m_maxChars}));
      }
   }
}

