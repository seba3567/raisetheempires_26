package resources
{
   import flash.text.Font;
   import zlabs.debug.Logger;
   
   public class EmbeddedFonts
   {
      
      private static var initialized:Boolean = false;
      
      public static const DEFAULT_FONT_NAME:String = "_typewriter";
      
      public function EmbeddedFonts()
      {
         super();
      }
      
      public static function initialize() : void
      {
         var _loc3_:Font = null;
         if(initialized == true)
         {
            throw new Error("EmbeddedFonts is already initialized");
         }
         initialized = true;
         var _loc1_:Array = Font.enumerateFonts(false);
         var _loc2_:Number = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_];
            Logger.info("EmbededFonts","initialize","[" + _loc2_ + "] name:" + _loc3_.fontName + ", style: " + _loc3_.fontStyle + ", type: " + _loc3_.fontType);
            _loc2_++;
         }
      }
   }
}

