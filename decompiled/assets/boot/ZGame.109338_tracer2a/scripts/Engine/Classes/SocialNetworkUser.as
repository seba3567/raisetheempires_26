package Engine.Classes
{
   public class SocialNetworkUser
   {
      
      public var snuid:Number = 0;
      
      public var snid:Number = 0;
      
      public var name:String = "";
      
      public var firstName:String = "";
      
      public var picture:String = "";
      
      public var gender:String = "";
      
      public var locale:String = "";
      
      public function SocialNetworkUser(param1:Number, param2:Number = 0)
      {
         super();
         this.snuid = param1;
         this.snid = param2;
      }
      
      public function get uid() : *
      {
         var _loc1_:String = null;
         if(this.snid == 0)
         {
            _loc1_ = this.snuid.toString();
         }
         else
         {
            _loc1_ = this.snid + ":" + this.snuid;
         }
         return _loc1_;
      }
      
      public function getLocGender() : String
      {
         if(this.gender == "F")
         {
            return "fem";
         }
         return "masc";
      }
   }
}

