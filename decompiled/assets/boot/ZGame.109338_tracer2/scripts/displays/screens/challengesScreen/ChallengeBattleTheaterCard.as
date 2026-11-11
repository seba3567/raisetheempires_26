package displays.screens.challengesScreen
{
   import core.gameobjects.UnitItem;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class ChallengeBattleTheaterCard
   {
      
      public static const THEATER_UNKNOWN:int = 0;
      
      public static const THEATER_LAND:int = 1;
      
      public static const THEATER_SEA:int = 2;
      
      public static const THEATER_AIR:int = 3;
      
      private var m_card:MovieClip;
      
      private var m_theater:int;
      
      private var m_battleType:String;
      
      public function ChallengeBattleTheaterCard(param1:MovieClip, param2:int)
      {
         super();
         this.m_card = param1;
         this.m_theater = param2;
         this.m_battleType = UnitItem.ARMY;
         this.m_card.img_air_mc.visible = false;
         this.m_card.img_land_mc.visible = false;
         this.m_card.img_sea_mc.visible = false;
         var _loc3_:String = "";
         switch(this.m_theater)
         {
            case ChallengeBattleTheaterCard.THEATER_AIR:
               this.m_card.img_air_mc.visible = true;
               _loc3_ = ZGameUtils.ZlocT("Dialogs","Theater_air");
               this.m_battleType = UnitItem.AIR;
               break;
            case ChallengeBattleTheaterCard.THEATER_LAND:
               this.m_card.img_land_mc.visible = true;
               _loc3_ = ZGameUtils.ZlocT("Dialogs","Theater_army");
               this.m_battleType = UnitItem.ARMY;
               break;
            case ChallengeBattleTheaterCard.THEATER_SEA:
               this.m_card.img_sea_mc.visible = true;
               _loc3_ = ZGameUtils.ZlocT("Dialogs","Theater_navy");
               this.m_battleType = UnitItem.NAVY;
         }
         TextFieldUtil.processTextField(this.m_card.default_mc.caption_tf,_loc3_);
         TextFieldUtil.processTextField(this.m_card.selected_mc.caption_tf,_loc3_);
         TextFieldUtil.processTextField(this.m_card.highlight_mc.caption_tf,_loc3_);
         this.setUnhighlighted();
         this.setUnselected();
         this.m_card.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this.m_card.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
      }
      
      public static function getTheaterTypeUnitLabel(param1:int) : String
      {
         switch(param1)
         {
            case ChallengeBattleTheaterCard.THEATER_AIR:
               return "BattleSelect_AirUnitType";
            case ChallengeBattleTheaterCard.THEATER_LAND:
               return "BattleSelect_LandUnitType";
            case ChallengeBattleTheaterCard.THEATER_SEA:
               return "BattleSelect_NavyUnitType";
            default:
               return null;
         }
      }
      
      public function dispose() : void
      {
         this.m_card.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.m_card.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.m_card = null;
      }
      
      public function get card() : MovieClip
      {
         return this.m_card;
      }
      
      public function get theater() : int
      {
         return this.m_theater;
      }
      
      public function get battleType() : String
      {
         return this.m_battleType;
      }
      
      public function setSelected() : void
      {
         this.m_card.selected_mc.visible = true;
         this.m_card.default_mc.visible = false;
      }
      
      public function setUnselected() : void
      {
         this.m_card.selected_mc.visible = false;
         this.m_card.default_mc.visible = true;
      }
      
      private function setHighlighted() : void
      {
         this.m_card.highlight_mc.visible = true;
      }
      
      private function setUnhighlighted() : void
      {
         this.m_card.highlight_mc.visible = false;
      }
      
      protected function onRollOver(param1:MouseEvent) : void
      {
         this.setHighlighted();
      }
      
      protected function onRollOut(param1:MouseEvent) : void
      {
         this.setUnhighlighted();
      }
   }
}

