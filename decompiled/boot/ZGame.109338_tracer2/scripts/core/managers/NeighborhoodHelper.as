package core.managers
{
   import core.ZGlobal;
   import core.entities.components.OverlayComponent;
   import displays.popups.NeighborhoodDialog;
   import entity.GameDataComponent;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import utils.ZGameTimeUtil;
   import zlabs.entity.IEntity;
   
   public class NeighborhoodHelper extends EventDispatcher
   {
      
      protected static var m_instance:NeighborhoodHelper;
      
      protected const NEIGHBORHOOD_BUILD_STATE:int = 20;
      
      protected var m_neighborhoods:Array = new Array();
      
      protected var m_timers:Array = new Array();
      
      public function NeighborhoodHelper()
      {
         super();
      }
      
      public static function get instance() : NeighborhoodHelper
      {
         if(!m_instance)
         {
            m_instance = new NeighborhoodHelper();
         }
         return m_instance;
      }
      
      public function isNeighborhoodEmpty(param1:Object) : Boolean
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         if(Boolean(param1) && Boolean(param1.blocks))
         {
            _loc2_ = param1.blocks;
            _loc3_ = 1;
            while(_loc3_ <= NeighborhoodDialog.NUM_BLOCKS)
            {
               _loc4_ = _loc2_["block" + _loc3_];
               if((Boolean(_loc4_)) && _loc4_.length > 0)
               {
                  return false;
               }
               _loc3_++;
            }
         }
         return true;
      }
      
      public function addNeighborhood(param1:int) : void
      {
         if(this.m_neighborhoods.lastIndexOf(param1) == -1)
         {
            this.m_neighborhoods.push(param1);
         }
      }
      
      public function getRemainingTime(param1:Object) : Number
      {
         var _loc3_:Object = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:Number = Number.MAX_VALUE;
         for each(_loc3_ in param1.harvest_info)
         {
            if(_loc3_.duration == -1)
            {
               return 1;
            }
            _loc4_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc3_.duration,0);
            _loc5_ = GlobalEngine.serverTime / 1000 - _loc3_.lastUpdated / 1000;
            _loc6_ = _loc4_ - _loc5_;
            if(_loc6_ <= 0)
            {
               return 1;
            }
            if(_loc2_ > _loc6_)
            {
               _loc2_ = _loc6_;
            }
         }
         return _loc2_;
      }
      
      public function resetTimer() : void
      {
         var timer:Timer = null;
         var id:int = 0;
         var obj:IEntity = null;
         var gdc:GameDataComponent = null;
         var overlay1:OverlayComponent = null;
         var duration:Number = NaN;
         while(this.m_timers.length > 0)
         {
            timer = this.m_timers.pop();
            timer.stop();
         }
         if(ZGlobal.isVisiting())
         {
            return;
         }
         for each(id in this.m_neighborhoods)
         {
            obj = ZGlobal.game.getObjectByID(id);
            if(obj)
            {
               gdc = obj.lookupComponentByType(GameDataComponent) as GameDataComponent;
               if(Boolean(gdc && gdc.userData) && Boolean(gdc.userData.itemName == "Neighborhood") && gdc.userData.state >= this.NEIGHBORHOOD_BUILD_STATE)
               {
                  overlay1 = obj.lookupComponentByType(OverlayComponent) as OverlayComponent;
                  if(overlay1)
                  {
                     overlay1.clearOverlay();
                  }
                  duration = this.getRemainingTime(gdc.userData) * 1000;
                  if(duration < 60 * 60 * 1000)
                  {
                     timer = new Timer(duration);
                     timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
                     {
                        var _loc2_:OverlayComponent = obj.lookupComponentByType(OverlayComponent) as OverlayComponent;
                        if(_loc2_)
                        {
                           _loc2_.setIconPath("assets/game/GeneralAssetGroup_UI.swf/Coins_42.png");
                        }
                        timer.stop();
                     });
                     this.m_timers.push(timer);
                     timer.start();
                  }
               }
            }
         }
      }
   }
}

