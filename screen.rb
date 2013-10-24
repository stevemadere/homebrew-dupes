require 'formula'

class Screen < Formula
  homepage 'http://www.gnu.org/software/screen'
  url 'http://ftpmirror.gnu.org/screen/screen-4.0.3.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/screen/screen-4.0.3.tar.gz'
  version '4.00.03'
  sha1 '7bc6e2f0959ffaae6f52d698c26c774e7dec3545'

  head 'git://git.savannah.gnu.org/screen.git', :branch => 'master'

  depends_on :autoconf

  def patches
    { :p1 => base_patch,
      # Fix bug in multiuser mode attach that results in msg: "Attach attempt with invalid pid"
      :p2 => DATA
    }
  end

  def base_patch
    if build.head?
      # This patch is to disable the error message
      # "/var/run/utmp: No such file or directory" on launch
      "https://gist.github.com/raw/4608863/75669072f227b82777df25f99ffd9657bd113847/gistfile1.diff"
    else
      "http://trac.macports.org/raw-attachment/ticket/20862/screen-4.0.3-snowleopard.patch"
    end
  end

  def install
    if build.head?
      Dir.chdir 'src'
      system "autoconf"
      system "autoheader"

      # With parallel build, it fails
      # because of trying to compile files which depend osdef.h
      # before osdef.sh script generates it.
      ENV.deparallelize
    end

    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--infodir=#{info}",
                          "--enable-colors256"
    system "make"
    system "make install"
  end
end
__END__
diff --git a/src/socket.c b/src/socket.c
index a7755a4..3742c5a 100644
--- a/src/socket.c
+++ b/src/socket.c
@@ -777,7 +777,7 @@ int pid;
   if (eff_uid == real_uid)
     return kill(pid, 0);
   if (UserContext() > 0)
-    UserReturn(kill(pid, 0));
+    return 0;
   return UserStatus();
 }

