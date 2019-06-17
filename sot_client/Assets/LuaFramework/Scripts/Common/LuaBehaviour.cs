using UnityEngine;
using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.UI;

namespace LuaFramework {
    public class LuaBehaviour : View {
        private string data = null;
        private Dictionary<string, LuaFunction> buttons = new Dictionary<string, LuaFunction>();

        private bool mUsingOnEnable = false;
        public bool UsingOnEnable
        {
            get
            {
                return mUsingOnEnable;
            }
            set
            {
                mUsingOnEnable = value;
            }
        }

        private bool mUsingOnDisable = false;
        public bool UsingOnDisable
        {
            get
            {
                return mUsingOnDisable;
            }
            set
            {
                mUsingOnDisable = value;
            }
        }

        /// <summary>
        /// lua 对象
        /// </summary>
        private LuaState mLuaState = null;
        private LuaTable mLuaTable = null;

        private LuaFunction mFixedUpdateFunc = null;
        private LuaFunction mUpdateFunc = null;
        private LuaFunction mLateUpdateFunc = null;

        private LuaFunction mOnEnableFunc = null;
        private LuaFunction mOnDisableFunc = null;

        private bool mIsStarted = false;

        protected void Awake() {
            //Util.CallMethod(name, "Awake", gameObject);

            //LuaFunction awakeFunc = mLuaTable.GetLuaFunction("Awake") as LuaFunction;
            //if (awakeFunc != null)
            //{
            //    awakeFunc.BeginPCall();
            //    awakeFunc.Push(mLuaTable);
            //    awakeFunc.PCall();
            //    awakeFunc.EndPCall();

            //    awakeFunc.Dispose();
            //    awakeFunc = null;
            //}
        }

        protected void Start() {
            //Util.CallMethod(name, "Start");
            if (!CheckValid()) return;

            LuaFunction startFunc = mLuaTable.GetLuaFunction("Start") as LuaFunction;
            if (startFunc != null)
            {
                startFunc.BeginPCall();
                startFunc.Push(mLuaTable);
                startFunc.PCall();
                startFunc.EndPCall();

                startFunc.Dispose();
                startFunc = null;
            }

            AddUpdate();
            mIsStarted = true;
        }

        protected void OnClick()
        {
            Util.CallMethod(name, "OnClick");
        }
    
        protected void OnClickEvent(GameObject go) {
            Util.CallMethod(name, "OnClick", go);
        }

        private void OnEnable()
        {
            if (UsingOnEnable)
            {
                if (!CheckValid()) return;

                if (mOnEnableFunc == null)
                {
                    mOnEnableFunc = mLuaTable.GetLuaFunction("OnEnable") as LuaFunction;
                }
                if (mOnEnableFunc != null)
                {
                    mOnEnableFunc.BeginPCall();
                    mOnEnableFunc.PCall();
                    mOnEnableFunc.EndPCall();
                }
            }

            if (mIsStarted)
            {
                AddUpdate();
            }
        }

        private void OnDisable()
        {
            if (UsingOnDisable)
            {
                if (!CheckValid()) return;

                if (mOnDisableFunc == null)
                {
                    mOnDisableFunc = mLuaTable.GetLuaFunction("OnDisable") as LuaFunction;
                }
                if (mOnDisableFunc != null)
                {
                    mOnDisableFunc.BeginPCall();
                    mOnDisableFunc.PCall();
                    mOnDisableFunc.EndPCall();
                }
            }

            RemoveUpdate();
        }

        /// <summary>
        /// 添加单击事件
        /// </summary>
        public void AddClick(GameObject go, LuaFunction luafunc) {
            if (!CheckValid()) return;
            if (go == null || luafunc == null) return;
            if (!buttons.ContainsKey(go.name))
            {
                buttons.Add(go.name, luafunc);
                go.GetComponent<Button>().onClick.AddListener(
                    delegate ()
                    {
                        luafunc.BeginPCall();
                        luafunc.Push(go);
                        luafunc.PCall();
                        luafunc.EndPCall();
                    }
                );
            }
        }

        /// <summary>
        /// 删除单击事件
        /// </summary>
        /// <param name="go"></param>
        public void RemoveClick(GameObject go) {
            if (!CheckValid()) return;
            if (go == null) return;
            LuaFunction luafunc = null;
            if (buttons.TryGetValue(go.name, out luafunc))
            {
                luafunc.Dispose();
                luafunc = null;
                buttons.Remove(go.name);
            }
        }

