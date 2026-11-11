package core.ui.menuitem
{
   import Engine.Classes.TimerUtil;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import core.ui.Tooltip;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.CineCameraComponent;
   import dispatchers.UIDispatcher;
   import entity.GameDataComponent;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.utils.MathUtils;
   
   public class TimedBuildableMenuItem extends PromoMenuItem
   {
      
      protected var m_itemCode:String;
      
      protected var m_timer:Timer;
      
      protected var m_xml:XML;
      
      public function TimedBuildableMenuItem(param1:XML)
      {
         var _loc2_:Array = null;
         this.m_xml = param1;
         itemID = param1.@classId.toString();
         swfPath = param1.@icon.toString();
         _loc2_ = param1.@tooltip.toString().split(":");
         if(_loc2_.length > 1)
         {
            toolTipFileName = _loc2_[0];
            toolTipText = _loc2_[1];
         }
         else
         {
            toolTipFileName = "MessageOfTheDay";
            toolTipText = param1.@tooltip.toString();
         }
         this.m_itemCode = param1.@itemCode.toString();
         priority = int(param1.@priority);
         super(id,false,true);
      }
      
      override protected function onLoadComplete(param1:String, param2:BitmapData) : void
      {
         var _loc5_:int = 0;
         super.onLoadComplete(param1,param2);
         var _loc3_:String = ZGameUtils.ZlocT(toolTipFileName,toolTipText);
         Tooltip.subscribe(m_uiloader,_loc3_);
         var _loc4_:XML = this.m_xml.criteria[0];
         if(_loc4_.hasOwnProperty("requiredDate"))
         {
            _loc5_ = this.getTimeRemaining(_loc4_);
         }
         if(_loc5_ <= 0)
         {
            removeItem();
         }
         else
         {
            this.m_timer = TimerUtil.callHandlerLater(this.onTimerExpiry,_loc5_ * 1000);
         }
      }
      
      private function panToItem(param1:String) : void
      {
         var _loc3_:Dictionary = null;
         var _loc4_:Object = null;
         var _loc5_:GameDataComponent = null;
         var _loc6_:BuildingSpatialComponent = null;
         var _loc7_:Pt = null;
         var _loc8_:CineCameraComponent = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         if(_loc2_)
         {
            _loc3_ = WorldObjectManager.instance.getObjectsBySubType(_loc2_.type,_loc2_.subType);
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = GameDataComponent(_loc4_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc5_)) && _loc5_.gameData.code == param1)
               {
                  _loc6_ = BuildingSpatialComponent(_loc4_.lookupComponentByType(BuildingSpatialComponent));
                  if(_loc6_)
                  {
                     _loc7_ = new Pt(_loc6_.position.x,_loc6_.position.y);
                     _loc7_ = MathUtils.worldToTile(_loc7_,ZGlobal.cellSize);
                     _loc8_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,CineCameraComponent) as CineCameraComponent;
                     _loc8_.moveTo(_loc7_);
                     break;
                  }
               }
            }
         }
      }
      
      override protected function onClicked(param1:MouseEvent) : void
      {
         this.panToItem(this.m_itemCode);
      }
      
      protected function getTimeRemaining(param1:XML) : int
      {
         var _loc2_:Object = {"stringNotUsed":true};
         var _loc3_:int = ZGameTimeUtil.instance.getDateStatus(_loc2_,param1);
         if(_loc3_ == ZGameTimeUtil.DATE_STATUS_ACTIVE || _loc3_ == ZGameTimeUtil.DATE_STATUS_EARLY)
         {
            return _loc2_.delta;
         }
         return 0;
      }
      
      protected function onTimerExpiry(param1:Event = null) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
         }
         this.m_timer = null;
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UIDispatcher.UI_REMOVE_UI_ITEM,this));
      }
   }
}

