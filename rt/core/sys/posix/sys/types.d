/**
 * D header file for POSIX.
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Sean Kelly,
              Alex Rønne Petersen
 * Standards: The Open Group Base Specifications Issue 6, IEEE Std 1003.1, 2004 Edition
 */

/*          Copyright Sean Kelly 2005 - 2009.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
module core.sys.posix.sys.types;

private import core.sys.posix.config;
private import core.stdc.stdint;
public import core.stdc.stddef;

version (OSX)
    version = Darwin;
else version (iOS)
    version = Darwin;
else version (TVOS)
    version = Darwin;
else version (WatchOS)
    version = Darwin;

version (Posix)
    version = Posixish;
else
version (dscripten)
    version = Posixish;

version (Posixish):
extern (C):

//
// bits/typesizes.h -- underlying types for *_t.
//
/*
__syscall_slong_t
__syscall_ulong_t
*/
version (CRuntime_Glibc)
{
    version (X86_64)
    {
        version (D_X32)
        {
            // X32 kernel interface is 64-bit.
            alias long slong_t;
            alias ulong ulong_t;
        }
        else
        {
            alias c_long slong_t;
            alias c_ulong ulong_t;
        }
    }
    else
    {
        alias c_long slong_t;
        alias c_ulong ulong_t;
    }
}
else
{
    alias c_long slong_t;
    alias c_ulong ulong_t;
}

//
// Required
//
/*
blkcnt_t
blksize_t
dev_t
gid_t
ino_t
mode_t
nlink_t
off_t
pid_t
size_t
ssize_t
time_t
uid_t
*/

version( CRuntime_Glibc )
{
  static if( __USE_FILE_OFFSET64 )
  {
    alias long      blkcnt_t;
    alias ulong     ino_t;
    alias long      off_t;
  }
  else
  {
    alias slong_t   blkcnt_t;
    alias ulong_t   ino_t;
    alias slong_t   off_t;
  }
    alias slong_t   blksize_t;
    alias ulong     dev_t;
    alias uint      gid_t;
    alias uint      mode_t;
    alias ulong_t   nlink_t;
    alias int       pid_t;
    //size_t (defined in core.stdc.stddef)
    alias c_long    ssize_t;
    alias slong_t   time_t;
    alias uint      uid_t;
}
else version( Darwin )
{
    alias long      blkcnt_t;
    alias int       blksize_t;
    alias int       dev_t;
    alias uint      gid_t;
    alias ulong     ino_t;
    alias ushort    mode_t;
    alias ushort    nlink_t;
    alias long      off_t;
    alias int       pid_t;
    //size_t (defined in core.stdc.stddef)
    alias c_long    ssize_t;
    alias c_long    time_t;
    alias uint      uid_t;
}
else version( FreeBSD )
{
    alias long      blkcnt_t;
    alias uint      blksize_t;
    alias uint      dev_t;
    alias uint      gid_t;
    alias uint      ino_t;
    alias ushort    mode_t;
    alias ushort    nlink_t;
    alias long      off_t;
    alias int       pid_t;
    //size_t (defined in core.stdc.stddef)
    alias c_long    ssize_t;
    alias c_long    time_t;
    alias uint      uid_t;
    alias uint      fflags_t;
}
else version(NetBSD)
{
    alias long      blkcnt_t;
    alias int       blksize_t;
    alias ulong     dev_t;
    alias uint      gid_t;
    alias ulong     ino_t;
    alias uint      mode_t;
    alias uint      nlink_t;
    alias ulong     off_t;
    alias int       pid_t;
    //size_t (defined in core.stdc.stddef)
    alias c_long      ssize_t;
    alias c_long      time_t;
    alias uint        uid_t;
}
else version (Solaris)
{
    alias char* caddr_t;
    alias c_long daddr_t;
    alias short cnt_t;

    static if (__USE_FILE_OFFSET64)
    {
        alias long blkcnt_t;
        alias ulong ino_t;
        alias long off_t;
    }
    else
    {
        alias c_long blkcnt_t;
        alias c_ulong ino_t;
        alias c_long off_t;
    }

    version (D_LP64)
    {
        alias blkcnt_t blkcnt64_t;
        alias ino_t ino64_t;
        alias off_t off64_t;
    }
    else
    {
        alias long blkcnt64_t;
        alias ulong ino64_t;
        alias long off64_t;
    }

    alias uint blksize_t;
    alias c_ulong dev_t;
    alias uid_t gid_t;
    alias uint mode_t;
    alias uint nlink_t;
    alias int pid_t;
    alias c_long ssize_t;
    alias c_long time_t;
    alias uint uid_t;
}
else version( CRuntime_Bionic )
{
    alias c_ulong   blkcnt_t;
    alias c_ulong   blksize_t;
    alias uint      dev_t;
    alias uint      gid_t;
    alias c_ulong   ino_t;
    alias c_long    off_t;
    alias int       pid_t;
    alias int       ssize_t;
    alias c_long    time_t;
    alias uint      uid_t;

    version(X86)
    {
        alias ushort    mode_t;
        alias ushort    nlink_t;
    }
    else version(ARM)
    {
        alias ushort    mode_t;
        alias ushort    nlink_t;
    }
    else version(MIPS32)
    {
        alias uint      mode_t;
        alias uint      nlink_t;
    }
    else
    {
        static assert(false, "Architecture not supported.");
    }
}
else
version( dscripten )
{
    alias int       pid_t;
    alias c_long    off_t;
    alias c_long    ssize_t;
    alias uint      uid_t;
    alias uint      gid_t;
}
else
{
    static assert(false, "Unsupported platform");
}

