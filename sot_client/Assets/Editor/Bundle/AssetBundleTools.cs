using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Text;
using System;
using System.Security.Cryptography;

public class AssetBundleTools
{
    #region 菜单
    // 菜单===========================================================
    //[MenuItem("Export/打包所有设置AssetLable项目")]
    //public static void BundlerAssets()
    //{
    //    AssetBundleTools.BuildAssetBundles(BuildAssetBundleOptions.None);
    //}

    //[MenuItem("Export/打包选中文件夹下所有项目")]
    //public static void BundSelectionAssets()
    //{
    //    AssetBundleTools.SetAssetBundleBuilds();
    //    //while (true)
    //    //{
    //    //    if (AssetBundleTools.GetState())
    //    //        break;
    //    //    else
    //    //        Debug.LogError("等待.....");
    //    //}
    //    AssetBundleTools.BuildAssetBundles(AssetBundleTools.GetAssetBundleBuilds(), BuildAssetBundleOptions.None);
    //}

    //[MenuItem("Export/设置Assetbundle名字")]
    //public static void SetAssetBundellabls()
    //{
    //    AssetBundleTools.CheckFileSystemInfo();
    //}

    //[MenuItem("Export/设置配置文件")]
    //public static void SetAssetConfig()
    //{
    //    AssetBundleTools.CheckAssetBundleDir(AssetBundleTools.GetAssetBundleStringPath());
    //}

    //[MenuItem("Export/测试")]
    //static void PackAsset()
    //{
    //    Debug.Log("Make AssetsBundle");
    //    //  
    //    List<AssetBundleBuild> builds = new List<AssetBundleBuild>();
    //    AssetBundleBuild build = new AssetBundleBuild();

    //    build.assetBundleName = "first";
    //    build.assetBundleVariant = "u3";
    //    // build.assetNames[0] = "Assets/Resources/mascot.prefab";  
    //    build.assetNames = new string[] { "Assets/PNG/结算副本.png" };
    //    builds.Add(build);
    //    // 第一个参数为打包文件的输出路径，第二个参数为打包资源的列表，第三个参数为打包需要的操作，第四个为打包的输出的环境  
    //    //BuildPipeline.BuildAssetBundles(@"Assets/Bundle", builds.ToArray(),
    //    //    BuildAssetBundleOptions.None, BuildTarget.Android);
    //    BuildPipeline.BuildAssetBundles(@"Assets/Bundle", builds.ToArray(), BuildAssetBundleOptions.None, BuildTarget.Android);
    //    Debug.Log("11111" + builds.ToArray() + "222222");
    //}
    // 菜单===========================================================
    #endregion

    #region asset 打包
    /// <summary>
    /// 检查目标文件下的文件系统
    /// </summary>
    public static void CheckFileSystemInfo()  //检查目标目录下的文件系统
    {
        UnityEngine.Object[] objs = Selection.objects;
        foreach(UnityEngine.Object obj in objs)
        {
            string path = AssetDatabase.GetAssetPath(obj);//选中的文件夹  //目录结构  Assets/Resources 没有Application.datapath 
            if (File.Exists(path))
            {
                SetBundleName(path);
            }
            else if (Directory.Exists(path))
            {
                CoutineCheck(path);
            }
        }
    }

    public static void CheckFileOrDirectory(FileSystemInfo fileSystemInfo, string path) //判断是文件还是文件夹
    {
        FileInfo fileInfo = fileSystemInfo as FileInfo;
        if (fileInfo != null)
        {
            SetBundleName(path);
        }
        else
        {
            CoutineCheck(path);
        }
    }

