using UnityEngine;
using System.Collections;
using System.IO;
using System.Text;
using System;

public class Tools
{
    public static T SafeGetComponent<T>(GameObject go) where T : Component
    {
        if (go == null)
        {
            return null;
        }

        T ret = go.GetComponent<T>();
        if (ret == null)
        {
            ret = go.AddComponent<T>();
        }
        return ret;
    }
}
