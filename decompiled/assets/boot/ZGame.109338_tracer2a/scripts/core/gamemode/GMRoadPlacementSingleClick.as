package core.gamemode
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gamemode.helpers.RoadPlacementProxy;
   import core.gamemode.island.GMIsland;
   import core.gameobjects.GameItem;
   import core.ui.PlayerFeedbackManager;
   import core.ui.actionfeedback.ResourceActionFeedback;
   import core.ui.menuitem.OptionUIItem;
   import core.worlds.islandworld.IslandWorld;
   import dispatchers.UIDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import sound.SoundEvent;
   import utils.TileUtil;
   import utils.ZGameUtils;
   
   public class GMRoadPlacementSingleClick extends GMIsland
   {
      
      private var m_currentPos:Point = new Point();
      
      private var m_roadPlacementProxy:RoadPlacementProxy = null;
      
      public function GMRoadPlacementSingleClick(param1:String, param2:Boolean = false)
      {
         super();
         this.m_roadPlacementProxy = new RoadPlacementProxy(IslandWorld.ID);
      }
      
      override protected function highlightEntity(param1:MouseEvent) : void
      {
      }
      
      override protected function getCursor() : Object
      {
         return null;
      }
      
      override public function onMouseMove(param1:MouseEvent) : Boolean
      {
         var _loc2_:Pt = new Pt();
         screenToIso(getMouseStagePos(this.m_currentPos),_loc2_);
         TileUtil.snapPointToGrid(_loc2_,false);
         this.m_roadPlacementProxy.onMouseMove(_loc2_);
         SelectionMasker.instance.updateTargetPosition(_loc2_);
         return super.onMouseMove(param1);
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         var _loc2_:Pt = null;
         var _loc3_:Pt = null;
         var _loc4_:GameItem = null;
         var _loc5_:ResourceActionFeedback = null;
         if(this.m_roadPlacementProxy)
         {
            _loc2_ = new Pt();
            getMouseStagePos(_loc2_);
            _loc3_ = new Pt();
            screenToIso(_loc2_,_loc3_);
            if(this.m_roadPlacementProxy.onMouseClick())
            {
               SoundEvent.getSoundEvent("PlaceRoad").play();
               _loc4_ = ZGlobal.gameSettings.getRoadItem();
               if(_loc4_)
               {
                  _loc5_ = new ResourceActionFeedback(new Vector3D(_loc3_.x,_loc3_.y + ZGlobal.cellSize),"coins",-_loc4_.cost,0);
               }
            }
            else
            {
               PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackCannotPlaceHere"),new Vector3D(_loc3_.x,_loc3_.y + ZGlobal.cellSize));
            }
         }
      }
      
      override public function enableMode() : void
      {
         UIDispatcher.instance.addEventListener(OptionUIItem.EXIT,onExitMode,false,0,true);
         SelectionMasker.instance.setRoadTarget(this.m_roadPlacementProxy,true);
         super.enableMode();
      }
      
      override public function disableMode() : void
      {
         UIDispatcher.instance.removeEventListener(OptionUIItem.EXIT,onExitMode);
         SelectionMasker.instance.clearTarget(true);
         if(this.m_roadPlacementProxy)
         {
            this.m_roadPlacementProxy.dispose();
            this.m_roadPlacementProxy = null;
         }
         super.disableMode();
      }
   }
}

