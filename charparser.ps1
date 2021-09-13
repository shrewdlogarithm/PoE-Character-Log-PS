$POBTREEVER = "3_14"

$passivedb = Get-Content -Raw -Path "$PSScriptRoot/passive-skill-tree.json" | ConvertFrom-Json
function getpassives($passives) {
    ForEach($passive in $passives) {
        if ($passivedb.nodes.$passive.isnotable) {
            $passivedb.nodes.$passive.name
        } else {
            -join($passivedb.nodes.$passive.name," [",$passive,"]")
        }
    }

}

function buildskills ($items) {
    $gemgroups = New-Object PSObject 
    ForEach($item in $items) {
        [String] $slot = $item.inventoryId
        if ($slot -and $slot -ne "MainInventory" -and $slot -ne "Flask" -and $slot -ne "Weapon2" -and $slot -ne "Offhand2") {
            $gemobjs = @()
            For ($g = 0;$g -lt 6;$g++) {
                $gemobjs += @{
                    gems=@() 
                    supports=@()
                }
            }
            $gemgroups | Add-Member -NotePropertyName "$slot" -NotePropertyValue $gemobjs
            for ($gem = 0; $gem -lt $item.socketedItems.count; $gem++) {
                $group = $item.sockets[$gem].group
                if ($item.socketedItems[$gem].typeLine -and $item.socketedItems[$gem].colour) {
                    if ($item.socketedItems[$gem].support) {
                        $gemgroups.$slot[$group].supports += $item.socketedItems[$gem].typeLine
                    } else {
                        $gemgroups.$slot[$group].gems += $item.socketedItems[$gem].typeLine
                    }
                }
            }
        }
    }
    $gemgroups
}

function getskills ($items) {
    $gemgroups = buildskills($items) 
    $gemgroups | Get-Member -MemberType NoteProperty | ForEach-Object {
        $slot = $_.Name
        ForEach ($group in $gemgroups."$slot") {
            #ForEach ($gem in $group.gems) {
            #    $gem
            #}
            #ForEach ($gem in $group.supports) {
            #    $gem + " >> " + $group.gems
            #}
            if ($group["gems"].count -gt 0 -or $group["supports"].count -gt 0) {
                $gemout = $group["gems"] -join " | "
                $suppout = $group["supports"] -join " | "
                $gemout + " >> " + $suppout 
            }
        }        
    }
}

function getitems($items) {
    ForEach($item in $items) {
        $sockets = ""
        [String] $slot = $item.inventoryId
        if ($slot -and $slot -ne "MainInventory") {
            ForEach($socket in $item.sockets) {
                $sockets += $socket.sColour
            }
            $name = $item.typeline
            if ($item.name) {
                $name = $item.name + " " + $item.typeline
            }
            $name += " iLvl:" + $item.ilvl + " " + $sockets
            $name
        }
    }
}

function maketreelink($item) {
    [byte[]] $b = 0,0,0,4,$item.character.classid,$item.character.ascendancyClass,0
    ForEach ($node in $item.passives) {
        $b += [math]::floor($node/256)
        $b += $node % 256
    }
    "https://www.pathofexile.com/fullscreen-passive-skill-tree/" + (([Convert]::ToBase64String($b) -replace "\+","-") -replace "\/","_")
}


function showchanges($before, $after, $bpref, $apref) {
    ForEach ($bef in $before) {
        if ($bef -notin $after) {
           $bpref + $bef
        }
    }
    ForEach ($aft in $after) {
        if ($aft -notin $before) {
           $apref + $aft
        }
    }
}

function makelogs($befitem, $aftitem) {
    if ($befitem.character.level -ne $aftitem.character.level) {
        "Reached Level " + $aftitem.character.level
    }
       
    $before = getpassives $befitem.passives
    $after = getpassives $aftitem.passives
    showchanges $before $after "Deallocated " "Allocated "

    $before = getitems $befitem.items
    $after = getitems $aftitem.items
    showchanges $before $after "Removed " "Equipped "

    $before = getskills $befitem.items
    $after= getskills $aftitem.items
    showchanges $before $after "Unsocketed " "Socketed "

    if ($befitem.character.level -ne $aftitem.character.level) {
        $lasttreelink = maketreelink($befitem)
        $treelink = maketreelink($aftitem)
        if ($lasttreelink -ne $treelink) {
            "Passive Tree " + $treelink
        }
    }
}

