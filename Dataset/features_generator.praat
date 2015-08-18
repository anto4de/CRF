Create Strings as file list: "wavlist", "*.wav"
strings = Create Strings as file list: "gridlist", "*.TextGrid"
numberOfFiles = Get number of strings
writeFileLine: "features.txt", ""

for j to 1

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
	output$ = soundname$ + ".Pitch"
	select Sound myWav
	intensityname$ = selected$ ("Sound")
	To Intensity: 100, 0
	output$ = intensityname$ + ".Intensity"


	for i to numberOfWords

		select TextGrid myTextGrid
		word$ = Get label of interval: 1, i

		if word$ = "#"
			appendFileLine: "features.txt", ""

		else

			#Start point and end point fo the current word
			startPoint = Get start point: 1, i
			endPoint = Get end point: 1, i

			#Select the dialogue act of the current word
			dialogueAct = Get interval at time: 2, startPoint
			dialogueAct$ = Get label of interval: 2, dialogueAct


			#calcolo l'istante d'inizio e l'istante di fine dell'intervallo precedente (che mi servirà per calcolare l'average pitch e l'average intensity dell'intervallo precedente)
			if i>1
				startPointPre = Get start point... 1 i-1
				endPointPre = Get end point... 1 i-1
			else
				startPointPre = 0
				endPointPre = 0
			endif

			#calcolo l'istante d'inizio e l'istante di fine dell'intervallo successivo (che mi servirà per calcolare l'average pitch e l'average intensity dell'intervallo successivo)
			if i < numberOfWords
				startPointPost = Get start point... 1 i+1
				endPointPost = Get end point... 1 i+1
			else
				startPointPre = Get start point... 1 i
				endPointPre = Get end point... 1 i
			endif

			select Pitch 'soundname$'

			#calcolo l'average pitch dell'intervallo precedente (che mi servirà per calcolare il delta pitch dell'intervallo corrente)
			f0avgPre = Get mean: startPointPre, endPointPre, "Hertz"

			#calcolo l'average pitch dell'intervallo successivo (che mi servirà per calcolare il delta pitch dell'intervallo corrente)
			f0avgPost = Get mean: startPointPost, endPointPost, "Hertz"

			#calcolo l'average pitch dell'intervallo corrente
			f0avg = Get mean: startPoint, endPoint, "Hertz"

			#calcolo il delta pitch dell'intervallo corrente
			deltaPitch = (f0avgPost - f0avgPre) / (endPoint - startPoint)

			if deltaPitch = undefined
			else
				if deltaPitch<0
					deltaPitch = deltaPitch*(-1)
				endif
			endif

			select Intensity 'intensityname$'

			#calcolo l'average intensity dell'intervallo precedente (che mi servirà per calcolare il delta intensity dell'intervallo corrente)
			meanIntensityPre = Get mean... startPointPre endPointPre dB

			#calcolo l'average intensity dell'intervallo successivo (che mi servirà per calcolare il delta intensity dell'intervallo corrente)
			meanIntensityPost = Get mean... startPointPost endPointPost dB

			#calcolo l'average intensity dell'intervallo corrente
			meanIntensity = Get mean... startPoint endPoint dB

			#calcolo il delta intensity dell'intervallo corrente
			deltaIntensity = (meanIntensityPost - meanIntensityPre) / (endPoint - startPoint)
			if deltaIntensity = undefined
			else
				if deltaIntensity<0
					deltaIntensity = deltaIntensity*(-1)
				endif
			endif

			appendFileLine: "features.txt", dialogueAct$ + tab$ + "word=" + word$ + tab$ + "avgPitch=" + tab$ + "dPitch=" + tab$ + "intensity=" + tab$ + "dIntensity="

		endif

	endfor

endfor
