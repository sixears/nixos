{ pkgs ? import <nixpkgs> {} }:

with pkgs;
with perlPackages;
let Getopt-Plus = import ../Getopt-Plus { inherit pkgs Log-Info; };
    Log-Info    = import ../Log-Info    { inherit pkgs; };
in buildPerlModule rec {
  version = "1.01";
  pname = "Finance";

  src = fetchurl {
    url = "http://localhost:8888/${pname}-${version}-002.tar.gz";
    sha256 = "0fib0rbzx8519imsw9jrfl805r6lrl6qzbnhipxxix5scar913r7";
  };

  patches = [ ./test-pm-tempdir.patch ];
  buildInputs = [ ClassMethodMaker Getopt-Plus IPCRun Log-Info PodParser ];
  propagatedBuildInputs = [ ];

  doCheck = false;
}
