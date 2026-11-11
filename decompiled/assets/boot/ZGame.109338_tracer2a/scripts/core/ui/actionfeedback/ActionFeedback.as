package core.ui.actionfeedback
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.ui.FloatingText;
   import core.ui.feedbacktext.FeedbackText;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Vector3D;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class ActionFeedback
   {
      
      private static const DEFAULT_ELEVATION:int = 100;
      
      private static const PER_INSTANCE_DISPLACEMENT:int = 30;
      
      protected var m_feedbackText:FeedbackText = null;
      
      private var m_position:Vector3D;
      
      public function ActionFeedback(param1:Object, param2:String, param3:int, param4:int = 0)
      {
         var _loc8_:IEntity = null;
         var _loc9_:BuildingSpatialComponent = null;
         var _loc10_:Pt = null;
         super();
         if(param1 is IEntity)
         {
            _loc8_ = param1 as IEntity;
            _loc9_ = BuildingSpatialComponent(_loc8_.lookupComponentByType(BuildingSpatialComponent));
            this.m_position = _loc9_.position;
            _loc10_ = _loc9_.volume;
            this.m_position.x = this.m_position.x - ZGlobal.cellSize + _loc10_.x;
            this.m_position.y += _loc10_.y;
         }
         else
         {
            this.m_position = param1 as Vector3D;
         }
         this.m_position.z = DEFAULT_ELEVATION + param4 * PER_INSTANCE_DISPLACEMENT;
         var _loc5_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc6_:Pt = Pt.toPt(this.m_position);
         _loc5_.isoView.isoToLocal(_loc6_);
         var _loc7_:FloatingText = this.createFloatingText(_loc5_.isoView.foregroundContainer);
         _loc7_.useWorldZoom = true;
         _loc7_.position = _loc6_;
         _loc7_.text = param3 > 0 ? ZGameUtils.ZlocT("Main","PositiveFeedback",{"feedback":this.m_feedbackText.friendlyName}) : this.m_feedbackText.friendlyName;
         _loc7_.scale = RewardPickupManager.instance.floatingTextSizeMultiplier3D;
         _loc7_.color = this.m_feedbackText.color;
         _loc7_.onDispose = this.onFloatingTextDisposed;
         _loc7_.disposeOnComplete = true;
      }
      
      protected function onFloatingTextDisposed() : void
      {
         this.m_feedbackText = null;
      }
      
      protected function createFloatingText(param1:DisplayObjectContainer) : FloatingText
      {
         return new FloatingText(param1);
      }
   }
}

