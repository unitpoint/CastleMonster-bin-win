levelRes = Resources()
levelRes.loadXML("xmls/levels.xml", false)

var get, prevRes = levelRes.get, null
function levelRes.get(name){
	var res = get.call(this, name)
	res === prevRes && return res
	prevRes.unload()
	prevRes = res
	// print "begin load res: "..name
	res.load()
	// print "end load res: "..name
	return res
}