//
// XOpen (XSI)
//
/*
clock_t
fsblkcnt_t
fsfilcnt_t
id_t
key_t
suseconds_t
useconds_t
*/

version( CRuntime_Glibc )
{
  static if( __USE_FILE_OFFSET64 )
  {
    alias ulong     fsblkcnt_t;
    alias ulong     fsfilcnt_t;
  }
  else
  {
    alias ulong_t   fsblkcnt_t;
    alias ulong_t   fsfilcnt_t;
  }
    alias slong_t   clock_t;
    alias uint      id_t;
    alias int       key_t;
    alias slong_t   suseconds_t;
    alias uint      useconds_t;
}
else version( Darwin )
{
    alias uint   fsblkcnt_t;
    alias uint   fsfilcnt_t;
    alias c_long clock_t;
    alias uint   id_t;
    // key_t
    alias int    suseconds_t;
    alias uint   useconds_t;
}
else version( FreeBSD )
{
    alias ulong     fsblkcnt_t;
    alias ulong     fsfilcnt_t;
    alias c_long    clock_t;
    alias long      id_t;
    alias c_long    key_t;
    alias c_long    suseconds_t;
    alias uint      useconds_t;
}
else version(NetBSD)
{
    alias ulong     fsblkcnt_t;
    alias ulong     fsfilcnt_t;
    alias c_long    clock_t;
    alias long      id_t;
    alias c_long    key_t;
    alias c_long    suseconds_t;
    alias uint      useconds_t;
}
else version (Solaris)
{
    static if (__USE_FILE_OFFSET64)
    {
        alias ulong fsblkcnt_t;
        alias ulong fsfilcnt_t;
    }
    else
    {
        alias c_ulong fsblkcnt_t;
        alias c_ulong fsfilcnt_t;
    }

    alias c_long clock_t;
    alias int id_t;
    alias int key_t;
    alias c_long suseconds_t;
    alias uint useconds_t;

    alias id_t taskid_t;
    alias id_t projid_t;
    alias id_t poolid_t;
    alias id_t zoneid_t;
    alias id_t ctid_t;
}
else version( CRuntime_Bionic )
{
    alias c_ulong  fsblkcnt_t;
    alias c_ulong  fsfilcnt_t;
    alias c_long   clock_t;
    alias uint     id_t;
    alias int      key_t;
    alias c_long   suseconds_t;
    alias c_long   useconds_t;
}
else version( dscripten )
{
    // TODO
}
else
{
    static assert(false, "Unsupported platform");
}

