package displays.screens.partsGather
{
   import flash.events.EventDispatcher;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.managers.WindowManager;
   
   public class RebuildParliamentPartsGather extends BuildingPartsGather
   {
      
      public function RebuildParliamentPartsGather(param1:EventDispatcher, param2:String, param3:String, param4:IEntity)
      {
         super(param1,param2,param3,param4);
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:String, param4:IEntity) : void
      {
         Logger.print(RebuildParliamentPartsGather,"JMR: using RebuildParliamentPartsGather");
         WindowManager.instance.push(new RebuildParliamentPartsGather(param1,param2,param3,param4));
      }
   }
}

