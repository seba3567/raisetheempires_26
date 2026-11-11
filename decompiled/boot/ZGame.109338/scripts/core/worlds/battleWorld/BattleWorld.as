package core.worlds.battleWorld
{
   import core.entities.components.WorldMusicComponent;
   import core.views.ViewComponent;
   import core.views.ViewManager;
   import core.worlds.AbstractWorld;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   
   public class BattleWorld extends AbstractWorld
   {
      
      public static const REGISTER_PLAYER_UNIT:String = "registerplayerunit";
      
      public static const REGISTER_ENEMY_UNIT:String = "registerenemyunit";
      
      public static const REGISTER_FLEETS:String = "registerfleets";
      
      public static const ID:String = "BattleWorldID";
      
      public function BattleWorld()
      {
         super(ID);
      }
      
      override public function initialize() : void
      {
         var _loc1_:IEntity = Zlab.allocateEntity();
         var _loc2_:ViewComponent = new ViewComponent();
         _loc2_.rendererPropertyReference = new PropertyReference("@Renderer.displayObject");
         _loc2_.layer = 1;
         _loc1_.addComponent(_loc2_,"ViewData");
         var _loc3_:BattleRendererComponent = new BattleRendererComponent();
         _loc1_.addComponent(_loc3_,"Renderer");
         var _loc4_:UnitHitPercentageComponent = new UnitHitPercentageComponent();
         _loc1_.addComponent(_loc4_,"HitPercentage");
         var _loc5_:WorldMusicComponent = new WorldMusicComponent("battlemusic",false);
         _loc1_.addComponent(_loc5_,"music");
         var _loc6_:MatchIntroComponent = new MatchIntroComponent(_loc3_);
         _loc1_.addComponent(_loc6_,"matchIntro");
         _loc1_.initialize(ID);
         _loc1_.owningGroup = Zlab.nameManager.lookup(ViewManager.VIEW_GROUP_NAME);
         ViewManager.instance.addView(_loc1_);
      }
   }
}

