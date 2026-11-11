package ZLocalization
{
   public class LocalizerSWF extends Localizer
   {
      
      public function LocalizerSWF(param1:Object)
      {
         super(param1);
         this.m_locale = param1.info.locale;
         this.m_cached = param1.text;
         this.setSubstituter();
      }
      
      override public function getString(param1:String, param2:String) : LocalizedString
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:LocalizedString = null;
         if(this.m_cached.hasOwnProperty(param1) && Boolean(this.m_cached[param1].hasOwnProperty(param2)))
         {
            if(this.m_cached[param1][param2] is LocalizedString)
            {
               return this.m_cached[param1][param2];
            }
            _loc3_ = this.m_cached[param1][param2];
            _loc4_ = _loc3_["original"];
            _loc5_ = _loc3_.hasOwnProperty("variations") ? _loc3_["variations"] : null;
            _loc6_ = new LocalizedString(_loc4_,_loc5_);
            if(_loc3_.hasOwnProperty("gender"))
            {
               _loc6_.gender = _loc3_["gender"];
            }
            this.m_cached[param1][param2] = _loc6_;
            return _loc6_;
         }
         return null;
      }
   }
}

