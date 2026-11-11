package resources
{
   import Engine.Interfaces.IFontMapper;
   import flash.text.TextFormat;
   
   public class FontMapperLatin implements IFontMapper
   {
      
      private static var CCSmashEmbedClass:Class = FontMapperLatin_CCSmashEmbedClass;
      
      private static const CCSMASH_FONT:String = "CCSmashEmbed";
      
      private static var FuturaStdHeavyEmbedClass:Class = FontMapperLatin_FuturaStdHeavyEmbedClass;
      
      public static const FUTURA_HEAVY_FONT:String = "FuturaStdHeavyEmbed";
      
      private static var FuturaStdMediumEmbedClass:Class = FontMapperLatin_FuturaStdMediumEmbedClass;
      
      public static const FUTURA_MEDIUM_FONT:String = "FuturaStdMediumEmbed";
      
      private static var FuturaStdCondExtraBdEmbed:Class = FontMapperLatin_FuturaStdCondExtraBdEmbed;
      
      public static const FUTURA_CONDEXTBD_FONT:String = "FuturaStdCondExtraBdEmbed";
      
      private static var fontMappings:Object = {
         "CCSmash":{
            "name":CCSMASH_FONT,
            "embeds":true
         },
         "CCSmash Regular":{
            "name":CCSMASH_FONT,
            "embeds":true
         },
         "Futura Std Heavy":{
            "name":FUTURA_HEAVY_FONT,
            "embeds":true
         },
         "Futura Std Medium":{
            "name":FUTURA_MEDIUM_FONT,
            "embeds":true
         },
         "FuturaStd-Medium":{
            "name":FUTURA_MEDIUM_FONT,
            "embeds":true
         },
         "Futura Std Condensed ExtBd":{
            "name":FUTURA_CONDEXTBD_FONT,
            "embeds":true
         },
         "Futura Std Extra Bold Condensed":{
            "name":FUTURA_CONDEXTBD_FONT,
            "embeds":true
         },
         "_sans":{
            "name":"Arial",
            "embeds":false
         },
         "Arial":{
            "name":"Arial",
            "embeds":false
         }
      };
      
      private var m_langCode:String = "en_US";
      
      public function FontMapperLatin()
      {
         super();
      }
      
      public function setLanguageCode(param1:String) : void
      {
         this.m_langCode = param1;
      }
      
      public function getFontsToRegister() : Array
      {
         return [CCSmashEmbedClass,FuturaStdHeavyEmbedClass,FuturaStdMediumEmbedClass,FuturaStdCondExtraBdEmbed];
      }
      
      public function mapFontName(param1:String, param2:String) : String
      {
         var _loc3_:Object = fontMappings[param2];
         if(_loc3_)
         {
            return _loc3_.name;
         }
         throw Error("Unable to map font " + param2 + ".");
      }
      
      public function mapFontSize(param1:String, param2:String, param3:int) : int
      {
         return param3;
      }
      
      public function mapFontEmbed(param1:String, param2:String, param3:Boolean) : Boolean
      {
         var _loc4_:Object = fontMappings[param2];
         if(_loc4_)
         {
            return _loc4_.embeds;
         }
         throw Error("Unable to map embeds for font " + param2 + ".");
      }
      
      public function mapFontBold(param1:String, param2:String, param3:int, param4:Boolean) : Boolean
      {
         return param4;
      }
      
      public function mapTextFormat(param1:String, param2:TextFormat) : TextFormat
      {
         param2.font = this.mapFontName(param1,param2.font);
         return param2;
      }
   }
}

