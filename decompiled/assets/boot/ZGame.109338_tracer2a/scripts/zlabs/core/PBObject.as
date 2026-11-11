package zlabs.core
{
   import zlabs.Zlab;
   
   public class PBObject implements IPBObject
   {
      
      protected var _name:String;
      
      protected var _alias:String;
      
      protected var _owningGroup:PBGroup;
      
      protected var _sets:Array;
      
      public function PBObject()
      {
         super();
      }
      
      internal function noteInSet(param1:PBSet) : void
      {
         if(!this._sets)
         {
            this._sets = [];
         }
         if(this._sets.indexOf(param1) != -1)
         {
            return;
         }
         this._sets.push(param1);
      }
      
      internal function noteOutOfSet(param1:PBSet) : void
      {
         var _loc2_:int = this._sets.indexOf(param1);
         if(_loc2_ == -1)
         {
            throw new Error("Removed object from set that it isn\'t in.");
         }
         this._sets.splice(_loc2_,1);
      }
      
      public function get owningGroup() : PBGroup
      {
         return this._owningGroup;
      }
      
      public function set owningGroup(param1:PBGroup) : void
      {
         if(!param1)
         {
            throw new Error("Must always be in a group - cannot set owningGroup to null!");
         }
         if(this._owningGroup)
         {
            this._owningGroup.removeFromGroup(this);
         }
         this._owningGroup = param1;
         this._owningGroup.addToGroup(this);
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get alias() : String
      {
         return this._alias;
      }
      
      public function initialize(param1:String = null, param2:String = null) : void
      {
         this._name = param1;
         this._alias = param2;
         Zlab.nameManager.add(this);
         if(this.owningGroup == null && Zlab.currentGroup != this)
         {
            this.owningGroup = Zlab.currentGroup;
         }
      }
      
      public function destroy() : void
      {
         Zlab.nameManager.remove(this);
         while(Boolean(this._sets) && Boolean(this._sets.length))
         {
            if(this._sets[this._sets.length - 1].remove(this) == false)
            {
               this._sets.pop();
            }
         }
         if(this._owningGroup)
         {
            this._owningGroup.removeFromGroup(this);
            this._owningGroup = null;
         }
      }
   }
}

