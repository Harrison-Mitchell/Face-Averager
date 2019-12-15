# Face-Averager
Collects, aligns and average faces from a directory of images or a video. Examples below.

### Dependencies
* Python >= 3.7
* cmake (`apt install cmake`)
* dlib (`pip3 install dlib`)
* scikit-image (`pip3 install scikit-image`)

### How it works
I've done a writeup about it on my blog [here](https://harrisonm.com/blog/faces).

### Workflow
The included `manager` bash file will ensure you have all necessary dependacies and scripts. The `manager` will then call `facePlucker.py` to get the best unique faces from a video file. Then, or otherwise `faceShaper.py` gets called to calculate with a NN model, 68 different places on the face to help align and average. This step is necessary to prevent vomit output. Stacking hundreds of images with relative transparency would quickly get noisy and unless each photo's face are perfectly aligned and centered this is necessary. Finally `faceAverage.py` (installed by `manager`) will grab the faces and the spatial information to average and align the [Delaunay triangles](https://en.wikipedia.org/wiki/Delaunay_triangulation). The face is then written to `output.png`.

### Tip
You don't necessarily have to hit the streets to get hundreds of images, go to [Google Images](https://images.google.com) and load a whole page of results (for example: `nyc male` or `australian bogan`). Right click > Save page as. Give the photo folder of that download to the script and you'll get your average with little effort.

### Example output / usage
##### Directory of images
```
$ ./manager australianMales/

[+] Model already downloaded
[+] Already have faceAverage.py
[+] And with that, the environment is setup

[+] Averaging faces from pictures in: australianMales/

[+] Face triangulation is complete!                       
average.png written, enjoy!
```
<div align="center"><img align="center" src="https://raw.githubusercontent.com/Harrison-Mitchell/Face-Averager/master/example2.png" width="300px"></div>

##### Video file
```
$ ./manager sydneyWalk.mp4

[+] Model already downloaded
[+] Already have faceAverage.py
[+] And with that, the environment is setup

[+] Averaging faces from video: sydneyWalk.mp4

[-] Extracting every 5th frame, may take a bit, make yourself a cup of tea
[+] Face triangulation is complete!                            
average.png written, enjoy!
```
<div align="center"><img align="center" src="https://raw.githubusercontent.com/Harrison-Mitchell/Face-Averager/master/example1.png" width="300px"></div>