//
// Thread (THR)
//
/*
pthread_attr_t
pthread_cond_t
pthread_condattr_t
pthread_key_t
pthread_mutex_t
pthread_mutexattr_t
pthread_once_t
pthread_rwlock_t
pthread_rwlockattr_t
pthread_t
*/

version (CRuntime_Glibc)
{
    version (X86)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 36;
        enum __SIZEOF_PTHREAD_MUTEX_T = 24;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 32;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 20;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else version (X86_64)
    {
        static if (__WORDSIZE == 64)
        {
            enum __SIZEOF_PTHREAD_ATTR_T = 56;
            enum __SIZEOF_PTHREAD_MUTEX_T = 40;
            enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
            enum __SIZEOF_PTHREAD_COND_T = 48;
            enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
            enum __SIZEOF_PTHREAD_RWLOCK_T = 56;
            enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
            enum __SIZEOF_PTHREAD_BARRIER_T = 32;
            enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
        }
        else
        {
            enum __SIZEOF_PTHREAD_ATTR_T = 32;
            enum __SIZEOF_PTHREAD_MUTEX_T = 32;
            enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
            enum __SIZEOF_PTHREAD_COND_T = 48;
            enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
            enum __SIZEOF_PTHREAD_RWLOCK_T = 44;
            enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
            enum __SIZEOF_PTHREAD_BARRIER_T = 20;
            enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
        }
    }
    else version (AArch64)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 64;
        enum __SIZEOF_PTHREAD_MUTEX_T = 48;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 8;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 8;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 56;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 32;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 8;
    }
    else version (ARM)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 36;
        enum __SIZEOF_PTHREAD_MUTEX_T = 24;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 32;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 20;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else version (IA64)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 56;
        enum __SIZEOF_PTHREAD_MUTEX_T = 40;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 56;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 32;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else version (MIPS32)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 36;
        enum __SIZEOF_PTHREAD_MUTEX_T = 24;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 32;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 20;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else version (MIPS64)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 56;
        enum __SIZEOF_PTHREAD_MUTEX_T = 40;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 56;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 32;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else version (PPC)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 36;
        enum __SIZEOF_PTHREAD_MUTEX_T = 24;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 32;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 20;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else version (PPC64)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 56;
        enum __SIZEOF_PTHREAD_MUTEX_T = 40;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 56;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 32;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else version (RISCV32)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 36;
        enum __SIZEOF_PTHREAD_MUTEX_T = 24;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 32;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 20;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else version (RISCV64)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 56;
        enum __SIZEOF_PTHREAD_MUTEX_T = 40;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 56;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 32;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else version (SPARC64)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 56;
        enum __SIZEOF_PTHREAD_MUTEX_T = 40;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 56;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 32;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else version (S390)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 36;
        enum __SIZEOF_PTHREAD_MUTEX_T = 24;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 32;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 20;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else version (SystemZ)
    {
        enum __SIZEOF_PTHREAD_ATTR_T = 56;
        enum __SIZEOF_PTHREAD_MUTEX_T = 40;
        enum __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
        enum __SIZEOF_PTHREAD_COND_T = 48;
        enum __SIZEOF_PTHREAD_CONDATTR_T = 4;
        enum __SIZEOF_PTHREAD_RWLOCK_T = 56;
        enum __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
        enum __SIZEOF_PTHREAD_BARRIER_T = 32;
        enum __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    }
    else
    {
        static assert (false, "Unsupported platform");
    }

    union pthread_attr_t
    {
        byte[__SIZEOF_PTHREAD_ATTR_T] __size;
        c_long __align;
    }

    private alias int __atomic_lock_t;

    private struct _pthread_fastlock
    {
        c_long          __status;
        __atomic_lock_t __spinlock;
    }

    private alias void* _pthread_descr;

    union pthread_cond_t
    {
        byte[__SIZEOF_PTHREAD_COND_T] __size;
        long  __align;
    }

    union pthread_condattr_t
    {
        byte[__SIZEOF_PTHREAD_CONDATTR_T] __size;
        int __align;
    }

    alias uint pthread_key_t;

    union pthread_mutex_t
    {
        byte[__SIZEOF_PTHREAD_MUTEX_T] __size;
        c_long __align;
    }

    union pthread_mutexattr_t
    {
        byte[__SIZEOF_PTHREAD_MUTEXATTR_T] __size;
        int __align;
    }

    alias int pthread_once_t;

    struct pthread_rwlock_t
    {
        byte[__SIZEOF_PTHREAD_RWLOCK_T] __size;
        c_long __align;
    }

    struct pthread_rwlockattr_t
    {
        byte[__SIZEOF_PTHREAD_RWLOCKATTR_T] __size;
        c_long __align;
    }

    alias c_ulong pthread_t;
}
else version( Darwin )
{
    version( D_LP64 )
    {
        enum __PTHREAD_SIZE__               = 1168;
        enum __PTHREAD_ATTR_SIZE__          = 56;
        enum __PTHREAD_MUTEXATTR_SIZE__     = 8;
        enum __PTHREAD_MUTEX_SIZE__         = 56;
        enum __PTHREAD_CONDATTR_SIZE__      = 8;
        enum __PTHREAD_COND_SIZE__          = 40;
        enum __PTHREAD_ONCE_SIZE__          = 8;
        enum __PTHREAD_RWLOCK_SIZE__        = 192;
        enum __PTHREAD_RWLOCKATTR_SIZE__    = 16;
    }
    else
    {
        enum __PTHREAD_SIZE__               = 596;
        enum __PTHREAD_ATTR_SIZE__          = 36;
        enum __PTHREAD_MUTEXATTR_SIZE__     = 8;
        enum __PTHREAD_MUTEX_SIZE__         = 40;
        enum __PTHREAD_CONDATTR_SIZE__      = 4;
        enum __PTHREAD_COND_SIZE__          = 24;
        enum __PTHREAD_ONCE_SIZE__          = 4;
        enum __PTHREAD_RWLOCK_SIZE__        = 124;
        enum __PTHREAD_RWLOCKATTR_SIZE__    = 12;
    }

    struct pthread_handler_rec
    {
      void function(void*)  __routine;
      void*                 __arg;
      pthread_handler_rec*  __next;
    }

    struct pthread_attr_t
    {
        c_long                              __sig;
        byte[__PTHREAD_ATTR_SIZE__]         __opaque;
    }

    struct pthread_cond_t
    {
        c_long                              __sig;
        byte[__PTHREAD_COND_SIZE__]         __opaque;
    }

    struct pthread_condattr_t
    {
        c_long                              __sig;
        byte[__PTHREAD_CONDATTR_SIZE__]     __opaque;
    }

    alias c_ulong pthread_key_t;

    struct pthread_mutex_t
    {
        c_long                              __sig;
        byte[__PTHREAD_MUTEX_SIZE__]        __opaque;
    }

    struct pthread_mutexattr_t
    {
        c_long                              __sig;
        byte[__PTHREAD_MUTEXATTR_SIZE__]    __opaque;
    }

    struct pthread_once_t
    {
        c_long                              __sig;
        byte[__PTHREAD_ONCE_SIZE__]         __opaque;
    }

    struct pthread_rwlock_t
    {
        c_long                              __sig;
        byte[__PTHREAD_RWLOCK_SIZE__]       __opaque;
    }

    struct pthread_rwlockattr_t
    {
        c_long                              __sig;
        byte[__PTHREAD_RWLOCKATTR_SIZE__]   __opaque;
    }

    private struct _opaque_pthread_t
    {
        c_long                  __sig;
        pthread_handler_rec*    __cleanup_stack;
        byte[__PTHREAD_SIZE__]  __opaque;
    }

    alias _opaque_pthread_t* pthread_t;
}
else version( FreeBSD )
{
    alias int lwpid_t;

    alias void* pthread_attr_t;
    alias void* pthread_cond_t;
    alias void* pthread_condattr_t;
    alias void* pthread_key_t;
    alias void* pthread_mutex_t;
    alias void* pthread_mutexattr_t;
    alias void* pthread_once_t;
    alias void* pthread_rwlock_t;
    alias void* pthread_rwlockattr_t;
    alias void* pthread_t;
}
else version(NetBSD)
{
   struct pthread_queue_t {
         void*  ptqh_first;
         void** ptqh_last;
   }

    alias lwpid_t = int;
    alias pthread_spin_t = ubyte;
    struct pthread_attr_t {
        uint    pta_magic;
        int     pta_flags;
        void*   pta_private;
    }
    struct  pthread_spinlock_t {
        uint    pts_magic;
        pthread_spin_t  pts_spin;
        int             pts_flags;
    }
    struct pthread_cond_t {
        uint    ptc_magic;
        pthread_spin_t  ptc_lock;
        pthread_queue_t ptc_waiters;
        pthread_mutex_t *ptc_mutex;
        void*   ptc_private;
    }
    struct pthread_condattr_t {
        uint    ptca_magic;
        void    *ptca_private;
    }
    struct pthread_mutex_t {
        uint ptm_magic;
        pthread_spin_t  ptm_errorcheck;
        ubyte[3]         ptm_pad1;
        pthread_spin_t  ptm_interlock;
        ubyte[3] ptm_pad2;
        pthread_t ptm_owner;
        void* ptm_waiters;
        uint  ptm_recursed;
        void* ptm_spare2;
    }
    struct pthread_mutexattr_t{
        uint    ptma_magic;
        void*   ptma_private;
    }
    struct pthread_once_t{
        pthread_mutex_t pto_mutex;
        int     pto_done;
    }
    struct pthread_rwlock_t{
        uint    ptr_magic;

        pthread_spin_t  ptr_interlock;

        pthread_queue_t ptr_rblocked;
        pthread_queue_t ptr_wblocked;
        uint    ptr_nreaders;
        pthread_t ptr_owner;
        void    *ptr_private;
    }
    struct pthread_rwlockattr_t{
        uint    ptra_magic;
        void*   ptra_private;
    }

    alias uint pthread_key_t;
    alias void* pthread_t;
}
else version (Solaris)
{
    alias uint pthread_t;

    struct pthread_attr_t
    {
        void* __pthread_attrp;
    }

    struct pthread_cond_t
    {
        struct ___pthread_cond_flags
        {
            ubyte[4] __pthread_cond_flags;
            ushort __pthread_cond_type;
            ushort __pthread_cond_magic;
        }

        ___pthread_cond_flags __pthread_cond_flags;
        ulong __pthread_cond_data;
    }

    struct pthread_condattr_t
    {
        void* __pthread_condattrp;
    }

    struct pthread_rwlock_t
    {
        int __pthread_rwlock_readers;
        ushort __pthread_rwlock_type;
        ushort __pthread_rwlock_magic;
        pthread_mutex_t __pthread_rwlock_mutex;
        pthread_cond_t __pthread_rwlock_readercv;
        pthread_cond_t __pthread_rwlock_writercv;
    }

    struct pthread_rwlockattr_t
    {
        void* __pthread_rwlockattrp;
    }

    struct pthread_mutex_t
    {
        struct ___pthread_mutex_flags
        {
            ushort __pthread_mutex_flag1;
            ubyte __pthread_mutex_flag2;
            ubyte __pthread_mutex_ceiling;
            ushort __pthread_mutex_type;
            ushort __pthread_mutex_magic;
        }

        ___pthread_mutex_flags __pthread_mutex_flags;

        union ___pthread_mutex_lock
        {
            struct ___pthread_mutex_lock64
            {
                ubyte[8] __pthread_mutex_pad;
            }

            ___pthread_mutex_lock64 __pthread_mutex_lock64;

            struct ___pthread_mutex_lock32
            {
                uint __pthread_ownerpid;
                uint __pthread_lockword;
            }

            ___pthread_mutex_lock32 __pthread_mutex_lock32;
            ulong __pthread_mutex_owner64;
        }

        ___pthread_mutex_lock __pthread_mutex_lock;
        ulong __pthread_mutex_data;
    }

    struct pthread_mutexattr_t
    {
        void* __pthread_mutexattrp;
    }

    struct pthread_once_t
    {
        ulong[4] __pthread_once_pad;
    }

    alias uint pthread_key_t;
}
else version( CRuntime_Bionic )
{
    struct pthread_attr_t
    {
        uint    flags;
        void*   stack_base;
        size_t  stack_size;
        size_t  guard_size;
        int     sched_policy;
        int     sched_priority;
    }

    struct pthread_cond_t
    {
        int value; //volatile
    }

    alias c_long pthread_condattr_t;
    alias int    pthread_key_t;

    struct pthread_mutex_t
    {
        int value; //volatile
    }

    alias c_long pthread_mutexattr_t;
    alias int    pthread_once_t; //volatile

    struct pthread_rwlock_t
    {
        pthread_mutex_t  lock;
        pthread_cond_t   cond;
        int              numLocks;
        int              writerThreadId;
        int              pendingReaders;
        int              pendingWriters;
        void*[4]         reserved;
    }

    alias int    pthread_rwlockattr_t;
    alias c_long pthread_t;
}
else version( dscripten )
{
}
else
{
    static assert(false, "Unsupported platform");
}

