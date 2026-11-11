package core.permission
{
   public interface IPermissionGate
   {
      
      function attempt(param1:String, param2:Function, param3:Function = null) : void;
   }
}

