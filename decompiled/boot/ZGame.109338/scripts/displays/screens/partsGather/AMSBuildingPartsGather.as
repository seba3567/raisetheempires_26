package displays.screens.partsGather
{
   import core.ZGlobal;
   import core.entities.components.utils.ServerTimeProgressionHelper;
   import core.managers.mayhemManager.MayhemManager;
   import displays.popups.GenericCountdownClock;
   import flash.events.EventDispatcher;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class AMSBuildingPartsGather extends BuildingPartsGather
   {
      
      private var m_timedHelper:ServerTimeProgressionHelper;
      
      private var m_clock:GenericCountdownClock;
      
      private var m_endTime:Number;
      
      private var m_dialog:AMSBuildingPartsGather;
      
      public function AMSBuildingPartsGather(param1:EventDispatcher, param2:String, param3:String, param4:IEntity)
      {
         super(param1,param2,param3,param4);
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:IEntity) : void
      {
         WindowManager.instance.push(new AMSBuildingPartsGather(param1,param2,param3,param4));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         var _loc2_:Object = MayhemManager.instance.getMayhemEvent(MayhemManager.FIRST_ATTACK);
         if(_loc2_)
         {
            this.m_endTime = _loc2_["endTime"];
            this.m_endTime -= MayhemManager.instance.offset + ZGlobal.player.timeWarpSeconds;
            this.m_clock = new GenericCountdownClock(m_partsWindow.clock_mc,this.m_endTime);
         }
         m_partsWindow.bonus_tf.visible = false;
      }
      
      private function onUpdate() : void
      {
      }
      
      override protected function getBuildingPartsInstructionsString() : String
      {
         return ZGameUtils.ZlocT("Dialogs","Mayhem_Clock_Text");
      }
   }
}

