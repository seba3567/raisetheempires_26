package zlabs.components
{
   import zlabs.Zlab;
   import zlabs.core.ITickedObject;
   import zlabs.entity.EntityComponent;
   
   public class TickedComponent extends EntityComponent implements ITickedObject
   {
      
      public var updatePriority:Number = 0;
      
      private var _registerForUpdates:Boolean = true;
      
      private var _isRegisteredForUpdates:Boolean = false;
      
      public function TickedComponent()
      {
         super();
      }
      
      public function set registerForTicks(param1:Boolean) : void
      {
         this._registerForUpdates = param1;
         if(this._registerForUpdates && !this._isRegisteredForUpdates)
         {
            this._isRegisteredForUpdates = true;
            Zlab.processManager.addTickedObject(this,this.updatePriority);
         }
         else if(!this._registerForUpdates && this._isRegisteredForUpdates)
         {
            this._isRegisteredForUpdates = false;
            Zlab.processManager.removeTickedObject(this);
         }
      }
      
      public function get registerForTicks() : Boolean
      {
         return this._registerForUpdates;
      }
      
      public function onTick(param1:Number) : void
      {
      }
      
      override protected function onAdd() : void
      {
         this.registerForTicks = this.registerForTicks;
      }
      
      override protected function onRemove() : void
      {
         this.registerForTicks = false;
      }
   }
}

