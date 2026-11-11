package core.player
{
   import core.ZGlobal;
   import utils.ZGameUtils;
   
   public class PlayerDummy implements IPVPPlayer
   {
      
      private var m_uid:String;
      
      public function PlayerDummy(param1:String)
      {
         super();
         this.m_uid = param1;
      }
      
      public function get firstName() : String
      {
         return ZGameUtils.ZlocT("Items","villain18_firstName");
      }
      
      public function get name() : String
      {
         return ZGameUtils.ZlocT("Items","villain18_firstName");
      }
      
      public function get portraitURL() : String
      {
         return ZGlobal.getAssetURL(ZGameUtils.NoProfileImageUrl);
      }
      
      public function get uid() : String
      {
         return this.m_uid;
      }
      
      public function get genderTag() : String
      {
         return ZGlobal.localizer.MASC;
      }
      
      public function get empireName() : String
      {
         return ZGameUtils.ZlocT("Main","WorldNameDefault");
      }
      
      public function get level() : int
      {
         return 0;
      }
      
      public function get snUser() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.picture = this.portraitURL;
         return _loc1_;
      }
   }
}

