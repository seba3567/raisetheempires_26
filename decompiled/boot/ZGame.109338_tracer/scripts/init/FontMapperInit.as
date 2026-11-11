package init
{
   import Cache.Init.ZCacheInit;
   import Engine.Classes.FontMapperProxy;
   import Engine.Init.InitializationAction;
   import Engine.Interfaces.IFontMapper;
   import core.ZGlobal;
   import flash.events.Event;
   import flash.text.Font;
   import resources.FontMapperLatin;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class FontMapperInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "FontMapperInit";
      
      private var m_url:String = null;
      
      private var m_locale:String;
      
      private const FONT_MAPPER_DEFINITION:String = "FontMapper";
      
      public function FontMapperInit()
      {
         super(INIT_ID);
         var _loc1_:String = Zlab.getFlashVar("zcache") as String;
         if(_loc1_ != null && _loc1_.length > 0)
         {
            addDependency(ZCacheInit.INIT_ID);
         }
      }
      
      override public function execute() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:Class = null;
         this.m_locale = Zlab.getFlashVar("locale") ? Zlab.getFlashVar("locale") as String : "en_US";
         GlobalEngine.fontMapper = new FontMapperLatin();
         if(ZGlobal.localizer)
         {
            GlobalEngine.fontMapper.setLanguageCode(this.m_locale);
         }
         if(Zlab.getFlashVar("fontmapper_url"))
         {
            this.m_url = Zlab.getFlashVar("fontmapper_url") as String;
         }
         else if(this.m_locale)
         {
            _loc1_ = GlobalEngine.stage.loaderInfo.url.lastIndexOf("/");
            _loc2_ = GlobalEngine.stage.loaderInfo.url.substr(0,_loc1_ + 1);
            if(this.m_locale == "zh_CN" || this.m_locale == "zh_TW" || this.m_locale == "zh")
            {
               this.m_url = _loc2_ + "FontMapper_zh.swf";
            }
            else if(this.m_locale == "ko_KR")
            {
               this.m_url = _loc2_ + "FontMapper_ko.swf";
            }
            else if(this.m_locale == "ja_JP")
            {
               this.m_url = _loc2_ + "FontMapper_ja.swf";
            }
            else if(this.m_locale == "tr_TR")
            {
               this.m_url = _loc2_ + "FontMapper_tr.swf";
            }
         }
         if(this.m_url)
         {
            Zlab.resourceManager.load(this.m_url,SWFResource,this.onLoadComplete,this.onLoadFailed);
         }
         else
         {
            _loc3_ = GlobalEngine.fontMapper.getFontsToRegister();
            for each(_loc4_ in _loc3_)
            {
               Font.registerFont(_loc4_);
            }
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      private function onLoadComplete(param1:SWFResource) : void
      {
         var _loc3_:IFontMapper = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc2_:Object = param1.getExportedAsset(this.FONT_MAPPER_DEFINITION);
         if(_loc2_)
         {
            _loc3_ = new FontMapperProxy(_loc2_);
            if(ZGlobal.localizer)
            {
               _loc3_.setLanguageCode(this.m_locale);
            }
            _loc4_ = _loc3_.getFontsToRegister();
            for each(_loc5_ in _loc4_)
            {
               Font.registerFont(param1.getAssetClass(_loc5_));
            }
            GlobalEngine.fontMapper = _loc3_;
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onLoadFailed(param1:SWFResource) : void
      {
         throw Error("Failed to load font mapper swf \"" + this.m_url + "\".");
      }
   }
}

