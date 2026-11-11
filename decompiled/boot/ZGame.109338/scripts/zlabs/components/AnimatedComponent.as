package zlabs.components
{
   import zlabs.Zlab;
   import zlabs.core.IAnimatedObject;
   import zlabs.entity.EntityComponent;
   
   public class AnimatedComponent extends EntityComponent implements IAnimatedObject
   {
      
      public var updatePriority:Number = 0;
      
      private var _registerForUpdates:Boolean = true;
      
      private var _isRegisteredForUpdates:Boolean = false;
      
      public function AnimatedComponent()
      {
         super();
      }
      
      public function set registerForUpdates(param1:Boolean) : void
      {
         this._registerForUpdates = param1;
         if(this._registerForUpdates && !this._isRegisteredForUpdates)
         {
            this._isRegisteredForUpdates = true;
            Zlab.processManager.addAnimatedObject(this,this.updatePriority);
         }
         else if(!this._registerForUpdates && this._isRegisteredForUpdates)
         {
            this._isRegisteredForUpdates = false;
            Zlab.processManager.removeAnimatedObject(this);
         }
      }
      
      public function get registerForUpdates() : Boolean
      {
         return this._registerForUpdates;
      }
      
      public function onFrame(param1:Number) : void
      {
      }
      
      override protected function onAdd() : void
      {
         this.registerForUpdates = this.registerForUpdates;
      }
      
      override protected function onRemove() : void
      {
         this.registerForUpdates = false;
      }
   }
}

