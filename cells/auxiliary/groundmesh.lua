function parameters()

end

function layout()
    local groundmesh = object.create()

    groundmesh:merge_into(geometry.rectangle(
        generics.metal(-2), 5, 5
    ):translate(2.5, 0))
    groundmesh:merge_into(geometry.rectangle(
        generics.metal(-2), 5, 5
    ):translate(-2.5, 0))
    groundmesh:merge_into(geometry.rectangle(
        generics.metal(-2), 5, 5
    ):translate(0, 2.5))
    groundmesh:merge_into(geometry.rectangle(
        generics.metal(-2), 5, 5
    ):translate(0, -2.5))
                
    return groundmesh
end

--[[
let(
	(cv)
	cv = pcDefinePCell( list(ddGetObj(lib) cell "layout") 
	    (
	    	(flavour		string		"ground")
	    	(metalliststr 	string		"M1 M2 C1 C2 C3 C4 C5 JA QA QB")
	    	(drawgrid		boolean		t)
	    	(drawvv			boolean		nil)
	    	(drawleft		boolean		t)
	    	(drawright		boolean		t)
	    	(drawtop		boolean		t)
	    	(drawbot		boolean		t)
	    	(drawfill		boolean		nil)
	    	(rxwidth 		float 		0.4)
	    	(pphyboffset	float 		0.1)
    		(caviapitch 	float		0.2)
    		(mxwidth 		float		0.6)
    		(v1viapitch 	float		0.2)
    		(ayviapitch 	float		0.2)
	    	(cxwidth		float		0.8)
    		(axviapitch 	float		0.2)
    		(jawidth 		float		1.0)
    		(ysviapitch 	float		1)
	    )
	    let(
	    	(	
	    		(metallist parseString(metalliststr))
	    		(cellsize 10)
	    		(viapitch 0.2)
	    		shapes
	    	)
			
			; CA
			when(member("M1" metallist)
				MSCLayoutCreatePitchedVia(pcCellView "RXCAM1" rxwidth cellsize caviapitch ?x -0.5 * (cellsize - rxwidth) ?xcut 0.04 ?ycut 0.04)	
				MSCLayoutCreatePitchedVia(pcCellView "RXCAM1" rxwidth cellsize caviapitch ?x  0.5 * (cellsize - rxwidth) ?xcut 0.04 ?ycut 0.04)	
				MSCLayoutCreatePitchedVia(pcCellView "RXCAM1" cellsize rxwidth caviapitch ?y -0.5 * (cellsize - rxwidth) ?xcut 0.04 ?ycut 0.04)	
				MSCLayoutCreatePitchedVia(pcCellView "RXCAM1" cellsize rxwidth caviapitch ?y  0.5 * (cellsize - rxwidth) ?xcut 0.04 ?ycut 0.04)
				MSCLayoutCreateRing(pcCellView ?layer "PPLUS" ?width rxwidth + 2 * pphyboffset ?length cellsize - rxwidth ?height cellsize - rxwidth)	
				MSCLayoutCreateRing(pcCellView ?layer "HYBRID" ?width rxwidth + 2 * pphyboffset ?length cellsize - rxwidth ?height cellsize - rxwidth)		
			)
			
			; V1
			when(member("M1" metallist) && member("M2" metallist)
				MSCLayoutCreatePitchedViaStack(pcCellView "M1" "M2" mxwidth cellsize v1viapitch ?x -0.5 * (cellsize - mxwidth))	
				MSCLayoutCreatePitchedViaStack(pcCellView "M1" "M2" mxwidth cellsize v1viapitch ?x  0.5 * (cellsize - mxwidth))	
				MSCLayoutCreatePitchedViaStack(pcCellView "M1" "M2" cellsize mxwidth v1viapitch ?y -0.5 * (cellsize - mxwidth))	
				MSCLayoutCreatePitchedViaStack(pcCellView "M1" "M2" cellsize mxwidth v1viapitch ?y  0.5 * (cellsize - mxwidth))	
			)
			
			; M1 M2
			foreach(metal list("M1" "M2")
				when(member(metal metallist)
					shapes = MSCLayoutCreateRing(pcCellView ?layer metal ?width mxwidth ?length cellsize - mxwidth ?height cellsize - mxwidth)
					MSCLayoutColorShapes(shapes "mask1Color")
				)
			)
			
			; AY
			when(member("M2" metallist) && member("C1" metallist)
				MSCLayoutCreatePitchedViaStack(pcCellView "M2" "C1" mxwidth cellsize ayviapitch ?x -0.5 * (cellsize - mxwidth))	
				MSCLayoutCreatePitchedViaStack(pcCellView "M2" "C1" mxwidth cellsize ayviapitch ?x  0.5 * (cellsize - mxwidth))	
				MSCLayoutCreatePitchedViaStack(pcCellView "M2" "C1" cellsize mxwidth ayviapitch ?y -0.5 * (cellsize - mxwidth))	
				MSCLayoutCreatePitchedViaStack(pcCellView "M2" "C1" cellsize mxwidth ayviapitch ?y  0.5 * (cellsize - mxwidth))	
			)
			
			; Ax
			foreach(pair '(("C1" "C2") ("C2" "C3") ("C3" "C4") ("C4" "C5"))
				when(member(car(pair) metallist) && member(cadr(pair) metallist)
					MSCLayoutCreatePitchedViaStack(pcCellView car(pair) cadr(pair) cxwidth cellsize axviapitch ?x -0.5 * (cellsize - cxwidth))	
					MSCLayoutCreatePitchedViaStack(pcCellView car(pair) cadr(pair) cxwidth cellsize axviapitch ?x  0.5 * (cellsize - cxwidth))	
					MSCLayoutCreatePitchedViaStack(pcCellView car(pair) cadr(pair) cellsize cxwidth axviapitch ?y -0.5 * (cellsize - cxwidth))	
					MSCLayoutCreatePitchedViaStack(pcCellView car(pair) cadr(pair) cellsize cxwidth axviapitch ?y  0.5 * (cellsize - cxwidth))	
				)
			)
			
			; Cx
			foreach(metal list("C1" "C2" "C3" "C4" "C5")
				when(member(metal metallist)
					MSCLayoutCreateRing(pcCellView ?layer metal ?width cxwidth ?length cellsize - cxwidth ?height cellsize - cxwidth)
				)
			)

			; YS			
			when(member("C5" metallist) && member("JA" metallist)
				MSCLayoutCreatePitchedVia(pcCellView "C5YSJA" jawidth cellsize ysviapitch ?x -0.5 * (cellsize - jawidth))	
				MSCLayoutCreatePitchedVia(pcCellView "C5YSJA" jawidth cellsize ysviapitch ?x  0.5 * (cellsize - jawidth))	
				MSCLayoutCreatePitchedVia(pcCellView "C5YSJA" cellsize jawidth ysviapitch ?y -0.5 * (cellsize - jawidth))	
				MSCLayoutCreatePitchedVia(pcCellView "C5YSJA" cellsize jawidth ysviapitch ?y  0.5 * (cellsize - jawidth))	
			)
			
			; JA
			when(member("JA" metallist)
				MSCLayoutCreateRing(pcCellView ?layer "JA" ?width jawidth ?length cellsize - jawidth ?height cellsize - jawidth)
			)
			
			; JW
			when(member("QA" metallist) && member("QB" metallist)
				MSCLayoutCreateVia(pcCellView "QAJWQB" 5 5)	
			)
			
			when(drawvv
				MSCLayoutCreateVia(pcCellView "QBVVLB" 5 5)
			)
			
			when(flavour == "ground"
				let(
					(
						(straplen 1)
					)
					foreach(metal list("M1" "M2")
						when(member(metal metallist)
							foreach(offset list(-0.25 0 0.25)
								foreach(i list(-1 1)
									shapes = MSCLayoutCreateRectangle(pcCellView 
										?layer "M1" ?width 2 * mxwidth ?height straplen 
										?xoffset offset * cellsize 
										?yoffset i * 0.5 * (cellsize - 2 * mxwidth - straplen)
									)
									MSCLayoutColorShapes(shapes "mask1Color")
									MSCLayoutCreateVia(pcCellView
										"M1V1M2" 2 * mxwidth 0.5 * straplen
										?x offset * cellsize 
										?y i * (0.5 * cellsize - mxwidth - 0.75 * straplen)
									)
									shapes = MSCLayoutCreateRectangle(pcCellView 
										?layer "M2" ?width straplen ?height 2 * mxwidth
										?xoffset i * 0.5 * (cellsize - 2 * mxwidth - straplen)
										?yoffset offset * cellsize 
									)
									MSCLayoutColorShapes(shapes "mask1Color")
									MSCLayoutCreateVia(pcCellView
										"M1V1M2" 0.5 * straplen 2 * mxwidth
										?x i * (0.5 * cellsize - mxwidth - 0.75 * straplen)
										?y offset * cellsize 
									)
								)
								shapes = MSCLayoutCreateRectangle(pcCellView 
									?layer "M2" ?width 2 * mxwidth ?height cellsize - 2 * mxwidth - 1 * straplen
									?xoffset offset * cellsize
								)
								MSCLayoutColorShapes(shapes "mask2Color")
								shapes = MSCLayoutCreateRectangle(pcCellView 
									?layer "M1" ?width cellsize - 2 * mxwidth - 1 * straplen ?height 2 * mxwidth 
									?yoffset offset * cellsize
								)
								MSCLayoutColorShapes(shapes "mask2Color")
							)
						)
					)
					foreach(pair '(("C1" "C2") ("C2" "C3") ("C3" "C4") ("C4" "C5"))
						when(member(car(pair) metallist) && member(cadr(pair) metallist)
							MSCLayoutCreatePitchedViaStack(pcCellView car(pair) cadr(pair) 2 * cxwidth cellsize axviapitch)	
							MSCLayoutCreatePitchedViaStack(pcCellView car(pair) cadr(pair) 2 * cxwidth cellsize axviapitch)	
							MSCLayoutCreatePitchedViaStack(pcCellView car(pair) cadr(pair) cellsize 2 * cxwidth axviapitch)	
							MSCLayoutCreatePitchedViaStack(pcCellView car(pair) cadr(pair) cellsize 2 * cxwidth axviapitch)	
						)
					)
					when(member("JA" metallist) && member("QA" metallist)
						when(drawleft MSCLayoutCreateVia(pcCellView "JAJVQA" 2.5 5 ?x -3.75))
						when(drawright MSCLayoutCreateVia(pcCellView "JAJVQA" 2.5 5 ?x  3.75))
					)
					; draw JA
					when(member("JA" metallist)
						MSCLayoutCreateRing(pcCellView ?layer "JA" ?width 2.5 ?length cellsize - 2.5 ?height cellsize - 2.5)
					)
				) ; let
			) ; when
			
			when(flavour == "cap"
			    letseq(
			    	(	
			    		(capmetallist MSCLayoutGetMetalList("M1" "C5"))
	    				(connwidth 0.6)
	    				(finger 33)
	    				(fwidth 0.05)
	    				(fspace 0.05)
	    				(foffset 0.1)
	    				(fdist 0.6)
			    		(mod 1)
			    		shapes
			    	)
			    	; draw fingers
			        foreach(metal setof(m list("M1" "M2") member(m metallist))
				        shapes = MSCLayoutCreateRectangle(pcCellView
				            ?layer metal
				            ?width fwidth
				            ?height 0.5 * (cellsize - 2 * mxwidth - connwidth - 2 * foffset)
				            ?xrep fix(0.5 * (cellsize - 2 * cxwidth - 2 * fdist - fwidth) / (fwidth + fspace)) + 1
				            ?xpitch 2 * (fwidth + fspace)
				            ?yrep 2
				            ?ypitch 0.5 * (cellsize - 2 * mxwidth - connwidth - 2 * foffset) + connwidth + 2 * foffset
				        )
				        MSCLayoutColorShapes(shapes "mask1Color")
				        shapes = MSCLayoutCreateRectangle(pcCellView
				            ?layer metal
				            ?width fwidth
				            ?height 0.5 * (cellsize - 2 * mxwidth - connwidth - 2 * foffset)
				            ?xrep fix(0.5 * (cellsize - 2 * cxwidth - 2 * fdist - fwidth) / (fwidth + fspace))
				            ?xpitch 2 * (fwidth + fspace)
				            ?yrep 2
				            ?ypitch 0.5 * (cellsize - 2 * mxwidth - connwidth - 2 * foffset) + connwidth
				        )
				        MSCLayoutColorShapes(shapes "mask2Color")
			        ) ; foreach
			        foreach(metal setof(m list("C1" "C2" "C3" "C4" "C5") member(m metallist))
				        MSCLayoutCreateRectangle(pcCellView
				            ?layer metal
				            ?width fwidth
				            ?height 0.5 * (cellsize - 2 * cxwidth - connwidth - 2 * foffset)
				            ?xrep fix(0.5 * (cellsize - 2 * cxwidth - 2 * fdist - fwidth) / (fwidth + fspace)) + 1
				            ?xpitch 2 * (fwidth + fspace)
				            ?yrep 2
				            ?ypitch 0.5 * (cellsize - 2 * cxwidth - connwidth - 2 * foffset) + connwidth + foffset + mod * foffset
				        )
				        MSCLayoutCreateRectangle(pcCellView
				            ?layer metal
				            ?width fwidth
				            ?height 0.5 * (cellsize - 2 * cxwidth - connwidth - 2 * foffset)
				            ?xrep fix(0.5 * (cellsize - 2 * cxwidth - 2 * fdist - fwidth) / (fwidth + fspace))
				            ?xpitch 2 * (fwidth + fspace)
				            ?yrep 2
				            ?ypitch 0.5 * (cellsize - 2 * cxwidth - connwidth - 2 * foffset) + connwidth + foffset - mod * foffset
				        )
				        mod = -mod
			        ) ; foreach
			        
				    ; connect to vdd
				    when(member("M1" metallist)
					    shapes = MSCLayoutCreateRectangle(pcCellView ?layer "M1" ?width cellsize - 2 * cxwidth - 2 * fdist ?height connwidth)
					    MSCLayoutColorShapes(shapes "mask2Color")
				    )
				    when(member("M2" metallist)
					    shapes = MSCLayoutCreateRectangle(pcCellView ?layer "M2" ?width cellsize - 2 * cxwidth - 2 * fdist ?height connwidth)
					    MSCLayoutColorShapes(shapes "mask2Color")
				    )
					foreach(pair '(("M1" "M2") ("M2" "C1") ("C1" "C2") ("C2" "C3") ("C3" "C4") ("C4" "C5"))
						when(member(car(pair) metallist) && member(cadr(pair) metallist)
							MSCLayoutCreatePitchedViaStack(pcCellView car(pair) cadr(pair) cellsize - 2 * cxwidth - 2 * fdist connwidth 0.2)		
						)
					)
				    when(member("C5" metallist) && member("JA" metallist)
					    MSCLayoutCreateVia(pcCellView "C5YSJA" cellsize - 2 * cxwidth - 2 * fdist connwidth)
				    )
				    when(member("JA" metallist) && member("QA" metallist)
						MSCLayoutCreateVia(pcCellView "JAJVQA" 5 5)	
					)
					; nwell + tap (helps with antenna)
					let(
						(
							(ntwidth 1.4)
							(ntheight 1.4)
						)
				    	when(member("M1" metallist)
							MSCLayoutCreateRectangle(pcCellView
								?layer "RX"
								?width ntwidth
								?height ntheight
							)
							MSCLayoutCreateRectangle(pcCellView
								?layer "DIODE"
								?width ntwidth + 0.2
								?height ntheight + 0.2
							)
							MSCLayoutCreateRectangle(pcCellView
								?layer "NPLUS"
								?width ntwidth + 0.4
								?height ntheight + 0.4
							)
							MSCLayoutCreateRectangle(pcCellView
								?layer "HYBRID"
								?width ntwidth + 0.4
								?height ntheight + 0.4
							)
							MSCLayoutCreatePitchedVia(pcCellView "RXCAM1" ntwidth connwidth 0.2 ?xcut 0.04 ?ycut 0.04)	
						)
					) ; let
			    ); let
				
			) ; when flavour == "cap"
			
			; fill
			when(drawfill
				let(
					(
						(numfill 10)
					)
					for(i 1 numfill 
						for(j 1 numfill 
							when(if(flavour == "ground" then t else i < 4 || i > 7 || j < 4 || j > 7)
								dbCreateInstByMasterName(
									pcCellView
									"msctech" "EQ_CFILL_GoLd" "layout"
									lsprintf("TFILL_%d_%d" i j) (i - 0.5 * (numfill - 1) - 1) * 0.79 - 0.48:(j - 0.5 * (numfill - 1) - 1) * 0.8 - 0.45 "R0" 1
								)
							)
						)
					)
				)
			)
		
			; draw exclude
			when(drawfill
				MSCLayoutCreateRectangle(pcCellView	?layer "RX" ?purpose "exclude" ?width cellsize ?height cellsize)
				MSCLayoutCreateRectangle(pcCellView ?layer "PC" ?purpose "exclude" ?width cellsize ?height cellsize)
				MSCLayoutCreateRectangle(pcCellView ?layer "CT" ?purpose "exclude" ?width cellsize ?height cellsize)
			)
			MSCLayoutCreateRectangle(pcCellView	
				?layer setof(l list("M1" "M2" "C1" "C2" "C3" "C4" "C5" "JA" "QA" "QB") member(l metallist))
				?purpose "exclude" ?width cellsize + 0.1 ?height cellsize + 0.1
			)
	    ); let 
	) ; pcDefinePCell
	dbSave(cv)
	dbClose(cv)
) ; let
--]]
