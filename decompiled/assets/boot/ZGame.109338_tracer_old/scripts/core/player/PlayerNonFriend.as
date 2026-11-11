package core.player
{
   import ZLocalization.LocalizationName;
   import core.ZGlobal;
   import utils.ZGameUtils;
   
   public class PlayerNonFriend implements IPVPPlayer
   {
      
      private var m_info:Object;
      
      public function PlayerNonFriend(param1:Object)
      {
         super();
         this.m_info = param1;
      }
      
      public function get firstName() : String
      {
         return this.m_info.first_name;
      }
      
      public function get name() : String
      {
         return this.m_info.name;
      }
      
      public function get portraitURL() : String
      {
         return this.m_info.pic;
      }
      
      public function get uid() : String
      {
         return this.m_info.uid;
      }
      
      public function get genderTag() : String
      {
         return this.m_info.sex == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC;
      }
      
      public function get empireName() : String
      {
         var _loc1_:LocalizationName = ZLoc.tn(this.firstName,this.genderTag);
         return ZGameUtils.ZlocT("Main","WorldName",{"player":_loc1_});
      }
      
      public function get level() : int
      {
         return this.m_info.level ? int(this.m_info.level) : 0;
      }
      
      public function get snUser() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.picture = this.portraitURL;
         return _loc1_;
      }
   }
}

