package core.worlds.strategicWorld
{
   import core.entities.components.WorldMusicComponent;
   import core.views.ViewComponent;
   import core.views.ViewManager;
   import core.worlds.AbstractWorld;
   import core.worlds.strategicWorld.swf.version2.StrategicSWF2RendererComponent;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   
   public class StrategicWorld extends AbstractWorld
   {
      
      public static const NEW_VERSION:Boolean = true;
      
      public static const ID:String = "StrategicWorldID";
      
      public function StrategicWorld()
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
         this.add2DComponents(_loc1_);
         var _loc3_:WorldMusicComponent = new WorldMusicComponent("islandmusic",false);
         _loc1_.addComponent(_loc3_,"music");
         _loc1_.initialize(ID);
         _loc1_.owningGroup = Zlab.nameManager.lookup(ViewManager.VIEW_GROUP_NAME);
         ViewManager.instance.addView(_loc1_);
      }
      
      private function add2DComponents(param1:IEntity) : void
      {
         var _loc2_:StrategicRendererComponent = null;
         _loc2_ = new StrategicSWF2RendererComponent();
         param1.addComponent(_loc2_,"Renderer");
      }
   }
}

