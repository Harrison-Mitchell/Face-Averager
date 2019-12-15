import sys, os, dlib, glob, skimage

detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor("model.dat")

# Make a list of all images
files = glob.glob('ims/*.jpg')
files.extend(glob.glob('ims/*.jpeg'))
files.extend(glob.glob('ims/*.png'))
files = sorted(files)

for f in files:
	img = skimage.io.imread(f)
	try:
		# I grab only the first face in images with many. It's about
		# double the current script length to handle extra faces
		dets = detector(img, 1)[0]
		print(f"[+] Face was found in {f[:26]}" + " " * 10, end="\r")
		shape = predictor(img, dets)
		# Once the 68 face points are found, write them to their txt
		with open(f + '.txt', 'w') as file:
			for i in range(0, 68):
				file.write(str(shape.part(i))[1:-1].replace(',', '') + '\n')
	except:
		# If there are no faces in this image, delete it so it doesn't
		# hurt us later down the line
		os.remove(f)
		print(f"[-] Face not found in {f[:26]}" + " " * 10, end="\r")
		
print("[+] Face triangulation is complete!                   ")