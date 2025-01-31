Create Strings as file list: "wavlist", "*.wav"
strings = Create Strings as file list: "gridlist", "*.TextGrid"
numberOfFiles = Get number of strings
writeFile: "features.txt", ""
writeFile: "log.txt", ""
avgPitchMean = 182
deltaPitchMean = -26
avgIntensityMean = 69
deltaIntensityMean = 0
avgF1Mean = 1742
avgF2Mean = 3414
avgHarmonicityMean = 6.6


for j to numberOfFiles

	select Strings gridlist
	filename$ = Get string: j
	Read from file: filename$
	Rename: "myTextGrid"
	select TextGrid myTextGrid
	numberOfWords = Get number of intervals: 1
	
	
	select Strings wavlist
	filename$ = Get string: j
	Read from file: filename$
	Rename: "myWav"


	select Sound myWav
	soundname$ = selected$ ("Sound")
	To Pitch: 0.01, 75, 400
	select Sound myWav
	To Intensity: 100, 0
	select Sound myWav
    To Formant (burg): 0.01, 2, 5500, 0.025, 50
	select Sound myWav
    To Harmonicity (cc): 0.1, 75, 0.1, 4.5


	for i to numberOfWords

		select TextGrid myTextGrid
		word$ = Get label of interval: 1, i

		if word$ = "#"
			if i <> 1 and i <> numberOfWords
				appendFileLine: "features.txt", ""
			endif
		else

			#Start point and end point of the current word
			startPoint = Get start point: 1, i
			endPoint = Get end point: 1, i

			#Select the dialogue act of the current word
			dialogueAct = Get interval at time: 2, startPoint
			dialogueAct$ = Get label of interval: 2, dialogueAct
			if dialogueAct$ = ""
				dialogueAct$ = "uninterpretable"
			endif

			#calculate start point and end point of the previous interval
			if i > 1
				startPointPre = Get start point: 1, i-1
				endPointPre = Get end point: 1, i-1
			else
				startPointPre = 0
				endPointPre = 0
			endif

			#calculate start point and end point of the next interval
			if i < numberOfWords
				startPointPost = Get start point: 1, i+1
				endPointPost = Get end point: 1, i+1
			else
				startPointPost = Get start point: 1, i
				endPointPost = Get end point: 1, i
			endif

			select Pitch 'soundname$'

			#calculate avg pitch of the current interval
			avgPitch = Get mean: startPoint, endPoint, "Hertz"
			if avgPitch <> undefined
				if avgPitch >= avgPitchMean
					avgPitch = round(ln(((avgPitch - avgPitchMean) / 10) + 1))
				else
					avgPitch = round(ln(((avgPitchMean - avgPitch) / 10) + 1)) * -1
				endif
			endif
			avgPitch$ = fixed$ (avgPitch, 0)

			#calculate avg pitch of the prev interval
			avgPitchPre = Get mean: startPointPre, endPointPre, "Hertz"

			#calculate avg pitch of the next interval
			avgPitchPost = Get mean: startPointPost, endPointPost, "Hertz"

			#calculate delta pitch
			deltaPitch = (avgPitchPost - avgPitchPre)/(endPoint - startPoint)
			if deltaPitch <> undefined
				if deltaPitch >= deltaPitchMean
					deltaPitch = round(ln(((deltaPitch - deltaPitchMean) / 100) + 1))
				else
					deltaPitch = round(ln(((deltaPitchMean - deltaPitch) / 100) + 1)) * -1
				endif
			endif
			deltaPitch$ = fixed$ (deltaPitch, 0)

			select Intensity 'soundname$'

			#calculate avg intensity of the current interval
			avgIntensity = Get mean: startPoint, endPoint, "dB"
			if avgIntensity <> undefined
				if avgIntensity >= avgPitchMean
					avgIntensity = round(ln(((avgIntensity - avgIntensityMean) / 10) + 1))
				else
					avgIntensity = round(ln(((avgIntensityMean - avgIntensity) / 10) + 1)) * -1
				endif
			endif
			avgIntensity$ = fixed$ (avgIntensity, 0)

			#calculate avg intensity of the prev interval
			avgIntensityPre = Get mean: startPointPre, endPointPre, "dB"

			#calculate avg pitch of the next interval
			avgIntensityPost = Get mean: startPointPost, endPointPost, "dB"

			#calculate delta intensity
			deltaIntensity = (avgIntensityPost - avgIntensityPre) / (endPoint - startPoint)
			if deltaIntensity <> undefined
				if deltaIntensity >= avgPitchMean
					deltaIntensity = round(ln(((deltaIntensity - deltaIntensityMean) / 20) + 1))
				else
					deltaIntensity = round(ln(((deltaIntensityMean - deltaIntensity)) / 20)) * -1
				endif
			endif
			deltaIntensity$ = fixed$ (deltaIntensity, 0)

			select Formant 'soundname$'

			#calculate avgF1 and avgF2 of the current interval
			avgF1 = Get mean: 1, startPoint, endPoint, "Hertz"
			if avgF1 <> undefined
				if avgF1 >= avgF1Mean
					avgF1 = round(ln(((avgF1 - avgF1Mean) / 20) + 1))
				else
					avgF1 = round(ln(((avgF1Mean - avgF1) / 20) + 1)) * -1
				endif
			endif
			avgF1$ = fixed$ (avgF1, 0)
			avgF2 = Get mean: 2, startPoint, endPoint, "Hertz"
			if avgF2 <> undefined
				if avgF2 >= avgF2Mean
					avgF2 = round(ln(((avgF2 - avgF2Mean) / 20) + 1))
				else
					avgF2 = round(ln(((avgF2Mean - avgF2) / 20) + 1)) * -1
				endif
			endif
			avgF2$ = fixed$ (avgF2, 0)

			select Harmonicity 'soundname$'

			#calculate avgHarmonicity of the current interval
            avgHarmonicity = Get mean: startPoint, endPoint
			if avgHarmonicity <> undefined
				if avgHarmonicity >= avgHarmonicityMean
					avgHarmonicity = round(ln(((avgHarmonicity - avgHarmonicityMean)) + 1))
				else
					avgHarmonicity = round(ln(((avgHarmonicityMean - avgHarmonicity)) + 1)) * -1
				endif
			endif
            avgHarmonicity$ = fixed$ (avgHarmonicity, 0)


			if avgHarmonicity <> undefined
				appendFileLine: "log.txt", avgHarmonicity$
			endif


			output$ = dialogueAct$ + tab$
			output$ = output$ + "word=" + word$ + tab$
			output$ = output$ + "avgPitch=" + avgPitch$ + tab$
			output$ = output$ + "deltaPitch=" + deltaPitch$ + tab$
			output$ = output$ + "avgIntensity=" + avgIntensity$ + tab$
			output$ = output$ + "deltaIntensity=" + deltaIntensity$ + tab$
			output$ = output$ + "avgF1=" + avgF1$ + tab$
			output$ = output$ + "avgF2=" + avgF2$ + tab$
			output$ = output$ + "avgHarmonicity=" + avgHarmonicity$

			appendFileLine: "features.txt", output$

		endif

	endfor
	appendFileLine: "features.txt", ""

endfor