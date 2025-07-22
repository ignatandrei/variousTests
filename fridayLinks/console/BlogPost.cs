using OpenLiveWriter.CoreServices;
using OpenLiveWriter.Extensibility.BlogClient;
using OpenLiveWriter.Interop.Com.StructuredStorage;
using OpenLiveWriter.PostEditor;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml.Linq;

namespace OpenLiveWriterPostCreator;

// COM Structured Storage interop declarations
[ComImport]
[Guid("0000000b-0000-0000-C000-000000000046")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface IStorage
{
    void CreateStream(string pwcsName, uint grfMode, uint reserved1, uint reserved2, out IStream ppstm);
    void OpenStream(string pwcsName, IntPtr reserved1, uint grfMode, uint reserved2, out IStream ppstm);
    void CreateStorage(string pwcsName, uint grfMode, uint reserved1, uint reserved2, out IStorage ppstg);
    void OpenStorage(string pwcsName, IStorage? pstgPriority, uint grfMode, IntPtr snbExclude, uint reserved, out IStorage ppstg);
    void CopyTo(uint ciidExclude, Guid[] rgiidExclude, IntPtr snbExclude, IStorage pstgDest);
    void MoveElementTo(string pwcsName, IStorage pstgDest, string pwcsNewName, uint grfFlags);
    void Commit(uint grfCommitFlags);
    void Revert();
    void EnumElements(uint reserved1, IntPtr reserved2, uint reserved3, out IEnumSTATSTG ppenum);
    void DestroyElement(string pwcsName);
    void RenameElement(string pwcsOldName, string pwcsNewName);
    void SetElementTimes(string pwcsName, System.Runtime.InteropServices.ComTypes.FILETIME pctime, System.Runtime.InteropServices.ComTypes.FILETIME patime, System.Runtime.InteropServices.ComTypes.FILETIME pmtime);
    void SetClass(ref Guid clsid);
    void SetStateBits(uint grfStateBits, uint grfMask);
    void Stat(out System.Runtime.InteropServices.ComTypes.STATSTG pstatstg, uint grfStatFlag);
}

[ComImport]
[Guid("0000000c-0000-0000-C000-000000000046")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface IStream
{
    void Read(byte[] pv, uint cb, out uint pcbRead);
    void Write(byte[] pv, uint cb, out uint pcbWritten);
    void Seek(long dlibMove, uint dwOrigin, out long plibNewPosition);
    void SetSize(long libNewSize);
    void CopyTo(IStream pstm, long cb, out long pcbRead, out long pcbWritten);
    void Commit(uint grfCommitFlags);
    void Revert();
    void LockRegion(long libOffset, long cb, uint dwLockType);
    void UnlockRegion(long libOffset, long cb, uint dwLockType);
    void Stat(out System.Runtime.InteropServices.ComTypes.STATSTG pstatstg, uint grfStatFlag);
    void Clone(out IStream ppstm);
}

[ComImport]
[Guid("0000000d-0000-0000-C000-000000000046")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
internal interface IEnumSTATSTG
{
    void Next(uint celt, out System.Runtime.InteropServices.ComTypes.STATSTG rgelt, out uint pceltFetched);
    void Skip(uint celt);
    void Reset();
    void Clone(out IEnumSTATSTG ppenum);
}

internal static class Ole32
{
    [DllImport("ole32.dll")]
    public static extern int StgCreateDocfile(
        [MarshalAs(UnmanagedType.LPWStr)] string pwcsName,
        uint grfMode,
        uint reserved,
        out IStorage ppstgOpen);

    [DllImport("ole32.dll")]
    public static extern int StgOpenStorage(
        [MarshalAs(UnmanagedType.LPWStr)] string pwcsName,
        IStorage pstgPriority,
        uint grfMode,
        IntPtr snbExclude,
        uint reserved,
        out IStorage ppstgOpen);

    public const uint STGM_CREATE = 0x00001000;
    public const uint STGM_READ = 0x00000000;
    public const uint STGM_WRITE = 0x00000001;
    public const uint STGM_READWRITE = 0x00000002;
    public const uint STGM_SHARE_EXCLUSIVE = 0x00000010;
    public const uint STGM_SHARE_DENY_WRITE = 0x00000020;
    public const uint STGM_TRANSACTED = 0x00010000;
    public const uint STGC_DEFAULT = 0;
}


public class OpenLiveWriterPostGenerator
{
    

    public static void SavePost(BlogPost post, string filePath)
    {
        SavePostAsStructuredStorage(post, filePath);
    }

    private static void SavePostAsStructuredStorage(BlogPost post, string filePath)
    {
        ApplicationEnvironment.Initialize(Assembly.GetExecutingAssembly(),
                        Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), @"\Windows Live\Writer\"));

        PostEditorFile.Initialize();

        PostEditorFile pef = PostEditorFile.CreateNew( new DirectoryInfo(Path.GetDirectoryName(filePath!)!));
        var bef= new BlogPostEditingContext(post.Id, post)  ;
        pef.SaveBlogPost(bef);
    }

    
    
    }
