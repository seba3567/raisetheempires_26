package Engine.Managers
{
   import Engine.Utilities;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class LocalizationManager
   {
      
      private static var m_xml:XML;
      
      private static var m_callBackFunc:Function;
      
      private static var m_urlLoader:URLLoader;
      
      private static var m_dictionary:Dictionary;
      
      private static var m_fileIsCompressed:Boolean;
      
      public function LocalizationManager()
      {
         super();
      }
      
      public static function init(param1:String, param2:Function, param3:Boolean = false) : void
      {
         m_fileIsCompressed = param3;
         m_urlLoader = new URLLoader();
         if(m_fileIsCompressed)
         {
            m_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
         }
         m_urlLoader.addEventListener(Event.COMPLETE,xmlParseCallBack);
         m_callBackFunc = param2;
         m_urlLoader.load(new URLRequest(param1));
      }
      
      public static function xmlParseCallBack(param1:Event) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         m_urlLoader.removeEventListener(Event.COMPLETE,xmlParseCallBack);
         if(m_fileIsCompressed)
         {
            _loc3_ = Utilities.uncompress(param1.target.data);
            _loc2_ = new XML(_loc3_);
         }
         else
         {
            GlobalEngine.msg("Loaded uncompressed localization file. Size:",param1.target.data.length);
            _loc2_ = new XML(param1.target.data);
         }
         m_xml = _loc2_;
         LocalizationManager.setLocaleXml(m_xml);
         m_dictionary = new Dictionary();
         m_callBackFunc();
      }
      
      public static function setLocaleXml(param1:XML) : void
      {
         m_xml = param1;
      }
      
      private static function getLocalizationString(param1:String, param2:String) : String
      {
         var hashKey:String = null;
         var bundleList:XMLList = null;
         var bundleXML:XML = null;
         var bundleLookup:XMLList = null;
         var bundleName:String = param1;
         var resource:String = param2;
         var stringResult:String = null;
         if(m_xml)
         {
            hashKey = bundleName + ":" + resource;
            stringResult = m_dictionary[hashKey];
            if(stringResult == null)
            {
               bundleList = m_xml.bundle.(@name == bundleName);
               if(bundleList)
               {
                  bundleXML = bundleList[0];
                  if(bundleXML != null && Boolean(bundleXML.bundleLine))
                  {
                     bundleLookup = bundleXML.bundleLine.(@key == resource);
                     if(bundleLookup)
                     {
                        stringResult = bundleLookup.value;
                     }
                     m_dictionary[hashKey] = stringResult;
                  }
               }
            }
            if(stringResult == "")
            {
               stringResult = null;
            }
         }
         return stringResult;
      }
      
      public static function hasLocalizationString(param1:String, param2:String) : Boolean
      {
         return getLocalizationString(param1,param2) != null;
      }
      
      public static function quickLocalize(param1:String, param2:String, param3:Array = null) : String
      {
         var _loc5_:RegExp = null;
         var _loc6_:int = 0;
         var _loc4_:String = getLocalizationString(param1,param2);
         if(_loc4_)
         {
            if(param3)
            {
               _loc6_ = 0;
               while(_loc6_ < param3.length)
               {
                  if(_loc4_)
                  {
                     _loc5_ = new RegExp("\\{" + _loc6_ + "\\}","gim");
                     _loc4_ = _loc4_.replace(_loc5_,param3[_loc6_]);
                  }
                  _loc6_++;
               }
            }
         }
         else if(Config.DEBUG_MODE == true)
         {
            _loc4_ = "Could not find localization data for " + param1 + ":" + param2;
            GlobalEngine.log("localization","bundleName: " + param1 + " resource: " + param2);
         }
         else
         {
            _loc4_ = "";
         }
         return _loc4_;
      }
   }
}

