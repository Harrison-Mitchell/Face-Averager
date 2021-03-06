#!/bin/bash

# Create and empty necessary dirs
mkdir -p ims
mkdir -p faces
mkdir -p frames

# Fixed strings
MODEL="http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2"
AVGPY="https://raw.githubusercontent.com/spmallick/learnopencv/master/FaceAverage/faceAverage.py"

# If cmake hasn't been installed, prompt the user to do it themselves
if [ $(which cmake | wc -l) -eq 0 ]; then
	echo "[!] cmake is needed. Download through your package manager"
	echo "[!] e.g sudo apt install cmake"
	echo "[!] It will install itself, but it's slow so be patient :)"
	echo "[!] Once you've done that, run me again!"
	exit 1
fi

# Ensure python3 has dlib and scikit-image packages
if [ $(pip3 list --format=legacy | egrep "^dlib |^scikit-image " | wc -l) -ne 2 ]; then
	echo "[!] dlib not found, installing now..."
	pip3 install -q dlib scikit-image
fi
# If the install failed, ask the user to do it themselves
if [ "$?" -ne "0" ]; then
	echo "[!] $ pip3 install dlib scikit-image"
	echo "[!] Failed. Replace pip3 in this script with the path of Python3's PIP"
	exit 1
fi

# Check that we have the face landmark model, otherwise download
if [ $(ls | grep "model.dat" | wc -l) -eq 1 ]; then
	echo "[+] Model already downloaded"
else
	echo "[-] Grabbing the NN face detection model ~100mb"
	wget -q --show-progress $MODEL
	mv *.bz2 model.dat.bz2
	echo "[-] Decompressing"
	bzip2 -d model.dat.bz2
fi

# Get Satya's faceAverage.py and add my additions
if [ $(ls | grep "faceAverage.py" | wc -l) -eq 1 ]; then
	echo "[+] Already have faceAverage.py"
else
	echo "[-] I don't want to reinvent the wheel, so we'll use Satya's final face averager"
	echo "[-] That said, I am taking some custom features in there"
	wget -q --show-progress $AVGPY
	sed -i -e 's/600/1000/g' faceAverage.py
	sed -i -e 's/cv2.waitKey(0)//g' faceAverage.py
	sed -i -e 's/presidents/faces/g' faceAverage.py
	sed -i -e "s/cv2.imshow('image', output)/cv2.imwrite('average.png', 255*output)/g" faceAverage.py
	sed -i -e 's/img = np.z/print("[+] Aligning " + str(len(imagesNorm)) + " faces: " + str(int(i \/ len(imagesNorm) * 100)) + "%   ", end="\\r"); img = np.z/g' faceAverage.py
	sed -i -e 's/.jpg")/.jpg") or filePath.endswith(".jpeg") or filePath.endswith(".png")/g' faceAverage.py
fi

echo -e "[+] And with that, the environment is setup\n"

if [[ -f $1 ]]; then # Video file
	echo -e "[+] Averaging faces from video: $1\n"
	mkdir -p frames
	echo "[-] Extracting every 5th frame, may take a bit, make yourself a cup of tea"
	ffmpeg -nostats -loglevel 0 -i $1 -vf "select=not(mod(n\,5))" -vsync vfr -q:v 2 frames/img_%05d.jpg
	python3 facePlucker.py
elif [[ -d $1 ]]; then # Picture dir
	echo -e "[+] Averaging faces from pictures in: $1\n"
    cp -r $1/* ims
else # No args
    echo "[!] Throw me a video file to average or a dir with images containing faces"
    exit 1
fi

# Copy only images and txts otherwise garbage is read by averager and it dies
python3 faceShaper.py
cp -r ims/*.png faces/ 2>/dev/null
cp -r ims/*.jpg faces/ 2>/dev/null
cp -r ims/*.jpeg faces/ 2>/dev/null
cp -r ims/*.txt faces/ 2>/dev/null
python3 faceAverage.py

rm -rf ims
rm -rf faces
rm -rf frames

echo "average.png written, enjoy!"
