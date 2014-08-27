require "formula"

class Libstrophe < Formula
  homepage "http://strophe.im/libstrophe/"
  url "https://github.com/strophe/libstrophe/archive/0.8.6.tar.gz"
  sha1 "fc30c78945cb075a636cff8c76be671c8a364eb0"
  head "https://github.com/strophe/libstrophe.git"
  revision 1

  bottle do
    cellar :any
    sha1 "77d6711507a185eb546160ed8249f5037cee0419" => :mavericks
    sha1 "1720a1d673d178ab70eeca0a6516b8a60a77e8c1" => :mountain_lion
    sha1 "fcc5859e1551887cd4361488208090496539978c" => :lion
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "libtool" => :build
  depends_on "openssl"
  depends_on "check"

  def install
    # see https://github.com/strophe/libstrophe/issues/28
    ENV.deparallelize

    system "./bootstrap.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/'test.c').write <<-EOS.undent
      #include <strophe.h>
      #include <assert.h>

      int main(void) {
        xmpp_ctx_t *ctx;
        xmpp_log_t *log;

        xmpp_initialize();
        log = xmpp_get_default_logger(XMPP_LEVEL_DEBUG);
        assert(log);

        ctx = xmpp_ctx_new(NULL, log);
        assert(ctx);

        xmpp_ctx_free(ctx);
        xmpp_shutdown();
        return 0;
      }
      EOS
    flags = ["-I#{include}/", "-lstrophe"]
    system ENV.cc, "-o", "test", "test.c", *(flags + ENV.cflags.to_s.split)
    system "./test"
  end
end