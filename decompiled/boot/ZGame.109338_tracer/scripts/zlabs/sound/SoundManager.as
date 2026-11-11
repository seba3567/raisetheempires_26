package zlabs.sound
{
   import Engine.Managers.AssetUrlManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.media.Sound;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.core.ITickedObject;
   import zlabs.debug.Logger;
   import zlabs.resource.MP3Resource;
   import zlabs.resource.SWFResource;
   import zlabs.resource.SoundResource;
   import zlabs.resource.helpers.GroupResourceLoader;
   
   public class SoundManager implements ISoundManager, ITickedObject
   {
      
      public static const MUSIC_MIXER_CATEGORY:String = "music";
      
      public static const SFX_MIXER_CATEGORY:String = "sfx";
      
      public var maxConcurrentSounds:int = 5;
      
      protected var playingSounds:Array = [];
      
      protected var categories:Object = {};
      
      protected var rootCategory:SoundCategory = new SoundCategory();
      
      protected var cachedSounds:Object = {};
      
      protected var soundData:Dictionary = new Dictionary();
      
      public function SoundManager()
      {
         super();
         this.createCategory(MUSIC_MIXER_CATEGORY);
         this.createCategory(SFX_MIXER_CATEGORY);
      }
      
      public function initFromSettings(param1:XMLList, param2:String) : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         for each(_loc3_ in param1)
         {
            _loc4_ = _loc3_.@name.toString();
            _loc5_ = "";
            if(_loc3_.@url.toString())
            {
               _loc5_ = AssetUrlManager.instance.lookUpUrl(param2 + _loc3_.@url.toString());
            }
            _loc6_ = _loc3_.@className.toString();
            this.soundData[_loc4_] = {
               "name":_loc4_,
               "url":_loc5_,
               "className":_loc6_
            };
         }
      }
      
      private function clearChannel(param1:String) : Boolean
      {
         var _loc4_:SoundHandle = null;
         var _loc2_:SoundHandle = null;
         var _loc3_:Number = GlobalEngine.serverTime / 1000;
         for each(_loc4_ in this.playingSounds)
         {
            if(_loc4_.category == param1)
            {
               if(!_loc4_.isPlaying)
               {
                  _loc4_.stop();
                  return true;
               }
               if(_loc4_.startTime < _loc3_)
               {
                  _loc2_ = _loc4_;
                  _loc3_ = _loc4_.startTime;
               }
            }
         }
         if(_loc2_ != null)
         {
            _loc2_.stop();
            return true;
         }
         return false;
      }
      
      public function play(param1:*, param2:Function = null, param3:String = "sfx", param4:Number = 0, param5:int = 0, param6:Number = 0, param7:Class = null) : SoundHandle
      {
         var actualSound:Sound;
         var sh:SoundHandle;
         var categoryRef:SoundCategory = null;
         var sound:* = param1;
         var onLoad:Function = param2;
         var category:String = param3;
         var pan:Number = param4;
         var loopCount:int = param5;
         var startDelay:Number = param6;
         var resourceType:Class = param7;
         if(this.playingSounds.length > this.maxConcurrentSounds)
         {
            if(!this.clearChannel(category))
            {
               return null;
            }
         }
         actualSound = null;
         if(sound is Sound)
         {
            actualSound = sound as Sound;
         }
         else if(sound is SoundResource)
         {
            actualSound = (sound as SoundResource).soundObject;
         }
         else
         {
            if(!(sound is String))
            {
               throw new Error("Parameter sound is of unexpected type. Should be Sound, SoundResource, or String.");
            }
            if(!this.cachedSounds[sound])
            {
               if(!resourceType)
               {
                  resourceType = MP3Resource;
               }
               Zlab.resourceManager.load(sound,resourceType,function(param1:*):void
               {
                  cachedSounds[sound] = param1;
                  play(param1 as SoundResource,onLoad,category,pan,loopCount,startDelay);
               });
               return null;
            }
            actualSound = (this.cachedSounds[sound] as SoundResource).soundObject;
         }
         sh = new SoundHandle(this,actualSound,category,pan,loopCount,startDelay);
         if(sh.valid)
         {
            categoryRef = this.categories[category] as SoundCategory;
            if(categoryRef)
            {
               sh.transform = SoundCategory.applyCategoriesToTransform(categoryRef.muted,sh.pan,sh.volume,categoryRef);
            }
            this.playingSounds.push(sh);
            if(null != onLoad)
            {
               onLoad(sh);
            }
         }
         return sh;
      }
      
      public function stream(param1:String, param2:String = "sfx", param3:Number = 0, param4:int = 1, param5:Number = 0) : SoundHandle
      {
         var sh:SoundHandle;
         var ur:URLRequest = null;
         var s:Sound = null;
         var url:String = param1;
         var category:String = param2;
         var pan:Number = param3;
         var loopCount:int = param4;
         var startDelay:Number = param5;
         try
         {
            ur = new URLRequest(url);
            s = new Sound();
            s.addEventListener(IOErrorEvent.IO_ERROR,this._handleStreamFailure,false,0,true);
            s.load(ur);
         }
         catch(e:Error)
         {
            Logger.error(this,"stream","Failed to stream Sound due to:" + e.toString() + "\n" + e.getStackTrace());
            return null;
         }
         sh = new SoundHandle(this,s,category,pan,loopCount,startDelay);
         if(sh.valid)
         {
            this.playingSounds.push(sh);
            return sh;
         }
         return null;
      }
      
      protected function _handleStreamFailure(param1:IOErrorEvent) : void
      {
         Logger.error(this,"_handleStreamFailure","Error streaming sound: " + param1.toString());
      }
      
      public function set muted(param1:Boolean) : void
      {
         this.rootCategory.muted = param1;
         this.rootCategory.dirty = true;
      }
      
      public function get muted() : Boolean
      {
         return this.rootCategory.muted;
      }
      
      public function set volume(param1:Number) : void
      {
         this.rootCategory.transform.volume = param1;
         this.rootCategory.dirty = true;
      }
      
      public function get volume() : Number
      {
         return this.rootCategory.transform.volume;
      }
      
      public function createCategory(param1:String) : void
      {
         this.categories[param1] = new SoundCategory();
      }
      
      public function removeCategory(param1:String) : void
      {
         this.categories[param1] = null;
         delete this.categories[param1];
      }
      
      public function toggleMusic() : Boolean
      {
         this.setCategoryMuted(SoundManager.MUSIC_MIXER_CATEGORY,this.getCategoryMuted(SoundManager.MUSIC_MIXER_CATEGORY) == false);
         return this.getCategoryMuted(SoundManager.MUSIC_MIXER_CATEGORY);
      }
      
      public function toggleSFX() : Boolean
      {
         this.setCategoryMuted(SoundManager.SFX_MIXER_CATEGORY,this.getCategoryMuted(SoundManager.SFX_MIXER_CATEGORY) == false);
         return this.getCategoryMuted(SoundManager.SFX_MIXER_CATEGORY);
      }
      
      public function setCategoryMuted(param1:String, param2:Boolean) : void
      {
         this.categories[param1].muted = param2;
         this.categories[param1].dirty = true;
      }
      
      public function getCategoryMuted(param1:String) : Boolean
      {
         return this.categories[param1].muted;
      }
      
      public function setCategoryVolume(param1:String, param2:Number) : void
      {
         this.categories[param1].transform.volume = param2;
         this.categories[param1].dirty = true;
      }
      
      public function getCategoryVolume(param1:String) : Number
      {
         return this.categories[param1].transform.volume;
      }
      
      public function setCategoryTransform(param1:String, param2:SoundTransform) : void
      {
         this.categories[param1].transform = param2;
         this.categories[param1].dirty = true;
      }
      
      public function getCategoryTransform(param1:String) : SoundTransform
      {
         return this.categories[param1].transform;
      }
      
      public function stopCategorySounds(param1:String) : void
      {
         var _loc2_:* = 0;
         while(_loc2_ < this.playingSounds.length)
         {
            if((this.playingSounds[_loc2_] as SoundHandle).category == param1)
            {
               (this.playingSounds[_loc2_] as SoundHandle).stop();
               _loc2_--;
            }
            _loc2_++;
         }
      }
      
      public function stopAll() : void
      {
         while(this.playingSounds.length)
         {
            (this.playingSounds[this.playingSounds.length - 1] as SoundHandle).stop();
         }
      }
      
      public function getSoundHandlesInCategory(param1:String, param2:Array) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < this.playingSounds.length)
         {
            if((this.playingSounds[_loc3_] as SoundHandle).category == param1)
            {
               param2.push(this.playingSounds[_loc3_]);
            }
            _loc3_++;
         }
      }
      
      internal function updateSounds() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:SoundHandle = null;
         var _loc5_:String = null;
         var _loc6_:SoundHandle = null;
         if(!this.rootCategory.dirty)
         {
            for(_loc2_ in this.categories)
            {
               if(this.categories[_loc2_].dirty != false)
               {
                  _loc3_ = 0;
                  while(_loc3_ < this.playingSounds.length)
                  {
                     _loc4_ = this.playingSounds[_loc3_] as SoundHandle;
                     if(_loc4_.category == _loc2_)
                     {
                        _loc4_.dirty = true;
                     }
                     _loc3_++;
                  }
                  this.categories[_loc2_].dirty = false;
               }
            }
         }
         else
         {
            for(_loc5_ in this.categories)
            {
               this.categories[_loc5_].dirty = false;
            }
         }
         _loc1_ = 0;
         while(_loc1_ < this.playingSounds.length)
         {
            _loc6_ = this.playingSounds[_loc1_] as SoundHandle;
            if(!(_loc6_.dirty == false && this.rootCategory.dirty == false))
            {
               if(_loc6_.channel)
               {
                  _loc6_.channel.soundTransform = SoundCategory.applyCategoriesToTransform(false,_loc6_.pan,_loc6_.volume,this.rootCategory,this.categories[_loc6_.category]);
               }
               _loc6_.dirty = false;
            }
            _loc1_++;
         }
         this.rootCategory.dirty = false;
      }
      
      public function chooseAndPlaySound(param1:Array) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:String = null;
         if(param1.length == 1)
         {
            _loc2_ = param1[0] as String;
         }
         else if(param1.length > 0)
         {
            _loc3_ = Math.floor(Math.random() * param1.length);
            _loc2_ = param1[_loc3_] as String;
         }
         if(_loc2_ != null && Boolean(this.soundData[_loc2_]))
         {
            this.playSoundObject(this.soundData[_loc2_]);
         }
      }
      
      public function playSoundObject(param1:Object) : void
      {
         var _loc2_:Class = null;
         var _loc3_:Sound = null;
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:GroupResourceLoader = null;
         if(!param1["url"])
         {
            return;
         }
         _loc4_ = param1["url"];
         _loc5_ = _loc4_.indexOf("mp3");
         if(_loc5_ > 0)
         {
            this.play(_loc4_);
         }
         else
         {
            _loc6_ = new GroupResourceLoader(_loc4_,param1.className);
            _loc6_.addEventListener(Event.COMPLETE,this.onLoadedComplete,false,0,true);
         }
      }
      
      public function onLoadedComplete(param1:Event) : void
      {
         var _loc3_:String = null;
         var _loc4_:SWFResource = null;
         var _loc5_:Class = null;
         var _loc2_:GroupResourceLoader = param1.target as GroupResourceLoader;
         if(_loc2_.m_items)
         {
            _loc3_ = _loc2_.m_items[0];
            _loc4_ = _loc2_.resource;
            _loc5_ = _loc4_.getAssetClass(_loc3_);
            if(_loc5_)
            {
               this.play(new _loc5_());
            }
            else
            {
               Logger.error(this,"onLoadedComplete","unable to find class \'" + _loc3_ + "\' in swf");
            }
         }
         else
         {
            Logger.error(this,"onLoadedComplete","groupLoader has no items");
         }
         _loc2_.destroy();
      }
      
      public function setDisplayObjectSoundToGlobalSound(param1:DisplayObject) : void
      {
         var _loc2_:SoundTransform = null;
         if(param1 is MovieClip)
         {
            _loc2_ = new SoundTransform();
            if(this.getCategoryMuted(SoundManager.SFX_MIXER_CATEGORY))
            {
               _loc2_.volume = 0;
            }
            else
            {
               _loc2_.volume = 1;
            }
            MovieClip(param1).soundTransform = _loc2_;
         }
      }
      
      public function onTick(param1:Number) : void
      {
         this.updateSounds();
      }
      
      internal function isInPlayingSounds(param1:SoundHandle) : Boolean
      {
         var _loc2_:int = this.playingSounds.indexOf(param1);
         return _loc2_ != -1;
      }
      
      internal function removeSoundHandle(param1:SoundHandle) : void
      {
         var _loc2_:int = this.playingSounds.indexOf(param1);
         if(_loc2_ == -1)
         {
            throw new Error("Could not find in list of playing sounds!");
         }
         this.playingSounds.splice(_loc2_,1);
      }
   }
}

