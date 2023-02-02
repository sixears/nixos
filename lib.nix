# ------------------------------------------------------------------------------

{ nixpkgs ? import <nixpkgs> {} }:

rec {
  /* :: Map String String -> Map String [String]
   *
   * Invert, say,
   *     {a = "x"; b = "x"; c = "y"; d = "x"; e = "z"; f = "y";}
   * to result in
   *     { x = [ "d" "b" "a" ]; y = [ "f" "c" ]; z = [ "e" ]; }
   *
   * Note that all values in the input set must be strings.
   */

  invertSet = input:
    let inherit (builtins)          attrNames getAttr hasAttr;
        inherit (nixpkgs.lib.lists) foldr;
        go = key: acc:
          let value = getAttr key input;
           in acc // { ${value} =
                         [key] ++ (if hasAttr value acc
                                   then getAttr value acc
                                   else []);
                     };
    in foldr go {} (attrNames input);

  # ------------------------------------

  /* :: Path -> Map String [Path]
   *
   * Akin to builtins.readdir, but inverts the set resulting in a set with keys
   * 'regular' (plain files), 'directory', etc.; and each value is a list of
   * files, where each file is a path (implicitly resolved to be absolute)
   * rather than a string.
   */

  readDir = path:
    builtins.mapAttrs (_: ps: map (p: path+("/"+p)) ps)
                      (invertSet (builtins.readDir path));

  # ------------------------------------

  /* :: Path -> Map String [Path] # keys 'regular', 'directory'
   *
   * Read all files in path; return a set with keys 'regular' (plain files that
   * are called '*.nix') and 'directory' (directories that contain a
   * default.nix).
   */

  readNixes = path:
    let inherit (builtins) filter match pathExists;
        content = readDir path;
     in { regular   = filter (n: match ".*\\.nix" (toString n) != null)
                             content.regular or [];
          directory = filter (n: pathExists (n+"/default.nix"))
                             content.directory or [];
        };

  # ------------------------------------

  /* :: Path -> [Path]
   *
   * A list of all *.nix files, and dirs with a default.nix, in a given dir (as
   * paths).
   */

  allNixes = path:
    let nixes = readNixes path;
     in nixes.directory ++ nixes.regular;

  # ------------------------------------

  /* :: Path -> any -> [*]
   *
   * Import all *.nix files, and dirs with a default.nix, in a given dir.
   * `args` is provided as an import argument to all imports.
   */

  importNixes = path: args: map (n: import n args) (allNixes path);

  # ------------------------------------

  /* :: Path -> [*]
   *
   * Import all *.nix files, and dirs with a default.nix, in a given dir.
   */

  importNixesNoArgs = path: map (n: import n) (allNixes path);

  # ------------------------------------

  /* :: String -> [x] -> x
   *
   * Given a list of length 1; return the single element.  Otherwise, abort with
   * the given error message.
   */
  select1 = err: xs:
    if 1 == (builtins.length xs) then builtins.head xs else abort err;

  # ------------------------------------

  /* [Map String *] -> Map String *
   *
   * Build a set by merging multiple sets, throwing an exception if any two sets
   * share a key.
   */
  mergeDisjointSets = input:
    let
      err   = name: "multiple values for ${name}";
      merge = name: values: select1 (err name) values;
      # List of likely-looking derivations in the input.
      dervs = builtins.filter nixpkgs.lib.attrsets.isDerivation input;
    in
      if 0 != builtins.length(dervs)
      then let
             one_derv = builtins.head dervs;
             e_msg    = "merge received a likely derivation, name: "
                      + "${one_derv.name}";
            in
             builtins.throw e_msg
      else nixpkgs.lib.attrsets.zipAttrsWith merge input;
}
