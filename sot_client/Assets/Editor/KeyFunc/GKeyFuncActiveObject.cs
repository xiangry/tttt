using UnityEditor;
using UnityEngine;

public class GKeyFuncActiveObject : ScriptableObject
{
    public const string KeyActiveObj = "Edit/Key Func/DisableSelectGameObect #d";

    //根据当前有没有选中物体来判断可否用快捷键
    [MenuItem(KeyActiveObj, true)]
    static bool ValidateSelectEnableDisable()
    {
        GameObject[] go = GetSelectedGameObjects() as GameObject[];

        if (go == null || go.Length == 0)
            return false;
        return true;
    }

    [MenuItem(KeyActiveObj)]
    static void SeletEnable()
    {
        bool enable = false;
        GameObject[] gos = GetSelectedGameObjects() as GameObject[];

        foreach (GameObject go in gos)
        {
            enable = !go.activeInHierarchy;
            EnableGameObject(go, enable);
        }
    }

    //获得选中的物体
    static GameObject[] GetSelectedGameObjects()
    {
        return Selection.gameObjects;
    }

    //激活或关闭当前选中物体
    public static void EnableGameObject(GameObject parent, bool enable)
    {
        parent.gameObject.SetActive(enable);
    }
}