    public static void CoutineCheck(string path)   //是文件，继续向下
    {
        DirectoryInfo directory = new DirectoryInfo(@path);
        FileSystemInfo[] fileSystemInfos = directory.GetFileSystemInfos();

        foreach (var item in fileSystemInfos)
        {
            // Debug.Log(item);
            int idx = item.ToString().LastIndexOf(@"\");
            string name = item.ToString().Substring(idx + 1);

            if (!name.Contains(".meta"))
            {
                CheckFileOrDirectory(item, path + "/" + name);  //item  文件系统，加相对路径
            }
        }
    }

    public static void SetBundleName(string path)  //设置assetbundle名字
    {
        //  Debug.LogError(path);
        var importer = AssetImporter.GetAtPath(path);
        string[] strs = path.Split('.');
        string[] dictors = strs[0].Split('/');
        string name = "";
        for (int i = 1; i < dictors.Length; i++)
        {
            if (i < dictors.Length - 1)
            {
                name += dictors[i] + "/";
            }
            else
            {
                name += dictors[i];
            }
        }
        if (importer != null)
        {
            importer.assetBundleName = name;
            importer.assetBundleVariant = "ab";
            // importer.assetBundleName = GetGUID(path);   //两种设置方式
            Debug.Log("importer name " + importer.assetBundleName);
        }
        else
            Debug.Log("importer是空的");
    }

    public static string GetGUID(string path)
    {
        return AssetDatabase.AssetPathToGUID(path);
    }

    //*****************配置文件设置***********************////////////

    static Dictionary<string, string> dicversoion = new Dictionary<string, string>(); //版本
    static Dictionary<string, string> dicurl = new Dictionary<string, string>();      //下载地址



    public static string GetAssetBundleStringPath()  //得到存放打包资源的文件路径
    {
        string path = Application.streamingAssetsPath;
        //Debug.Log(path);
        string[] strs = path.Split('/');
        int idx = 0;
        for (int i = 0; i < strs.Length; i++)
        {
            if (strs[i] == "Assets")
                idx = i;
        }
        // Debug.Log(idx);
        //path = strs[strs.Length - 2] + "/" + strs[strs.Length - 1];
        string str = "";
        for (int i = idx; i < strs.Length; i++)
        {
            if (i != strs.Length - 1)
                str += strs[i] + "/";
            else if (i == strs.Length - 1)
                str += strs[i];
            //Debug.Log(i);
        }
        path = str;
        return path;
        //Debug.Log(path);
    }

    public static void CheckAssetBundleDir(string path)   //是文件，继续向下
    {
        DirectoryInfo directory = new DirectoryInfo(@path);
        FileSystemInfo[] fileSystemInfos = directory.GetFileSystemInfos();

        foreach (var item in fileSystemInfos)
        {
            // Debug.Log(item);
            int idx = item.ToString().LastIndexOf(@"\");
            string name = item.ToString().Substring(idx + 1);

            if (!name.Contains(".meta"))
            {
                CheckAssetBundleFileOrDirectory(item, path + "/" + name);  //item  文件系统，加相对路径
            }
        }
    }

    public static void CheckAssetBundleFileOrDirectory(FileSystemInfo fileSystemInfo, string path) //判断是文件还是文件夹
    {
        FileInfo fileInfo = fileSystemInfo as FileInfo;
        if (fileInfo != null)
        {
            Debug.Log("不为空,MD5值==>" + GetMD5(path));
            // string guid = AssetDatabase.AssetPathToGUID(path);
            // Debug.Log("不为空,文件名字是==>>"+guid);
            Addconfigdic(fileInfo.Name, GetMD5(path));
        }
        else
        {
            CheckAssetBundleDir(path);
        }
    }

    public static string GetMD5(string path)
    {
        FileStream fs = new FileStream(path, FileMode.Open);
        MD5 md5 = new MD5CryptoServiceProvider();
        byte[] retVal = md5.ComputeHash(fs);
        fs.Close();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < retVal.Length; i++)
        {
            sb.Append(retVal[i].ToString("x2"));
        }
        return sb.ToString();
    }

    public static void Addconfigdic(string name, string verMd5)
    {
        dicversoion.Add(name, verMd5);
    }

    public static void CreateConfigFile(string path) //创建配置文件
    {

    }

    #region 不使用label方式打包
    // -------------------------------我是分割线------------------------------------
    //   割.............................
    static List<AssetBundleBuild> listassets = new List<AssetBundleBuild>();  //第二种打包方式用
    static List<DirectoryInfo> listfileinfo = new List<DirectoryInfo>();
    static int directoryCount = 0;
    static bool isover = false; //是否检查完成，可以打包
  
    public static bool GetState()
    {
        return isover;
    }

    public static AssetBundleBuild[] GetAssetBundleBuilds()
    {
        Debug.Log("ab count ---- " + listassets.Count);
        AssetBundleBuild ab = listassets[0];
        Debug.Log("ab " + ab.assetBundleName);
        Debug.Log("ab " + ab.assetNames);
        return listassets.ToArray();
    }

    public static void SetAssetBundleBuilds()
    {
        listfileinfo.Clear();
        listassets.Clear();
        isover = false;
        UnityEngine.Object[] objs = Selection.objects;
        foreach (UnityEngine.Object obj in objs)
        {
            string path = AssetDatabase.GetAssetPath(obj);//选中的文件夹  //目录结构  Assets/Resources 没有Application.datapath 
            if (File.Exists(path))
            {
                var fileInfo = new FileInfo(path);
                CheckFileOrDirectoryReturnBundleName(fileInfo, path);
            }
            else if (Directory.Exists(path))
            {
                SearchFileAssetBundleBuild(path);
            }
        }
    }

    public static void SearchFileAssetBundleBuild(string path)   //是文件，继续向下
    {
        directoryCount += 1;
        DirectoryInfo directory = new DirectoryInfo(@path);
        FileSystemInfo[] fileSystemInfos = directory.GetFileSystemInfos();
        foreach (var item in fileSystemInfos)
        {
            int idx = item.ToString().LastIndexOf(@"\");
            string name = item.ToString().Substring(idx + 1);
            if ((item as DirectoryInfo) != null)
                listfileinfo.Add(item as DirectoryInfo);
            if (!name.Contains(".meta"))
            {
                CheckFileOrDirectoryReturnBundleName(item, path + "/" + name);
            }
        }
        directoryCount -= 1;
        if (directoryCount == 0)
        {
            isover = true;
        }
    }

    public static string CheckFileOrDirectoryReturnBundleName(FileSystemInfo fileSystemInfo, string path) //判断是文件还是文件夹
    {
        FileInfo fileInfo = fileSystemInfo as FileInfo;
        if (fileInfo != null)
        {
            string[] strs = path.Split('.');
            string[] dictors = strs[0].Split('/');
            string name = "";
            for (int i = 1; i < dictors.Length; i++)
            {
                if (i < dictors.Length - 1)
                {
                    name += dictors[i] + "/";
                }
                else
                {
                    name += dictors[i];
                }
            }
            AssetBundleBuild assetBundleBuild = new AssetBundleBuild();
            assetBundleBuild.assetBundleName = name;
            assetBundleBuild.assetBundleVariant = "ab";
            assetBundleBuild.assetNames = new string[] { path };
            listassets.Add(assetBundleBuild);
            return name;
        }
        else
        {
            SearchFileAssetBundleBuild(path);
            return null;
        }
    }
    #endregion

    private static BuildTarget buildTarget;
    private static string outPutPlat;

    public static void ResetExportParams()
    {
#if UNITY_ANDROID   //安卓  
        buildTarget = BuildTarget.Android;
        outPutPlat = "Android";
#elif UNITY_IOS
        buildTarget = BuildTarget.iOS;
        outPutPlat = "IOS";
#else
        buildTarget = BuildTarget.StandaloneWindows;
        outPutPlat = "Windows";
#endif

#if UNITY_EDITOR
        outPutPlat = Application.streamingAssetsPath;
#else
        outPutPlat = "AssetBundles/" + outPutPlat;
#endif
        // 创建输出目录
        if (Directory.Exists(outPutPlat) == false)
        {
            Directory.CreateDirectory(outPutPlat);
        }
    }

    public static AssetBundleManifest BuildAssetBundles(AssetBundleBuild[] builds, BuildAssetBundleOptions assetBundleOptions)
    {
        ResetExportParams();
        return BuildPipeline.BuildAssetBundles(outPutPlat, builds, assetBundleOptions, buildTarget);
    }
    
    public static AssetBundleManifest BuildAssetBundles(BuildAssetBundleOptions assetBundleOptions)
    {
        ResetExportParams();
        return BuildPipeline.BuildAssetBundles(outPutPlat, assetBundleOptions, buildTarget);
    }
    #endregion

}