//
// Barrier (BAR)
//
/*
pthread_barrier_t
pthread_barrierattr_t
*/

version( CRuntime_Glibc )
{
    struct pthread_barrier_t
    {
        byte[__SIZEOF_PTHREAD_BARRIER_T] __size;
        c_long __align;
    }

    struct pthread_barrierattr_t
    {
        byte[__SIZEOF_PTHREAD_BARRIERATTR_T] __size;
        int __align;
    }
}
else version( FreeBSD )
{
    alias void* pthread_barrier_t;
    alias void* pthread_barrierattr_t;
}
else version(NetBSD)
{
    alias void* pthread_barrier_t;
    alias void* pthread_barrierattr_t;
}
else version( Darwin )
{
}
else version (Solaris)
{
    struct pthread_barrier_t
    {
        uint __pthread_barrier_count;
        uint __pthread_barrier_current;
        ulong __pthread_barrier_cycle;
        ulong __pthread_barrier_reserved;
        pthread_mutex_t __pthread_barrier_lock;
        pthread_cond_t __pthread_barrier_cond;
    }

    struct pthread_barrierattr_t
    {
        void* __pthread_barrierattrp;
    }
}
else version( CRuntime_Bionic )
{
}
else version( dscripten ) 
{
}
else
{
    static assert(false, "Unsupported platform");
}

//
// Spin (SPN)
//
/*
pthread_spinlock_t
*/

version( CRuntime_Glibc )
{
    alias int pthread_spinlock_t; // volatile
}
else version( FreeBSD )
{
    alias void* pthread_spinlock_t;
}
else version(NetBSD)
{
    //already defined
}
else version (Solaris)
{
    alias pthread_mutex_t pthread_spinlock_t;
}

//
// Timer (TMR)
//
/*
clockid_t
timer_t
*/

//
// Trace (TRC)
//
/*
trace_attr_t
trace_event_id_t
trace_event_set_t
trace_id_t
*/
