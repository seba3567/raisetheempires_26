package as3isolib.data
{
   import as3isolib.core.as3isolib_internal;
   import as3isolib.events.IsoEvent;
   import eDpLib.events.EventDispatcherProxy;
   
   use namespace as3isolib_internal;
   
   public class Node extends EventDispatcherProxy implements INode
   {
      
      private static var _IDCount:uint = 0;
      
      public const UID:uint = _IDCount++;
      
      protected var setID:String;
      
      private var _data:Object;
      
      as3isolib_internal var ownerObject:Object;
      
      as3isolib_internal var parentNode:INode;
      
      private var childrenArray:Vector.<INode> = null;
      
      public function Node()
      {
         super();
      }
      
      public function get id() : String
      {
         return this.setID == null || this.setID == "" ? "node" + this.UID.toString() : this.setID;
      }
      
      public function set id(param1:String) : void
      {
         this.setID = param1;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      public function get owner() : Object
      {
         return this.ownerObject ? this.ownerObject : this.parentNode;
      }
      
      public function get hasParent() : Boolean
      {
         return this.parentNode != null;
      }
      
      public function get parent() : INode
      {
         return this.parentNode;
      }
      
      public function getRootNode() : INode
      {
         var _loc1_:INode = this;
         while(_loc1_.hasParent)
         {
            _loc1_ = _loc1_.parent;
         }
         return _loc1_;
      }
      
      public function getDescendantNodes(param1:Boolean = false) : Array
      {
         var _loc3_:INode = null;
         var _loc2_:Array = [];
         if(null != this.childrenArray)
         {
            for each(_loc3_ in this.childrenArray)
            {
               if(_loc3_.children.length > 0)
               {
                  _loc2_ = _loc2_.concat(_loc3_.getDescendantNodes(param1));
                  if(param1)
                  {
                     _loc2_.push(_loc3_);
                  }
               }
               else
               {
                  _loc2_.push(_loc3_);
               }
            }
         }
         return _loc2_;
      }
      
      public function contains(param1:INode) : Boolean
      {
         var _loc2_:INode = null;
         if(param1.hasParent)
         {
            return param1.parent == this;
         }
         if(null != this.childrenArray)
         {
            for each(_loc2_ in this.childrenArray)
            {
               if(_loc2_ == param1)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get children() : Array
      {
         var _loc2_:Object = null;
         var _loc1_:Array = [];
         if(null != this.childrenArray)
         {
            for each(_loc2_ in this.childrenArray)
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      public function get numChildren() : uint
      {
         return null != this.childrenArray ? this.childrenArray.length : 0;
      }
      
      public function addChild(param1:INode) : void
      {
         this.addChildAt(param1,this.numChildren);
      }
      
      public function addChildAt(param1:INode, param2:uint) : void
      {
         var _loc4_:INode = null;
         if(param1.hasParent)
         {
            _loc4_ = param1.parent;
            _loc4_.removeChildByID(param1.id);
         }
         if(null == this.childrenArray)
         {
            this.childrenArray = new Vector.<INode>();
         }
         Node(param1).parentNode = this;
         this.childrenArray.splice(param2,0,param1);
         var _loc3_:IsoEvent = new IsoEvent(IsoEvent.CHILD_ADDED);
         _loc3_.newValue = param1;
         dispatchEvent(_loc3_);
      }
      
      public function getChildAt(param1:uint) : INode
      {
         if(param1 >= this.numChildren)
         {
            throw new Error("");
         }
         return INode(this.childrenArray[param1]);
      }
      
      public function getChildIndex(param1:INode) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.numChildren)
         {
            if(param1 == this.childrenArray[_loc2_])
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function setChildIndex(param1:INode, param2:uint) : void
      {
         var _loc4_:INode = null;
         var _loc5_:Boolean = false;
         var _loc3_:int = this.getChildIndex(param1);
         if(_loc3_ == param2)
         {
            return;
         }
         if(_loc3_ > -1)
         {
            this.childrenArray.splice(_loc3_,1);
            _loc5_ = false;
            for each(_loc4_ in this.childrenArray)
            {
               if(_loc4_ == param1)
               {
                  _loc5_ = true;
               }
            }
            if(_loc5_)
            {
               throw new Error("");
            }
            if(param2 >= this.numChildren)
            {
               this.childrenArray.push(param1);
            }
            else
            {
               this.childrenArray.splice(param2,0,param1);
            }
            return;
         }
         throw new Error("");
      }
      
      public function removeChild(param1:INode) : INode
      {
         return this.removeChildByID(param1.id);
      }
      
      public function removeChildAt(param1:uint) : INode
      {
         var _loc2_:INode = null;
         if(param1 >= this.numChildren)
         {
            return null;
         }
         _loc2_ = INode(this.childrenArray[param1]);
         return this.removeChildByID(_loc2_.id);
      }
      
      public function removeChildByID(param1:String) : INode
      {
         var _loc3_:uint = 0;
         var _loc4_:IsoEvent = null;
         var _loc2_:INode = this.getChildByID(param1);
         if(_loc2_)
         {
            Node(_loc2_).parentNode = null;
            while(_loc3_ < this.childrenArray.length)
            {
               if(_loc2_ == this.childrenArray[_loc3_])
               {
                  this.childrenArray.splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
            _loc4_ = new IsoEvent(IsoEvent.CHILD_REMOVED);
            _loc4_.newValue = _loc2_;
            dispatchEvent(_loc4_);
         }
         return _loc2_;
      }
      
      public function removeAllChildren() : void
      {
         var _loc1_:INode = null;
         for each(_loc1_ in this.childrenArray)
         {
            Node(_loc1_).parentNode = null;
         }
         this.childrenArray = null;
      }
      
      public function getChildByID(param1:String) : INode
      {
         var _loc2_:String = null;
         var _loc3_:INode = null;
         if(null != this.childrenArray)
         {
            for each(_loc3_ in this.childrenArray)
            {
               _loc2_ = _loc3_.id;
               if(_loc2_ == param1)
               {
                  return _loc3_;
               }
            }
         }
         return null;
      }
   }
}

