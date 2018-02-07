# /network.nix
{
  defaults = {
    networking.firewall.enable = false;
    services.openssh.enable = true;

    imports = [ ./roles.nix ];
  };
} // (
  let
    root = ./terraform;

    absRoot = builtins.toString root;

    filesAndType = builtins.readDir root;

    # Find all the names of the directories inside of the root
    dirs = builtins.filter
      (key: filesAndType."${key}" == "directory")
      (builtins.attrNames filesAndType);

    nodes = builtins.filter
      (dirName: dirName != ".cache")
      dirs;

    importNode = name: builtins.toPath "${absRoot}/${name}";

    # From a list of nodes: [ "node1" "node2" ]
    # import them all in to a dictionary, as:
    # { node1 = import ./root/node1; node2 = import ./root/node2; }
    allImported = builtins.foldl'
      (collector: node: collector // { "${node}" = importNode node; })
      {}
      nodes;
  in allImported)
