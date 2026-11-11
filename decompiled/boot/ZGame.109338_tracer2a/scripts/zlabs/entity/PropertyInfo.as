package zlabs.entity
{
   internal final class PropertyInfo
   {
      
      public var propertyParent:Object = null;
      
      public var propertyName:String = null;
      
      public function PropertyInfo()
      {
         super();
      }
      
      final public function getValue() : *
      {
         try
         {
            if(this.propertyName)
            {
               return this.propertyParent[this.propertyName];
            }
            return this.propertyParent;
         }
         catch(e:Error)
         {
            return null;
         }
      }
      
      final public function setValue(param1:*) : void
      {
         this.propertyParent[this.propertyName] = param1;
      }
      
      final public function clear() : void
      {
         this.propertyParent = null;
         this.propertyName = null;
      }
   }
}

