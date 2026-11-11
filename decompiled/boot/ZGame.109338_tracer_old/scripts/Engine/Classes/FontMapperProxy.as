package Engine.Classes
{
   import Engine.Interfaces.IFontMapper;
   import flash.text.TextFormat;
   
   public class FontMapperProxy implements IFontMapper
   {
      
      private var m_setLanguageCode:Function;
      
      private var m_getFontsToRegister:Function;
      
      private var m_mapFontName:Function;
      
      private var m_mapFontSize:Function;
      
      private var m_mapFontEmbed:Function;
      
      private var m_mapFontBold:Function;
      
      private var m_mapTextFormat:Function;
      
      public function FontMapperProxy(param1:Object)
      {
         super();
         this.m_setLanguageCode = param1.setLanguageCode;
         this.m_getFontsToRegister = param1.getFontsToRegister;
         this.m_mapFontName = param1.mapFontName;
         this.m_mapFontSize = param1.mapFontSize;
         this.m_mapFontEmbed = param1.mapFontEmbed;
         this.m_mapFontBold = param1.mapFontBold;
         this.m_mapTextFormat = param1.mapTextFormat;
      }
      
      public function setLanguageCode(param1:String) : void
      {
         this.m_setLanguageCode(param1);
      }
      
      public function getFontsToRegister() : Array
      {
         return this.m_getFontsToRegister();
      }
      
      public function mapFontName(param1:String, param2:String) : String
      {
         return this.m_mapFontName(param1,param2);
      }
      
      public function mapFontSize(param1:String, param2:String, param3:int) : int
      {
         return this.m_mapFontSize(param1,param2,param3);
      }
      
      public function mapFontEmbed(param1:String, param2:String, param3:Boolean) : Boolean
      {
         return this.m_mapFontEmbed(param1,param2,param3);
      }
      
      public function mapFontBold(param1:String, param2:String, param3:int, param4:Boolean) : Boolean
      {
         return this.m_mapFontBold(param1,param2,param3,param4);
      }
      
      public function mapTextFormat(param1:String, param2:TextFormat) : TextFormat
      {
         return this.m_mapTextFormat(param1,param2);
      }
   }
}

