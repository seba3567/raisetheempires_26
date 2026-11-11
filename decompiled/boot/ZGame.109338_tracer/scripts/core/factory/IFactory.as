package core.factory
{
   import utils.IInitObject;
   
   public interface IFactory
   {
      
      function create(param1:IInitObject) : *;
      
      function dispose() : void;
   }
}

