package zlabs.serialization
{
   public interface ISerializable
   {
      
      function serialize(param1:XML) : void;
      
      function deserialize(param1:XML) : *;
   }
}

