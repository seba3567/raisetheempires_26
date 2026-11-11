package zlabs.core
{
   public interface IPBObject
   {
      
      function get name() : String;
      
      function get alias() : String;
      
      function set owningGroup(param1:PBGroup) : void;
      
      function get owningGroup() : PBGroup;
      
      function initialize(param1:String = null, param2:String = null) : void;
      
      function destroy() : void;
   }
}

