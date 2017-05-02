from js9 import j

path = "/opt/code/github/jumpscale"

for item in j.sal.fs.listFilesInDir(path, True):
    if "cuisine" in item.lower():
        newname = item.replace("cuisine", "prefab")
        newname = item.replace("Prefab", "Prefab")
        j.sal.fs.renameFile(item, newname)
        # print("rename %s %s" % (item, newname))

from IPython import embed
print("DEBUG NOW jjj")
embed()
raise RuntimeError("stop debug here")
