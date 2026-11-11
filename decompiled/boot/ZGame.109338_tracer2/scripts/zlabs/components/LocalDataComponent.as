package zlabs.components
{
   import flash.net.SharedObject;
   import zlabs.debug.Logger;
   
   public class LocalDataComponent
   {
      
      private static var m_hostName:String = "zynga_games";
      
      public function LocalDataComponent()
      {
         super();
      }
      
      public static function getLocalData(param1:String) : Object
      {
         var local_data:SharedObject = null;
         var a_var:String = param1;
         try
         {
            local_data = SharedObject.getLocal(m_hostName);
            return local_data.data[a_var];
         }
         catch(err:Error)
         {
            Logger.error(null,"LocalDataComponent::getLocalData",err.message);
         }
         return null;
      }
      
      public static function setLocalData(param1:String, param2:Object) : void
      {
         var local_data:SharedObject = null;
         var flushResult:Object = null;
         var a_name:String = param1;
         var a_value:Object = param2;
         try
         {
            local_data = SharedObject.getLocal(m_hostName);
            local_data.data[a_name] = a_value;
            flushResult = local_data.flush();
            local_data.close();
         }
         catch(err:Error)
         {
            Logger.error(null,"LocalDataComponent::setLocalData",err.message);
         }
      }
      
      public static function clearLocalData() : void
      {
         var local_data:SharedObject = null;
         try
         {
            local_data = SharedObject.getLocal(m_hostName);
            local_data.clear();
         }
         catch(err:Error)
         {
            Logger.error(null,"LocalDataComponent::clearLocalData",err.message);
         }
      }
   }
}

