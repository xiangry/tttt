using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using LuaInterface;

namespace LuaFramework {
    public class PanelManager : Manager {
        private Transform parent;

        Transform Parent {
            get {
                if (parent == null) {
                    GameObject go = GameObject.FindWithTag("GuiCamera");
                    //GameObject go = GameObject.FindWithTag("Canvas");
                    if (go != null) parent = go.transform;
                }
                return parent;
            }
        }

        public void CreatePanel(string assetName, LuaTable luaTable = null, LuaFunction func = null)
        {
            if (Parent.Find(assetName) != null)
            {
                Debug.LogError("asset bundle already have in Hierarchy " + assetName);
                return;
            }

            string abName = assetName.ToLower() + AppConst.ExtName;
#if ASYNC_MODE
            ResManager.LoadPrefab(abName, assetName, delegate (UnityEngine.Object[] objs)
            {
                if (objs.Length == 0) return;
                GameObject prefab = objs[0] as GameObject;
                if (prefab == null) return;

                GameObject go = Instantiate(prefab) as GameObject;
                go.name = assetName;
                go.layer = LayerMask.NameToLayer("Default");
                go.transform.SetParent(Parent);
                go.transform.localScale = Vector3.one;
                go.transform.localPosition = Vector3.zero;
                go.AddComponent<LuaBehaviour>();

                LuaBehaviour luaBehavior = Tools.SafeGetComponent<LuaBehaviour>(go);
                luaBehavior.Init(luaTable);

                if (func != null)
                {
                    func.Call(go);

                    func.Dispose();
                    func = null;
                }
                Debug.LogWarning("CreatePanel::>> " + name + " " + prefab);
            });
#else
            GameObject prefab = ResManager.LoadAsset<GameObject>(abName, assetName);
            if (prefab == null) return;

            GameObject go = Instantiate(prefab) as GameObject;
            go.name = assetName;
            go.layer = LayerMask.NameToLayer("Default");
            go.transform.SetParent(Parent);
            go.transform.localScale = Vector3.one;
            go.transform.localPosition = Vector3.zero;
            go.AddComponent<LuaBehaviour>();

            LuaBehaviour luaBehavior = Tools.SafeGetComponent<LuaBehaviour>(go);
            luaBehavior.Init(luaTable);

            if (func != null)
            {
                func.Call(go);

                func.Dispose();
                func = null;
            }
            Debug.LogWarning("CreatePanel::>> " + name + " " + prefab);
#endif
        }

        /// <summary>
        /// ������壬������Դ������
        /// </summary>
        /// <param name="type"></param>
        public void CreatePanel(string name, string abName = null, LuaFunction func = null) {
            string assetName = name + "Panel";
            if(abName == null)
            {
                abName = name.ToLower() + AppConst.ExtName;
            }
            else
            {
                abName = abName.ToLower() + AppConst.ExtName;
            }
            Debug.Log("CreatePanel assetName " + assetName);
            Debug.Log("CreatePanel abName " + abName);
            if (Parent.Find(name) != null) return;

#if ASYNC_MODE
            ResManager.LoadPrefab(abName, assetName, delegate(UnityEngine.Object[] objs) {
                if (objs.Length == 0) return;
                GameObject prefab = objs[0] as GameObject;
                if (prefab == null) return;

                GameObject go = Instantiate(prefab) as GameObject;
                go.name = assetName;
                go.layer = LayerMask.NameToLayer("Default");
                go.transform.SetParent(Parent);
                go.transform.localScale = Vector3.one;
                go.transform.localPosition = Vector3.zero;
                go.AddComponent<LuaBehaviour>();

                if (func != null) func.Call(go);
                Debug.LogWarning("CreatePanel::>> " + name + " " + prefab);
            });
#else
            GameObject prefab = ResManager.LoadAsset<GameObject>(name, assetName);
            if (prefab == null) return;

            GameObject go = Instantiate(prefab) as GameObject;
            go.name = assetName;
            go.layer = LayerMask.NameToLayer("Default");
            go.transform.SetParent(Parent);
            go.transform.localScale = Vector3.one;
            go.transform.localPosition = Vector3.zero;
            go.AddComponent<LuaBehaviour>();

            if (func != null) func.Call(go);
            Debug.LogWarning("CreatePanel::>> " + name + " " + prefab);
#endif
        }

        /// <summary>
        /// �ر����
        /// </summary>
        /// <param name="name"></param>
        public void ClosePanel(string assetName) {
            var panelObj = Parent.Find(assetName);
            if (panelObj == null) return;
            Destroy(panelObj.gameObject);
        }
    }
}