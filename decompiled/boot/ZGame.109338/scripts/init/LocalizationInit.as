package init
{
   import Engine.Init.InitializationAction;
   import ZLocalization.LocaleLoader;
   import ZLocalization.LocalizerSWF;
   import core.ZGlobal;
   import flash.events.Event;
   
   public class LocalizationInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "LocalizationInit";
      
      private var m_localeUrl:String = "";
      
      private var m_xml:XML;
      
      private var localeLoader:LocaleLoader;
      
      public function LocalizationInit(param1:String)
      {
         super(INIT_ID);
         this.m_localeUrl = param1;
      }
      
      override public function execute() : void
      {
         if(Boolean(ZGlobal.localeData) && ZGlobal.localeData != "0")
         {
            this.onConfigXmlLoaded(true);
         }
         else
         {
            this.localeLoader = new LocaleLoader(this.m_localeUrl,this.onConfigXmlLoaded,this.m_localeUrl.lastIndexOf(".phpgz") > 0,this.m_localeUrl.lastIndexOf(".swf") <= 0);
         }
      }
      
      private function onConfigXmlLoaded(param1:Boolean = false) : void
      {
         if(param1)
         {
            ZGlobal.localizer = new LocalizerSWF(ZGlobal.localeData);
            ZGlobal.localeData = null;
            LocaleLoader.loadFontMapper(ZGlobal.localizer,ZGlobal.localeAppDomain);
         }
         else
         {
            ZGlobal.localizer = this.localeLoader.localizer;
         }
         ZGlobal.localizer.setAsGlobalInstance();
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