$className = @("Scion","Marauder","Ranger","Witch","Duelist","Templar","Shadow")
$ascendName = @(
    @("None","Ascendant"),
    @("None","Juggernaut","Berserker","Chieftain"),
    @("None","Raider","Deadeye","Pathfinder"),
    @("None","Occultist","Elementalist","Necromancer"),
    @("None","Slayer","Gladiator","Champion"),
    @("None","Inquisitor","Hierophant","Guardian"),
    @("None","Assassin","Trickster","Saboteur")
)
$rarity = @("NORMAL","MAGIC","RARE","UNIQUE")
$socketTrans = @{
    "Weapon" = "Weapon 1"
    "Offhand" = "Weapon 2"
    "Weapon2" = "Weapon 1 Swap"
    "Offhand2" = "Weapon 2 Swap"
    "Amulet" = "Amulet"
    "Gloves" = "Gloves"
    "Boots" = "Boots"
    "Ring" = "Ring 1"
    "Ring2" = "Ring 2"
    "Belt" = "Belt"
    "BodyArmour" = "Body Armour"
    "Helm" = "Helmet"
    "Flask" = "Flask"
}

function getbyname ($attrs,$attr,$name) {
    foreach ($at in $attrs.$attr) {
        if ($at.name -and $at.name -eq $name) {
            return ,$at.values[0][0]
        }
    }
}

