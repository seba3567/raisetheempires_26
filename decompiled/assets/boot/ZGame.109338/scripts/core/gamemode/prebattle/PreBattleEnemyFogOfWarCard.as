package core.gamemode.prebattle
{
   import core.ZGlobal;
   import core.gameobjects.Fleet;
   import core.managers.formationManager.FormationManager;
   import core.ui.Tooltip;
   import core.worlds.battleWorld.BattleSide;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import utils.ZGameUtils;
   
   public class PreBattleEnemyFogOfWarCard implements IPreBattleEnemyCard
   {
      
      private static const PATH:String = "assets/game/GeneralAssetGroup_UI.swf/dominanceFog.png";
      
      private var m_movieClip:MovieClip = null;
      
      private var m_loader:ImageLoader;
      
      public function PreBattleEnemyFogOfWarCard(param1:Class, param2:int)
      {
         super();
         var _loc3_:int = Fleet.MAX_UNITS;
         var _loc4_:Point = FormationManager.instance.getLocalOffset(BattleSide.ENEMY.toString() + "_" + _loc3_.toString(),param2,1);
         this.m_movieClip = new param1();
         this.m_movieClip.x = _loc4_.x;
         this.m_movieClip.y = _loc4_.y;
         Tooltip.subscribe(this.m_movieClip,ZGameUtils.ZlocT("Tooltips","PreBattleFOWTooltip"));
         var _loc5_:String = ZGlobal.getAssetURL(PATH);
         this.m_loader = ImageLoaderFactory.CreateImageLoader(_loc5_,this.m_movieClip.loader);
      }
      
      public function dispose() : void
      {
         if(this.m_loader)
         {
            this.m_loader.destroy();
         }
         this.m_movieClip = null;
         Tooltip.unsubscribe(this.m_movieClip);
      }
      
      public function get art() : MovieClip
      {
         return this.m_movieClip;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this.m_movieClip.visible = param1;
      }
   }
}

