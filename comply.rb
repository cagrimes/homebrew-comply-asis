class Comply < Formula
  desc "Compliance automation framework, focused on SOC2"
  homepage "https://comply.strongdm.com"
  url "https://github.com/strongdm/comply/archive/v1.4.1.tar.gz"
  sha256 "23820f4f6f6a040551e7b472e4fcf394bfc4bdba2d2beb726536c1d6fde251f5"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV.prepend_create_path "PATH", buildpath/"bin"
    (buildpath/"src/github.com/strongdm/comply").install buildpath.children
    cd "src/github.com/strongdm/comply" do
      system "make", "brew"
      bin.install "bin/comply"
    end
  end

  test do
    (testpath/"init_comply.sh").write <<~EOS
      #!/usr/bin/expect -f
      set timeout 2
      spawn #{bin}/comply init
      send -- "Hello Corporation\r"
      expect "*Filename Prefix*"
      send -- "\r\r\r"
      expect "*GitHub*"
      send -- "\r"
      expect "*Configure github now*"
      send -- "\r\r"
      expect "+:+"
      send -- "thing\r"
      expect "+:+"
      send -- "thing\r"
      expect "+:+"
      send -- "thing\r"
      expect "+:+"
      send -- "thing\r"
      expect "*Next steps*"
      expect eof
    EOS

    chmod 0755, testpath/"init_comply.sh"
    mkdir testpath/"rundir"

    system "cd rundir && ../init_comply.sh"
    assert_predicate testpath/"rundir/narratives", :exist?
    assert_predicate testpath/"rundir/policies", :exist?
    assert_predicate testpath/"rundir/procedures", :exist?
    assert_predicate testpath/"rundir/standards", :exist?
    assert_predicate testpath/"rundir/templates", :exist?
  end
end
