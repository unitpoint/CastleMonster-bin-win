resLevels = Resources()
resLevels.loadXML("xmls/levels.xml", false)

var getResAnim, prevRes = resLevels.getResAnim, null
function resLevels.getResAnim(name){
	var res = getResAnim.call(this, name)
	res === prevRes && return res
	prevRes.unload()
	prevRes = res
	// print "begin load res: "..name
	res.load()
	// print "end load res: "..name
	return res
}