function makexml($chardata,$xmname) {
    [XML]$pobxml = {}
    $pob = $pobxml.CreateElement("PathOfBuilding")
    [void]$pobxml.AppendChild($pob)
    $summary = $pobxml.CreateElement("Summary")
    [void]$summary.setAttribute("LevelFrom", $chardata[0].character.level)
    [void]$summary.setAttribute("LevelTo",$chardata[$chardata.length-1].character.level)
    [void]$pob.AppendChild($summary)
    $build = $pobxml.CreateElement("Build")
    [void]$build.setAttribute("targetVersion","3_0")
    [void]$build.setAttribute('level',$chardata[$chardata.length-1].character.level)
    [void]$build.setAttribute('className',$className[$chardata[$chardata.length-1].character.classId])
    [void]$build.setAttribute('ascendClassName',$ascendName[$chardata[$chardata.length-1].character.classId][$chardata[$chardata.length-1].character.ascendancyClass])
    [void]$build.setAttribute("viewMode","ITEMS")
    [void]$pob.AppendChild($build)
    $tree = $pobxml.CreateElement("Tree")
    [void]$tree.SetAttribute("activeSpec","1")
    [void]$pob.AppendChild($tree)
    $items = $pobxml.CreateElement("Items")
    [void]$items.setAttribute("activeItemSet","1")
    [void]$items.setAttribute("useSecondWeaponSet","nil")
    [void]$pob.AppendChild($items)
    $skills = $pobxml.CreateElement("Skills")
    [void]$pob.AppendChild($skills)
    $skilldb = @{}
    $itemdb = @{}
    $lastset = @{}
    $itn = 1
    $isn = 1
    for ($e=0;$e -lt $chardata.length;$e++) {
        $lastnodes = $chardata[$e-1].passives -join ","
        $nodes = $chardata[$e].passives -join ","
        if ($nodes -ne $lastnodes) {
            $spec= $pobxml.CreateElement("Spec")
            [void]$spec.setAttribute("title","$e - Level " + $chardata[$e].character.level)
            [void]$spec.setAttribute("ascendClassId",$chardata[$e].character.ascendancyClass)
            [void]$spec.setAttribute("nodes",$nodes)
            [void]$spec.setAttribute("treeVersion",$POBTREEVER)
            [void]$spec.setAttribute("classId",$chardata[$e].character.classId)
            [void]$tree.AppendChild($spec)
        }
        $gemgroups = buildskills($chardata[$e].items)  
        $gemgroups | Get-Member -MemberType NoteProperty | ForEach-Object {
            $slot = $_.name
            $skill = $pobxml.CreateElement("Skill")
            $skillset = ""
            foreach ($group in $gemgroups.$slot) {
                if ($group.gems.count -gt 0) {
                    $skillset += (($group.gems | sort) -join " ") + " " + (($group.supports| sort) -join " ")
                    foreach ($gm in ($group["gems"]+$group["supports"])) {
                        $gem = $pobxml.CreateElement("Gem")
                        [void]$gem.setAttribute("level","1")
                        [void]$gem.setAttribute("nameSpec",($gm -replace " Support",""))
                        [void]$gem.setAttribute("quality","0")
                        [void]$gem.setAttribute("enabled","true")
                        [void]$skill.appendChild($gem)
                    }
                }
            }
            if ($skillset -ne "" -and (-not $skilldb.ContainsKey($slot) -or $skilldb[$slot] -notcontains $skillset)) {
                [void]$skill.setAttribute("label","" + $chardata[$e].character.level + "-" + $skillset)
                [void]$skill.setAttribute("slot","" + $socketTrans[$slot])
                [void]$skill.setAttribute("enabled","true")                        
                [void]$skills.appendChild($skill)
                $skilldb[$slot] = $skillset
           }
        }
        $itemset = $pobxml.CreateElement("ItemSet")
        [void]$itemset.setAttribute("id",$isn)
        [void]$itemset.setAttribute("useSecondWeaponSet","nil")
        [void]$itemset.setAttribute("title","$isn - Level " + $chardata[$e].character.level)
        $fln = 1
        foreach ($itm in $chardata[$e].items) {
            if ($socketTrans.ContainsKey($itm.inventoryId) -and $itm.frameType -lt 4) {
                $itemkey = $itm.name + $itm.typeLine
                $itemno = $itn
                if ($itemdb.ContainsKey($itemkey)) {
                    $itemno = $itemdb.$itemkey
                } else {
                    $itemdb.$itemkey = $itn
                    $item = $pobxml.CreateElement("Item")
                    [void]$item.setAttribute("id",$itemno)
                    [void]$pob.AppendChild($item)
                    $itemtext = "`nRarity: " + $rarity[$itm.frameType] + "`n" + $itm.name + "`n" + $itm.typeLine + "`n" 
                    $itemtext = $itemtext -replace [char]246, "o" # the Maelstrom 'o'
                    $itemtext = $itemtext -replace [char]228, "a" # the Doppelganger 'a'
                    if ($itm.id) {
                        $itemtext += "Unique ID :" + $itm.id + "`n"
                    }
                    if ($itm.ilvl) {
                        $itemtext +=  "Item Level: " + $itm.ilvl + "`n"
                    }
                    $lvlreq = getbyname $itm "requirements" "Level"
                    if ($itm.sockets) {
                        $itemtext = $itemtext + "Sockets: "
                        for ($gem=0;$gem -lt $itm.sockets.length;$gem++) {
                            if ($gem -gt 0 -and $itm.sockets[$gem-1].group -ne $itm.sockets[$gem].group) {
                                $itemtext = $itemtext + " "
                            } elseif ($gem -gt 0) {
                                $itemtext = $itemtext + "-"
                            }
                            $itemtext = $itemtext + $itm.sockets[$gem].sColour
                        }
                        $itemtext = $itemtext + "`n"
                    }
                    if ($lvlreq) {
                        $itemtext = $itemtext +  "LevelReq: $lvlreq`n"
                    }
                    if ($itm.implicitMods) {
                        $itemtext = $itemtext + "Implicits: " + $itm.implicitMods.length + "`n"
                        foreach ($imp in $itm.implicitMods) {
                            $itemtext = $itemtext + $imp + "`n"
                        }
                    }
                    if ($itm.explicitMods) {
                        foreach ($exp in $itm.explicitMods) {
                            $itemtext = $itemtext + $exp + "`n"
                        }
                    }
                    $text = $pobxml.CreateTextNode($itemtext)
                    [void]$item.appendChild($text)
                    [void]$items.appendChild($item)

                    $itn = $itn + 1
                }
                $iid = $socketTrans[$itm.inventoryId]
                if ($iid -eq "Flask") {
                    $iid += " $fln"
                    $fln = $fln + 1
                }
                $islot = $pobxml.CreateElement("Slot")
                [void]$islot.setAttribute("name",$iid)
                [void]$islot.setAttribute("itemId",$itemno)
                [void]$itemset.appendChild($islot)
                if (-not $itemset.parentNode -and (!$lastset.ContainsKey($iid) -or $lastset.$iid -ne $itemno)) {
                    [void]$items.appendChild($itemset)
                    $isn = $isn + 1
                }
                $lastset.$iid = $itemno
            }
        }
    }

    if ($xmname) {

        [System.Xml.XmlWriterSettings] $XmlSettings = New-Object System.Xml.XmlWriterSettings
        $XmlSettings.Indent = $true
        $XmlSettings.Encoding = New-Object System.Text.UTF8Encoding($false)

        [System.Xml.XmlWriter] $XmlWriter = [System.Xml.XmlWriter]::Create($xmname, $XmlSettings)
        $pobxml.Save($XmlWriter)

        $XmlWriter.Dispose()
    } else {
        return ,$pobxml
    }
}