        /// <summary>
        /// 清除单击事件
        /// </summary>
        public void ClearClick() {
            foreach (var de in buttons)
            {
                if (de.Value != null)
                {
                    de.Value.Dispose();
                }
            }
            buttons.Clear();
        }

        //-----------------------------------------------------------------
        protected void OnDestroy() {
#if ASYNC_MODE
            string abName = name.ToLower().Replace("panel", "");
            ResManager.UnloadAssetBundle(abName + AppConst.ExtName);
#endif
            if (!CheckValid()) return;
            ClearClick();
            LuaFunction destroyFunc = mLuaTable.GetLuaFunction("OnDestroy") as LuaFunction;
            if (destroyFunc != null)
            {
                destroyFunc.BeginPCall();
                destroyFunc.PCall();
                destroyFunc.EndPCall();

                destroyFunc.Dispose();
                destroyFunc = null;
            }

            SafeRelease(ref mFixedUpdateFunc);
            SafeRelease(ref mUpdateFunc);
            SafeRelease(ref mLateUpdateFunc);
            SafeRelease(ref mOnEnableFunc);
            SafeRelease(ref mOnDisableFunc);
            SafeRelease(ref mLuaTable);

            Util.ClearMemory();
            Debug.Log("~" + name + " was destroy!");
        }

        public void Init(LuaTable tb)
        {
            LuaManager luaMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            mLuaState = luaMgr.GetLuaState();
            if (mLuaState == null) return;

            if (tb == null)
            {
                mLuaTable = mLuaState.GetTable(name);
            }
            else
            {
                mLuaTable = tb;
            }
            if (mLuaTable == null)
            {
                Debug.LogWarning("mLuaTable is null:" + name);
                return;
            }
            mLuaTable["gameObject"] = gameObject;
            mLuaTable["transform"] = transform;
            mLuaTable["lua_behaviour"] = this;

            LuaFunction awakeFunc = mLuaTable.GetLuaFunction("Awake") as LuaFunction;
            if (awakeFunc != null)
            {
                awakeFunc.BeginPCall();
                awakeFunc.Push(mLuaTable);
                awakeFunc.PCall();
                awakeFunc.EndPCall();

                awakeFunc.Dispose();
                awakeFunc = null;
            }

            mUpdateFunc = mLuaTable.GetLuaFunction("Update") as LuaFunction;
            mFixedUpdateFunc = mLuaTable.GetLuaFunction("FixedUpdate") as LuaFunction;
            mLateUpdateFunc = mLuaTable.GetLuaFunction("LateUpdate") as LuaFunction;
        }

        private void AddUpdate()
        {
            if (!CheckValid()) return;

            LuaManager luaMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            LuaLooper luaLooper = luaMgr.GetLuaLooper();

            if (luaLooper == null) return;

            if (mUpdateFunc != null)
            {
                luaLooper.UpdateEvent.Add(mUpdateFunc, mLuaTable);
            }

            if (mLateUpdateFunc != null)
            {
                luaLooper.LateUpdateEvent.Add(mLateUpdateFunc, mLuaTable);
            }

            if (mFixedUpdateFunc != null)
            {
                luaLooper.FixedUpdateEvent.Add(mFixedUpdateFunc, mLuaTable);
            }
        }

        private void RemoveUpdate()
        {
            if (!CheckValid()) return;

            LuaManager luaMgr = AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua);
            LuaLooper luaLooper = luaMgr.GetLuaLooper();

            if (mUpdateFunc != null)
            {
                luaLooper.UpdateEvent.Remove(mUpdateFunc, mLuaTable);
            }
            if (mLateUpdateFunc != null)
            {
                luaLooper.LateUpdateEvent.Remove(mLateUpdateFunc, mLuaTable);
            }
            if (mFixedUpdateFunc != null)
            {
                luaLooper.FixedUpdateEvent.Remove(mFixedUpdateFunc, mLuaTable);
            }
        }
        private bool CheckValid()
        {
            if (mLuaState == null) return false;
            if (mLuaTable == null) return false;
            return true;
        }

        private void SafeRelease(ref LuaFunction func)
        {
            if (func != null)
            {
                func.Dispose();
                func = null;
            }
        }

        private void SafeRelease(ref LuaTable table)
        {
            if (table != null)
            {
                table.Dispose();
                table = null;
            }
        }
    }
}