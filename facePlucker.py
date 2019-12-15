# This script will find all faces in each frame and if so, saves them all
# However, it also keeps track of past faces and will only save each face once
# If a larger/clearer face of a previously seen face exists, we update it
# If we simply extracted faces, the average would be skewed because some
# face would be in frame longer than others. This is the sole reason
# the script is larger than it really should be, but I digress

from os import walk, remove
from PIL import Image
import face_recognition as FR

skip = 0
bypass = False
area, finalFiles, fingerprints, fingerprintSizes = [], [], [], []
(_, _, filenames) = next(walk("frames/"))
filenames = sorted(filenames)

for fNum, frame in enumerate(filenames):
	# Enumerate frames front to back, beginning to end
	image = FR.load_image_file(f"frames/{frame}")
	# Detect faces in the current frame
	faceLocs = FR.face_locations(image)

	s = "[-] Frame {} had {} faces. {}% done. {} people found" + " " * 10
	s = s.format(fNum, len(faceLocs), round(fNum/len(filenames)*100, 2), len(fingerprints))
	print(s, end="\r", flush=True)
	
	# For each face (0 faces naturally skip)
	for i, face_location in enumerate(faceLocs):
		# Get the position in frame, area/size and load it to an array
		top, right, bottom, left = face_location
		faceImg = image[top:bottom, left:right]
		area = (right - left) * (bottom - top)
		f = frame + "-" + str(i)
		img = Image.fromarray(faceImg)
		numPrints = len(fingerprints)
		
		# To be completely honest, I forgot why this is necessary
		try:
			fingerprint = FR.face_encodings(faceImg)[0]
			distances = FR.face_distance(fingerprints, fingerprint)
		except: bypass = True

		# If the current face is of decent size and it's confident it's unique
		if area > 8000 and (not bypass) and (numPrints == 0 or min(distances) > 0.55):
			# Then commit a new face to the fingerprints and save the image
			fingerprints.append(fingerprint)
			fingerprintSizes.append(area)
			finalFiles.append(f"ims/{f}.jpg")
			img.save(f"ims/{f}.jpg")
			
		# If the current face is of decent size and it's been seen before
		elif area > 8000 and (not bypass) and numPrints > 0 and min(distances) <= 0.55:
			# Check if the previous picture of this face was smaller
			idx = distances.tolist().index(min(distances))
			if area > fingerprintSizes[idx]:
				# If so, update the saved image file and its fingerprint entry
				fingerprints[idx] = fingerprint
				fingerprintSizes[idx] = area
				remove(finalFiles[idx])
				finalFiles[idx] = f"ims/{f}.jpg"
				img.save(f"ims/{f}.jpg")
				
		bypass = False