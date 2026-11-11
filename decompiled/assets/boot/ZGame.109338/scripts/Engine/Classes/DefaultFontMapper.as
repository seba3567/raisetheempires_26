package Engine.Classes
{
   import Engine.Interfaces.IFontMapper;
   import flash.text.TextFormat;
   
   public class DefaultFontMapper implements IFontMapper
   {
      
      public function DefaultFontMapper()
      {
         super();
      }
      
      public function setLanguageCode(param1:String) : void
      {
      }
      
      public function getFontsToRegister() : Array
      {
         return [];
      }
      
      public function mapFontName(param1:String, param2:String) : String
      {
         return param2;
      }
      
      public function mapFontSize(param1:String, param2:String, param3:int) : int
      {
         return param3;
      }
      
      public function mapFontEmbed(param1:String, param2:String, param3:Boolean) : Boolean
      {
         return param3;
      }
      
      public function mapFontBold(param1:String, param2:String, param3:int, param4:Boolean) : Boolean
      {
         return param4;
      }
      
      public function mapTextFormat(param1:String, param2:TextFormat) : TextFormat
      {
         return param2;
      }
   }
}

