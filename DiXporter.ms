try(destroyDialog DiXporter)catch()
try(destroyDialog locationsRollout)catch()

rootFolder = (getDir #userScripts) + "/GenTools"
preferencesIni = rootFolder + "/GenToolsPreferences.ini" 
locationlistini = rootFolder + "/compartmentlist.ini"
locationlistarray = getIniSetting locationlistini
exportlabel = "Export_To" 
unityRot = eulerToQuat(eulerAngles 90 0 180) -- it used to be 90 0 180 

-- Starting Precautions
fn StartingPrecautions =
(
	if doesFileExist rootFolder == false do
	(
		print "making director at - " + rootFolder
		makeDir rootFolder
	)
	if doesFileExist preferencesIni != true then
	(
		messageBox "Can't find Ini, Creating it now"
	)
	else
	(
		print "Found ini"
	)
	if getIniSetting preferencesIni "Export" "SceneNameAs" == "" do
	(
		setIniSetting preferencesIni "Export" "SceneNameAs" "1"
	) 
	if getIniSetting preferencesIni "Export" "LayerNameAs" == "" do
	(
		setIniSetting preferencesIni "Export" "LayerNameAs" "1"
	) 
	if getIniSetting preferencesIni "Export" "CustomAs" == "" do
	(
		setIniSetting preferencesIni "Export" "CustomAs" "1"
	) 
	if getIniSetting preferencesIni "Export" "ExportHidden" == "" do
	(
		 setIniSetting preferencesIni "Export" "ExportHidden" "false"
	)
	if (getIniSetting preferencesIni "Export" "FlipForUnity" ) == "" do
	(
		setIniSetting preferencesIni "Export" "FlipForUnity" "false"
	)
)
	
fn ReloadLists =
(
	locationlistarray = getIniSetting locationlistini
	pathArray = for i in 1 to locationlistarray.count collect
	(
		getIniSetting locationlistini locationlistarray[i] exportlabel
	)
	try(
		locationsRollout.locationbox.items = locationlistarray
		locationsRollout.pathbox.items = pathArray
	)catch()
	try(
		DiXporter.locationbox.items = locationlistarray
	)catch()
)

fn CheckOptionStates =
(
	locationsRollout.sceneradio.state = (getIniSetting preferencesIni "Export" "SceneNameAs" as integer)
	locationsRollout.layerradio.state = (getIniSetting preferencesIni "Export" "LayerNameAs" as integer)
	locationsRollout.customradio.state = (getIniSetting preferencesIni "Export" "CustomAs" as integer)
	locationsRollout.customtext.text = (getIniSetting preferencesIni "Export" "CustomString" as string)
	locationsRollout.hiddencheck.state = (getIniSetting preferencesIni "Export" "ExportHidden" as booleanClass)
	locationsRollout.flipcheck.state = (getIniSetting preferencesIni "Export" "FlipForUnity" as booleanClass)
)

fn Flip =
(
	rot = eulerToQuat(eulerAngles 90 0 180)
	x = XForm()
	for i = 1 to DiXporter.layerArray.count do 
	(
		layer = DiXporter.allLayerNames[DiXporter.layerArray[i]]
		(LayerManager.getLayerFromName(layer)).nodes &theNodes
		select theNodes
		for o in theNodes do
		(
			addModifier o x
		)
	)
	x.gizmo.rotation += rot as quat
)

fn UnFlip =
(
	for i = 1 to DiXporter.layerArray.count do 
	(
		layer = DiXporter.allLayerNames[DiXporter.layerArray[i]]
		(LayerManager.getLayerFromName(layer)).nodes &theNodes
		select theNodes
		for o in theNodes do
		(
			deleteModifier o o.modifiers[XForm]
		)
	)
)

fn NewLocation location newpath =
(
	print location
	print newpath
	if location != "" and newpath != "" then
		setIniSetting locationlistini location exportlabel newpath
	else
		messagebox "Please fill in both boxes"
)
	
rollout locationsRollout "Locations" width:888 height:448
(
	local pathArray
	listbox locationbox "Name" pos:[8,8] width:200 height:22 selection:0 
	listbox pathbox "Path" pos:[216,8] width:664 height:22 enabled:true selection:0 readOnly:true
	button delbtn "Delete" pos:[824,408] width:22 height:20 images:#("Trash_Icon.bmp", "undefined", 2, 1, 2, 1, 1) toolTip:"Delete Selected entry"
	button reloadbtn "Reload" pos:[856,408] width:22 height:20 images:#("Reload_Icon.bmp", "undefined", 2, 1, 2, 1, 1) toolTip:"Reload lists"
	label lbl1 "Edit existing -" pos:[12,328] width:80 height:16
	label lbl2 "New location -" pos:[12,368] width:80 height:16
	edittext editlocationbox "" pos:[8,344] width:200 height:16 selection:0 readOnly:true
	edittext editpathbox "" pos:[216,344] width:536 height:16 selection:0  
	edittext newlocationbox "" pos:[8,384] width:200 height:16 selection:0
	edittext newpathbox "" pos:[216,384] width:536 height:16 selection:0 
	button editbtn "Change" pos:[816,344] width:64 height:16
	button createbtn "Create" pos:[816,384] width:64 height:16
	radiobuttons sceneradio "Scene name as -" pos:[12,408] width:170 height:30 labels:#("none", "prefix", "sufix") columns:3 toolTip:"Add the scene name on a layer or per mesh export"
	radiobuttons layerradio "Layer name as -" pos:[192,408] width:170 height:30 labels:#("none", "prefix", "sufix") columns:3 toolTip:"Add the layer name on a per mesh export"
	radiobuttons customradio "Custom name as -" pos:[376,408] width:173 height:30 labels:#("none", "prefix", "sufix") columns:3 toolTip:"Replace the scene name or layer name with a custom string"
	checkbox hiddencheck "Export Hidden" pos:[560,425] width:104 height:16 toolTip:"Include the hidden meshes in the export"
	edittext customtext "Custom label" pos:[560,408] width:256 height:16
	button editpathbtn ". . ." pos:[760,344] width:48 height:16
	button newpathbtn ". . ." pos:[760,384] width:48 height:16
	checkbox flipcheck "Filp for Unity" pos:[680,425] width:104 height:16 toolTip:"When exporting in mesh mode adds the correct rotation for Unity, and make Y Up"
	on locationsRollout open do
	(
		sceneradio.state = (getIniSetting preferencesIni "Export" "SceneNameAs" as integer)
		layerradio.state = (getIniSetting preferencesIni "Export" "LayerNameAs" as integer)
		customradio.state = (getIniSetting preferencesIni "Export" "CustomAs" as integer)
		customtext.text = (getIniSetting preferencesIni "Export" "CustomString" as string)
		hiddencheck.state = (getIniSetting preferencesIni "Export" "ExportHidden" as booleanClass)
		flipcheck.state = (getIniSetting preferencesIni "Export" "FlipForUnity" as booleanClass)
			
		locationlistarray = getIniSetting locationlistini
		pathArray = for i in 1 to locationlistarray.count collect
		(
			getIniSetting locationlistini locationlistarray[i] exportlabel
		)

		locationbox.items = locationlistarray
		pathbox.items = pathArray
	)
	on locationbox selected sel do
	(
		editlocationbox.text = locationbox.items[sel]
		editpathbox.text = pathbox.items[sel]
	)
	on delbtn pressed do
	(
		if queryBox "Do you really want to delete selected?" do
		(
			delIniSetting locationlistini locationbox.items[locationbox.selection]
			ReloadLists()
		)
	)
	on reloadbtn pressed do
	(
		ReloadLists()
	)
	on editpathbox entered text do
	(
		if queryBox "Change the path of selected?" do
		(
			setIniSetting locationlistini locationbox.items[locationbox.selection] exportlabel editpathbox.text
			ReloadLists()
		)
	)
	on newlocationbox entered text do
	(
		--NewLocation newlocationbox.text newpathbox.text
		--ReloadLists()
	)
	on newpathbox entered text do
	(
		--NewLocation newlocationbox.text newpathbox.text
		--ReloadLists()
	)
	on editbtn pressed do
	(
		if queryBox "Change the path of selected?" do
		(
			setIniSetting locationlistini locationbox.items[locationbox.selection] exportlabel editpathbox.text
			ReloadLists()
		)
	)
	on createbtn pressed do
	(
		NewLocation newlocationbox.text newpathbox.text
		ReloadLists()
	)
	on sceneradio changed stat do
	(
		setIniSetting preferencesIni "Export" "SceneNameAs" (stat as string)
	)
	on layerradio changed stat do
	(
		setIniSetting preferencesIni "Export" "LayerNameAs" (stat as string)
	)
	on customradio changed stat do
	(	
		setIniSetting preferencesIni "Export" "CustomAs" (stat as string)
	)
	on hiddencheck changed state do
	(
		setIniSetting preferencesIni "Export" "ExportHidden" (state as string)
	)
	on customtext entered text do
	(
		setIniSetting preferencesIni "Export" "CustomString" (text as string)
	)
	on editpathbtn pressed do
	(
		editpathbox.text = getsavepath()
	)
	on newpathbtn pressed do
	(
		newpathbox.text = getsavepath()
	)
	on flipcheck changed state do
	(
		setIniSetting preferencesIni "Export" "FlipForUnity" (state as string)
	)
)

fn ExportWholeFile =
(
	max select none 
	local exportlocation = getIniSetting locationlistini DiXporter.selectedLocation exportlabel
	exportTo = exportlocation + "\\" + (trimRight maxFileName ".max")
	for i = 1 to DiXporter.layerArray.count do 
	(
		layer = DiXporter.allLayerNames[DiXporter.layerArray[i]]
		(LayerManager.getLayerFromName(layer)).nodes &theNodes
		if (getIniSetting preferencesIni "Export" "ExportHidden" as booleanClass) == false then
		(
			theNodes = for o in theNodes where o.isHidden == false collect o
		)
		selectmore theNodes
	)	
	exportFile exportTo  selectedOnly:true #noPrompt
)
	
fn ExportLayers =
(
	local exportlocation = getIniSetting locationlistini (DiXporter.locationbox.selection as string) exportlabel
	for i = 1 to DiXporter.layerArray.count do 
	(
		layer = DiXporter.allLayerNames[DiXporter.layerArray[i]]
		/*
				for i = 1 to layerArray.count do 
				(
					print allLayerNames[layerArray[i]]
					ExportThis allLayerNames[layerArray[i]] exportlocation
				)
		*/
		sceneNameState = (getIniSetting preferencesIni "Export" "SceneNameAs" as integer)
		if sceneNameState == 1 do
		(
			exportTo = exportlocation + "\\" + layer
		)
		if sceneNameState == 2 do
		(
			exportTo = exportlocation + "\\" + trimright maxFileName ".max" + "_" + layer
		)
		if sceneNameState == 3 do
		(
			exportTo = exportlocation + "\\" + layer + "_" + trimright maxFileName ".max" 
		)
		
		(LayerManager.getLayerFromName(layer)).nodes &theNodes
		if (getIniSetting preferencesIni "Export" "ExportHidden" as booleanClass) == false then
		(
			theNodes = for o in theNodes where o.isHidden == false collect o
		)
		select theNodes
		if theNodes.count != 0 then
		(
			exportFile exportTo  selectedOnly:true #noPrompt
		)
		else
		(
			messagebox "a layer had no meshes in it"
		)
	)
)


/*
fn alignMyPivot sourceNode targetNode =
(
sourceNode.objectOffsetRot = targetNode.rotation
rotate sourceNode targetNode.rotation
sourceNode.pivot = targetNode.position
)
*/

fn ExportSingleNodes =
(
	local exportlocation = getIniSetting locationlistini DiXporter.selectedLocation exportlabel
	local marker = "^"
	for i = 1 to DiXporter.layerArray.count do 
	(
		layer = DiXporter.allLayerNames[DiXporter.layerArray[i]]
		(LayerManager.getLayerFromName(layer)).nodes &theNodes
		if (getIniSetting preferencesIni "Export" "ExportHidden" as booleanClass) == false then
		(
			theNodes = for o in theNodes where o.isHidden == false collect o
		)
		select theNodes
		for o in theNodes do
		(
			select o
			oName = o.name
			sceneNameState = (getIniSetting preferencesIni "Export" "SceneNameAs" as integer)
			layerNameState = (getIniSetting preferencesIni "Export" "LayerNameAs" as integer)
			CustomState = (getIniSetting preferencesIni "Export" "CustomAs" as integer)
			if layerNameState == 2 do
			(
				oName = layer + marker + oName
			)
			if layerNameState == 3 do
			(
				oName =  oName + marker + layer
			)
			
			if sceneNameState == 2 do
			(
				oName = (trimright maxFileName ".max") + marker + oName
			)
			if sceneNameState == 3 do
			(
				oName =  oName + marker + (trimright maxFileName ".max")
			)
			
			if CustomState == 2 do
			(
				oName = (getIniSetting preferencesIni "Export" "CustomString" as string) + marker + oName
			)
			if CustomState == 3 do
			(
				oName =  oName + marker + (getIniSetting preferencesIni "Export" "CustomString" as string)
			)
			--   + "_" + trimright maxFileName ".max" 
			exportTo = exportlocation + "\\" + oName
			exportFile exportTo  selectedOnly:true #noPrompt
		)
	)
)

fn ExpLocation =
(
	local exportlocation = getIniSetting locationlistini DiXporter.selectedLocation exportlabel
	local meshIni = exportlocation + "/MeshLocations.ini"
	try( deleteFile meshIni )catch()
	local marker = "^"
	for i = 1 to DiXporter.layerArray.count do 
	(
		layer = DiXporter.allLayerNames[DiXporter.layerArray[i]]
		(LayerManager.getLayerFromName(layer)).nodes &theNodes
		if (getIniSetting preferencesIni "Export" "ExportHidden" as booleanClass) == false then
		(
			theNodes = for o in theNodes where o.isHidden == false collect o
		)
		for o in theNodes do
		(
			setIniSetting meshIni o.name "x" (o.pos.x as string)
			setIniSetting meshIni o.name "y" (o.pos.y as string)
			setIniSetting meshIni o.name "z" (o.pos.z as string)
			
			setIniSetting meshIni o.name "Rotation" (o.rotation as string) -- as eulerAngles
		)
	)
)

rollout DiXporter "DiXporter" width:160 
(
	local allLayerNames = #()
	local layerArray = #()
	local selectedLocation 
	local expMethod = 2
	--exp functions
	fn ResetToMesh toReset =
	(
		ConvertToMesh toReset
		ResetXform toReset
		ConvertToMesh toReset
	)
	fn ExportLayersForUnity =
	(
		-- hold for backup
		max hold
		-- get dir for export
		local exportlocation = getIniSetting locationlistini selectedLocation exportlabel
		-- export each layer selected
		for i = 1 to layerArray.count do 
		(
			layer = allLayerNames[layerArray[i]]
			exportTo = "P_" + layer
			exportTo = exportlocation + "\\" + exportTo
			
			curObj = execute("$'"+ layer + "'")
			if curObj == undefined do
			(
				messagebox "No root object named " 
				return 0
			)
			if curObj.children != undefined do ( for obj in curObj.children do obj.parent = undefined )
			ResetToMesh (curObj)
			(LayerManager.getLayerFromName(layer)).nodes &theNodes
			theNodes = for o in theNodes where o.isHidden == false collect o
			for obj in theNodes where obj != curObj do (obj.parent = curObj)
			curObj.position = [0,0,0]
			curObj.rotation += unityRot as quat
			for obj in theNodes where obj != curObj do 
			(
				obj.parent = undefined
				ResetToMesh(obj)
			)
			ResetToMesh(curObj)
			parentDummy = dummy pos:curObj.pos name:("P_" + curObj.name) 
			--curObj.parent = parentDummy
			for obj in theNodes do obj.parent = parentDummy
			select parentDummy
			selectMore parentDummy.children

			exportFile exportTo  selectedOnly:true #noPrompt
		)
		max fetch
	)
	--Rollout Start
	dropdownList methoddrop "Export Type" pos:[8,8] width:144 height:40 items:#("File", "Layer",  "Mesh", "Layer For Unity") selection:expMethod
	listBox locationbox "Locations" pos:[8,50] width:144 height:8  selection:0 items:locationlistarray
	multiListBox layerlistbox "Layers" pos:[8,184] width:144 height:8 selection:0
	button exportbtn "Export" pos:[16,320] width:128 height:21 
	button explocationbtn "Export Position" pos:[16,350] width:128 height:21 
	button prefsbtn "Preferences" pos:[130,2] width:22 height:20 images:#("Pref_Icons.bmp", "undefined", 2, 1, 2, 1, 1)
	button reloadbtn "Reload" pos:[104,0] width:22 height:20 images:#("Reload_Icon.bmp", "undefined", 2, 1, 2, 1, 1)
	on DiXporter open do
	(
		layCount = layerManager.count - 1
		allLayerNames = for i = 1 to layCount collect (layermanager.getlayer i).name
		allLayerNames = sort(append allLayerNames ("0"))
		layerlistbox.items = allLayerNames
		methoddrop.selection = getIniSetting preferencesIni "Export" "ExpMethod" as integer
		--clearListener()
	)
	on prefsbtn pressed do
	(
		createDialog locationsRollout
	)
	on layerlistbox selected val do
	(
		max select none 
		layerArray = layerlistbox.selection as array
		for i = 1 to layerArray.count do 
		(
			ilayer = layerManager.getLayerFromName allLayerNames[layerArray[i]]
			ilayer.nodes &theNodes
			selectmore theNodes
		)
	)
	
	on locationbox selected val do
	(
		selectedLocation = locationbox.items[val]
		--print selectedLocation
	)
	
	on exportbtn pressed do
	(
		if selectedLocation != undefined then
		(
			if layerArray.count != 0 then
			(
				if methoddrop.selection == 1 do
				(
					ExportWholeFile()
				)
				
				if methoddrop.selection == 2 do
				(
					ExportLayers()
				)
				
				if methoddrop.selection == 3 do
				(
					if (getIniSetting preferencesIni "Export" "FlipForUnity" as booleanClass) == true do
					(
						Flip()
					)
					ExportSingleNodes()
					if (getIniSetting preferencesIni "Export" "FlipForUnity" as booleanClass) == true do
					(
						UnFlip()
					)
				)
				
				if methoddrop.selection == 4 do
				(
					ExportLayersForUnity()
				)
			)
			else (	messagebox "Please select a layer to export"	)
		)
		else	(	messagebox "Please select a location to export to"		)
		
	)
	on explocationbtn pressed do
	(
		if selectedLocation != undefined then
		(
			if layerArray.count != 0 then
			(
				ExpLocation()
			) else (	messagebox "Please select a layer to export"	)
		)
		else	(	messagebox "Please select a location to export to"		)
	)
	on methoddrop selected sel do
	(
		expMethod = sel
		setIniSetting preferencesIni "Export" "ExpMethod" (sel as string)
	)
	
	on reloadbtn pressed do
	(
		layCount = layerManager.count - 1
		allLayerNames = for i = 1 to layCount collect (layermanager.getlayer i).name
		allLayerNames = sort(append allLayerNames ("0"))
		layerlistbox.items = allLayerNames
	)
)
StartingPrecautions()
createDialog DiXporter
